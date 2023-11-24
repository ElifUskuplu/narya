open Parser

(* Translate a parse observation into something that shows the names of notations rather than their internal abstract representations, for easier inspection and testing.  Note that since we intercept the parse tree before the "compilation" step, there is no name resolution, so this doesn't need to be run inside a Yuujinchou handler and can use unbound variables. *)

type obs =
  | Flag of Notation.flag
  | Ident of string option
  | Term of parse_tree
  | Constr of string
  | Field of string

and parse_tree =
  | Notn of string * obs list
  | App of parse_tree * parse_tree
  | Ident of string
  | Constr of string
  | Field of string
  | Numeral of Q.t
  | Abs of [ `Normal | `Cube ] * string option list * parse_tree

let rec get_obs (obs : Notation.observation) : obs =
  match obs with
  | Flagged f -> Flag f
  | Ident x -> Ident x
  | Term r -> Term (get_tree r)
  | Constr c -> Constr c
  | Field f -> Field f

and get_tree (r : Notation.parse) : parse_tree =
  match r with
  | Infix (n, args) -> Notn (Notation.name n, List.map get_obs args)
  | Prefix (n, args) -> Notn (Notation.name n, List.map get_obs args)
  | Postfix (n, args) -> Notn (Notation.name n, List.map get_obs args)
  | Outfix (n, args) -> Notn (Notation.name n, List.map get_obs args)
  | App (x, y) -> App (get_tree x, get_tree y)
  | Ident x -> Ident x
  | Constr x -> Constr x
  | Field x -> Field x
  | Numeral n -> Numeral n
  | Abs (cube, vars, body) -> Abs (cube, vars, get_tree body)

let parse state str = get_tree (Parse.term state str)
