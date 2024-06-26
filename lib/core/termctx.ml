(* This module should not be opened, but used qualified. *)

open Util
open Tbwd
open Dim
open Reporter
open Syntax
open Term

(* Here we define a data structure analogous to Ctx.t, but using terms rather than values.  This is used to store the context of a metavariable, as the value context containing level variables is too volatile to store in the Galaxy.  We also define a function to evaluate a Termctx into a Ctx.  (We can also read back a Ctx into a Termctx, but we wait to define that operation until readback.ml for dependency reasons.) *)

type 'b binding = { ty : ('b, kinetic) term; tm : ('b, kinetic) term option }

type (_, _, _) entry =
  | Vis : {
      dim : 'm D.t;
      plusdim : ('m, 'n, 'mn) D.plus;
      vars : (N.zero, 'n, string option, 'f1) NICubeOf.t;
      bindings : ('mn, ('b, 'mn) snoc binding) CubeOf.t;
      hasfields : ('m, 'f2) Ctx.has_fields;
      fields : (Field.t * string * (('b, 'mn) snoc, kinetic) term, 'f2) Bwv.t;
      fplus : ('f1, 'f2, 'f) N.plus;
    }
      -> ('b, 'f, 'mn) entry
  | Invis : ('n, ('b, 'n) snoc binding) CubeOf.t -> ('b, N.zero, 'n) entry

type (_, _) ordered =
  | Emp : (N.zero, emp) ordered
  | Snoc :
      ('a, 'b) ordered * ('b, 'x, 'n) entry * ('a, 'x, 'ax) N.plus
      -> ('ax, ('b, 'n) snoc) ordered
  (* A locked context permits no access to the variables behind it. *)
  | Lock : ('a, 'b) ordered -> ('a, 'b) ordered

type ('a, 'b) t = Permute : ('a, 'i) N.perm * ('i, 'b) ordered -> ('a, 'b) t

(* When printing a hole we also use a Termctx, since that's what we store anyway, and we would also have to read back a value context anyway in order to unparse it. *)
type printable += PHole : (string option, 'a) Bwv.t * ('a, 'b) t * ('b, kinetic) term -> printable

let link_entry : type b f mn. (Compunit.t -> Compunit.t) -> (b, f, mn) entry -> (b, f, mn) entry =
 fun f e ->
  match e with
  | Vis v ->
      let bindings =
        CubeOf.mmap
          { map = (fun _ [ b ] -> { ty = Link.term f b.ty; tm = Option.map (Link.term f) b.tm }) }
          [ v.bindings ] in
      Vis { v with bindings }
  | Invis bindings ->
      let bindings =
        CubeOf.mmap
          { map = (fun _ [ b ] -> { ty = Link.term f b.ty; tm = Option.map (Link.term f) b.tm }) }
          [ bindings ] in
      Invis bindings

let rec link_ordered : type a b. (Compunit.t -> Compunit.t) -> (a, b) ordered -> (a, b) ordered =
 fun f ctx ->
  match ctx with
  | Emp -> Emp
  | Snoc (ctx, e, ax) -> Snoc (link_ordered f ctx, link_entry f e, ax)
  | Lock ctx -> Lock (link_ordered f ctx)

let link : type a b. (Compunit.t -> Compunit.t) -> (a, b) t -> (a, b) t =
 fun f (Permute (p, ctx)) -> Permute (p, link_ordered f ctx)
