open Bwd
open Util
open Core
open Parser
open Format
open React
open Lwt
open LTerm_text

let usage_msg = "narya [options] <file1> [<file2> ...]"
let inputs = ref Emp
let anon_arg filename = inputs := Snoc (!inputs, `File filename)
let reformat = ref false
let verbose = ref false
let compact = ref false
let unicode = ref true
let typecheck = ref true
let interactive = ref false
let proofgeneral = ref false
let arity = ref 2
let refl_char = ref 'e'
let refl_strings = ref [ "refl"; "Id" ]
let internal = ref true
let discreteness = ref false
let source_only = ref false

let set_refls str =
  match String.split_on_char ',' str with
  | [] -> raise (Failure "Empty direction names")
  | c :: _ when String.length c <> 1 || c.[0] < 'a' || c.[0] > 'z' ->
      raise (Failure "Direction name must be a single lowercase letter")
  | c :: names ->
      refl_char := c.[0];
      refl_strings := names

let speclist =
  [
    ("-interactive", Arg.Set interactive, "Enter interactive mode (also -i)");
    ("-i", Arg.Set interactive, "");
    ("-proofgeneral", Arg.Set proofgeneral, "Enter proof general interaction mode");
    ( "-exec",
      Arg.String (fun str -> inputs := Snoc (!inputs, `String str)),
      "Execute a string, after all files loaded (also -e)" );
    ("-e", Arg.String (fun str -> inputs := Snoc (!inputs, `String str)), "");
    ("-verbose", Arg.Set verbose, "Show verbose messages (also -v)");
    ("-v", Arg.Set verbose, "");
    ("-no-check", Arg.Clear typecheck, "Don't typecheck and execute code (only parse it)");
    ("-reformat", Arg.Set reformat, "Display reformatted code on stdout");
    ("-noncompact", Arg.Clear compact, "Reformat code noncompactly (default)");
    ("-compact", Arg.Set compact, "Reformat code compactly");
    ("-unicode", Arg.Set unicode, "Display and reformat code using Unicode for built-ins (default)");
    ("-ascii", Arg.Clear unicode, "Display and reformat code using ASCII for built-ins");
    ("-arity", Arg.Set_int arity, "Arity of parametricity (default = 2)");
    ( "-direction",
      Arg.String set_refls,
      "Names for parametricity direction and reflexivity (default = e,refl,Id)" );
    ("-internal", Arg.Set internal, "Set parametricity to internal (default)");
    ("-external", Arg.Clear internal, "Set parametricity to external");
    ("-discreteness", Arg.Set discreteness, "Enable discreteness");
    ("-source-only", Arg.Set source_only, "Load all files from source (ignore compiled versions)");
    ( "-dtt",
      Unit
        (fun () ->
          arity := 1;
          refl_char := 'd';
          refl_strings := [];
          internal := false),
      "Abbreviation for -arity 1 -direction d -external" );
    ("--help", Arg.Unit (fun () -> ()), "");
    ("-", Arg.Unit (fun () -> inputs := Snoc (!inputs, `Stdin)), "");
  ]

let () =
  Arg.parse speclist anon_arg usage_msg;
  if Bwd.is_empty !inputs && (not !interactive) && not !proofgeneral then (
    Printf.fprintf stderr "No input files specified\n";
    Arg.usage speclist usage_msg;
    exit 1)

module Terminal = Asai.Tty.Make (Core.Reporter.Code)

let rec batch first ws p src =
  let cmd = Command.Parse.final p in
  if cmd = Eof then if Eternity.unsolved () then Reporter.fatal Open_holes else ws
  else (
    if !typecheck then Parser.Command.execute cmd;
    let ws =
      if !reformat then (
        let ws = if first then ws else Whitespace.ensure_starting_newlines 2 ws in
        Print.pp_ws `None std_formatter ws;
        Parser.Command.pp_command std_formatter cmd)
      else [] in
    let p, src = Command.Parse.restart_parse p src in
    batch false ws p src)

let execute init_visible compunit (source : Asai.Range.source) =
  if !reformat then Format.open_vbox 0;
  Units.run ~init_visible @@ fun () ->
  let p, src = Command.Parse.start_parse source in
  Compunit.Current.run ~env:compunit @@ fun () ->
  Reporter.try_with
    (fun () ->
      let ws = batch true [] p src in
      if !reformat then (
        let ws = Whitespace.ensure_ending_newlines 2 ws in
        Print.pp_ws `None std_formatter ws;
        Format.close_box ()))
    ~fatal:(fun d ->
      match d.message with
      | Quit _ ->
          let src =
            match source with
            | `File name -> Some name
            | `String { title; _ } -> title in
          Reporter.emit (Quit src)
      | _ -> Reporter.fatal_diagnostic d);
  Scope.get_export ()

let ( let* ) f o = Lwt.bind f o

class read_line terminal history prompt =
  object (self)
    inherit LTerm_read_line.read_line ~history ()
    inherit [Zed_string.t] LTerm_read_line.term terminal
    method! show_box = false
    initializer self#set_prompt (S.const (eval [ B_underline true; S prompt; B_underline false ]))
  end

