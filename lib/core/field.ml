open Bwd
open Dim
open Util
open Signatures

type raw = string * int Bwd.t
type 'i field = string * 'i D.t
type 'i t = 'i field

let intern (str : string) (i : 'i D.t) : 'i t = (str, i)
let to_string (x : 'i t) : string = fst x

let strings_to_string (f : string) (p : string list) =
  f
  ^
  if List.exists (fun x -> String.length x > 1) p then ".." ^ String.concat "." p
  else "." ^ String.concat "" p

let dim (x : 'i t) : 'i D.t = snd x

let equal : type i j. i t -> j t -> (i, j) Eq.compare =
 fun x y -> if fst x = fst y then D.compare (snd x) (snd y) else Neq

type wrapped = Wrap : 'i t -> wrapped
type with_ins = WithIns : 'i t * ('n, 't, 'i) insertion -> with_ins
type or_index = Name : raw -> or_index | Index : int -> or_index

let to_string_ori (x : or_index) : string =
  match x with
  | Name (f, p) ->
      if Bwd.exists (fun i -> i > 9) p then
        f ^ ".." ^ String.concat "." (Bwd_extra.to_list_map string_of_int p)
      else f ^ "." ^ String.concat "" (Bwd_extra.to_list_map string_of_int p)
  | Index n -> string_of_int n

let intern_ori (str : string) : or_index =
  try
    let n = int_of_string str in
    Index n
  with Failure _ -> Name (str, Emp)

module Abwd (F : Fam2) = struct
  type 'a entry = Entry : ('i t * ('i, 'a) F.t) -> 'a entry
  type 'a t = 'a entry Bwd.t

  type (_, _) find_opt_result =
    | Found : ('i, 'a) F.t -> ('i, 'a) find_opt_result
    | Wrong_dimension : 'j D.t * ('j, 'a) F.t -> ('i, 'a) find_opt_result
    | Not_found : ('i, 'a) find_opt_result

  let rec find_opt : type i a. a t -> i field -> (i, a) find_opt_result =
   fun fields ((name, i) as fld) ->
    match fields with
    | Emp -> Not_found
    | Snoc (fields, Entry ((name', i'), x)) -> (
        match (name = name', D.compare i i') with
        | true, Eq -> Found x
        | true, Neq -> Wrong_dimension (i', x)
        | _ -> find_opt fields fld)

  let rec find_string_opt : type a. a t -> string -> a entry option =
   fun fields name ->
    match fields with
    | Emp -> None
    | Snoc (fields, (Entry ((name', _), _) as e)) ->
        if name = name' then Some e else find_string_opt fields name
end
