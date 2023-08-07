(* Type-level (additive) monoids *)

type (_, _) eq = Eq : ('a, 'a) eq
type (_, _) compare = Eq : ('a, 'a) compare | Neq : ('a, 'b) compare

module type Monoid = sig
  (* The elements of the monoid are the types that satisfy this predicate. *)
  type 'a t

  (* Addition defined as a relation *)
  type ('a, 'b, 'c) plus

  (* To compute a sum, we wrap up the output in a GADT. *)
  type (_, _) has_plus = Has_plus : ('a, 'b, 'c) plus -> ('a, 'b) has_plus

  (* The conditions on which of these have to be assumed and which are deduced follows what happens for type-level natural numbers.  If we had other examples, we might have to be more flexible. *)
  val plus : 'b t -> ('a, 'b) has_plus
  val plus_right : ('a, 'b, 'c) plus -> 'b t
  val plus_out : 'a t -> ('a, 'b, 'c) plus -> 'c t

  (* Sums are unique *)
  val plus_uniq : ('a, 'b, 'c) plus -> ('a, 'b, 'd) plus -> ('c, 'd) eq

  (* The unit element of the monoid is called zero *)
  type zero

  val zero : zero t
  val zero_plus : 'a t -> (zero, 'a, 'a) plus
  val plus_zero : 'a t -> ('a, zero, 'a) plus

  (* Addition is associative *)
  val plus_assocl :
    ('a, 'b, 'ab) plus -> ('b, 'c, 'bc) plus -> ('a, 'bc, 'abc) plus -> ('ab, 'c, 'abc) plus

  val plus_assocr :
    ('a, 'b, 'ab) plus -> ('b, 'c, 'bc) plus -> ('ab, 'c, 'abc) plus -> ('a, 'bc, 'abc) plus
end

module type MonoidPos = sig
  include Monoid

  type _ pos

  val zero_nonpos : zero pos -> 'c
  val plus_pos : 'a t -> 'b pos -> ('a, 'b, 'ab) plus -> 'ab pos
  val pos_plus : 'a pos -> ('a, 'b, 'ab) plus -> 'ab pos
  val pos : 'a pos -> 'a t

  type _ compare_zero = Zero : zero compare_zero | Pos : 'n pos -> 'n compare_zero

  val compare_zero : 'a t -> 'a compare_zero
end