let rec repl terminal history buf =
  let buf, prompt =
    match buf with
    | Some buf -> (buf, "")
    | None -> (Buffer.create 70, "narya\n") in
  let* command =
    Lwt.catch
      (fun () ->
        let rl = new read_line terminal (LTerm_history.contents history) prompt in
        rl#run >|= fun command -> Some command)
      (function
        | Sys.Break -> return None
        | exn -> Lwt.fail exn) in
  match command with
  | Some command ->
      let str = Zed_string.to_utf8 command in
      if str = "" then (
        let str = Buffer.contents buf in
        let* () = Lwt_io.flush Lwt_io.stdout in
        Reporter.try_with
          ~emit:(fun d -> Terminal.display ~output:stdout d)
          ~fatal:(fun d ->
            Terminal.display ~output:stdout d;
            match d.message with
            | Quit _ -> exit 0
            | _ -> ())
          (fun () ->
            match Command.parse_single str with
            | ws, None -> if !reformat then Print.pp_ws `None std_formatter ws
            | ws, Some cmd ->
                if !typecheck then Parser.Command.execute cmd;
                if !reformat then (
                  Print.pp_ws `None std_formatter ws;
                  let last = Parser.Command.pp_command std_formatter cmd in
                  Print.pp_ws `None std_formatter last;
                  Format.pp_print_newline std_formatter ()));
        LTerm_history.add history (Zed_string.of_utf8 (String.trim str));
        repl terminal history None)
      else (
        Buffer.add_string buf str;
        Buffer.add_char buf '\n';
        repl terminal history (Some buf))
  | None -> repl terminal history None

let history_file = Unix.getenv "HOME" ^ "/.narya_history"

let interact () =
  let* () = LTerm_inputrc.load () in
  let history = LTerm_history.create [] in
  let* () = LTerm_history.load history history_file in
  Lwt.catch
    (fun () ->
      let* terminal = Lazy.force LTerm.stdout in
      repl terminal history None)
    (function
      | LTerm_read_line.Interrupt ->
          let* () = LTerm_history.save history history_file in
          Lwt.return ()
      | exn ->
          let* () = LTerm_history.save history history_file in
          Lwt.fail exn)

let rec interact_pg () =
  print_endline "[narya]";
  try
    let str = read_line () in
    Reporter.try_with
      ~emit:(fun d -> Terminal.display ~output:stdout d)
      ~fatal:(fun d -> Terminal.display ~output:stdout d)
      (fun () ->
        match Command.parse_single str with
        | ws, None -> if !reformat then Print.pp_ws `None std_formatter ws
        | ws, Some cmd ->
            if !typecheck then Parser.Command.execute cmd;
            if !reformat then (
              Print.pp_ws `None std_formatter ws;
              let last = Parser.Command.pp_command std_formatter cmd in
              Print.pp_ws `None std_formatter last));
    interact_pg ()
  with End_of_file -> ()

let marshal_flags chan =
  Marshal.to_channel chan !arity [];
  Marshal.to_channel chan !refl_char [];
  Marshal.to_channel chan !refl_strings [];
  Marshal.to_channel chan !internal [];
  Marshal.to_channel chan !discreteness []

let unmarshal_flags chan =
  let ar = (Marshal.from_channel chan : int) in
  let rc = (Marshal.from_channel chan : char) in
  let rs = (Marshal.from_channel chan : string list) in
  let int = (Marshal.from_channel chan : bool) in
  let disc = (Marshal.from_channel chan : bool) in
  if ar = !arity && rc = !refl_char && rs = !refl_strings && int = !internal && disc = !discreteness
  then Ok ()
  else
    Error
      (Printf.sprintf "-arity %d -direction %s %s%s" ar
         (String.concat "," (String.make 1 rc :: rs))
         (if int then "-internal" else "-external")
         (if disc then " -discreteness" else ""))

let () =
  Parser.Unparse.install ();
  Units.Flags.run ~env:{ marshal = marshal_flags; unmarshal = unmarshal_flags } @@ fun () ->
  Eternity.run_empty @@ fun () ->
  Global.run_empty @@ fun () ->
  Builtins.run @@ fun () ->
  Printconfig.run
    ~env:
      {
        style = (if !compact then `Compact else `Noncompact);
        state = `Case;
        chars = (if !unicode then `Unicode else `ASCII);
      }
  @@ fun () ->
  Readback.Display.run ~env:false @@ fun () ->
  Core.Syntax.Discreteness.run ~env:!discreteness @@ fun () ->
  Reporter.run
    ~emit:(fun d ->
      if !verbose || d.severity = Error || d.severity = Warning then
        Terminal.display ~output:stderr d)
    ~fatal:(fun d ->
      Terminal.display ~output:stderr d;
      exit 1)
  @@ fun () ->
  if !arity < 1 || !arity > 9 then Reporter.fatal (Unimplemented "arities outside [1,9]");
  if !discreteness && !arity > 1 then Reporter.fatal (Unimplemented "discreteness with arity > 1");
  Dim.Endpoints.set_len !arity;
  Dim.Endpoints.set_char !refl_char;
  Dim.Endpoints.set_names !refl_strings;
  Dim.Endpoints.set_internal !internal;
  (* The initial namespace for all compilation units. *)
  let init = Parser.Pi.install Scope.Trie.empty in
  Compunit.Current.run ~env:Compunit.basic @@ fun () ->
  let top_files =
    Bwd.fold_right
      (fun input acc ->
        match input with
        | `File file -> FilePath.make_absolute (Sys.getcwd ()) file :: acc
        | _ -> acc)
      !inputs [] in
  Units.with_execute !source_only top_files init execute @@ fun () ->
  Mbwd.miter
    (fun [ input ] ->
      match input with
      | `File filename -> Units.load_file filename
      | `Stdin ->
          let content = In_channel.input_all stdin in
          Units.load_string (Some "stdin") content None
      (* Command-line strings have all the previous units loaded without needing to 'require' them. *)
      | `String content ->
          Units.load_string (Some "command-line exec string") content (Some (Units.all ())))
    [ !inputs ];
  (* Interactive mode also has all the other units loaded. *)
  if !interactive then
    Units.run ~init_visible:(Units.all ()) @@ fun () -> Lwt_main.run (interact ())
  else if !proofgeneral then Units.run ~init_visible:(Units.all ()) @@ fun () -> interact_pg ()
