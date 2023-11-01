open Util
open Dim
open Value
open Term
open Hctx

type (_, _) t

val vis : ('a, 'b) t -> ('n, level option * normal) CubeOf.t -> ('a N.suc, ('b, 'n) ext) t
val invis : ('a, 'b) t -> ('n, level option * normal) CubeOf.t -> ('a, ('b, 'n) ext) t

val split :
  ('a, 'b) t ->
  ('n, 'f) count_faces ->
  ('a, 'f, 'af) N.plus ->
  ('n, level option * normal) CubeOf.t ->
  ('af, ('b, 'n) ext) t

val length : ('a, 'b) t -> int
val empty : (N.zero, emp) t
val lookup : ('a, 'b) t -> 'a Raw.index -> level option * normal * 'b index

val lookup_face :
  ('a, 'f, 'af) N.plus ->
  ('n sface_of, 'f) Bwv.t ->
  ('a, 'b) t ->
  ('n, level option * normal) CubeOf.t ->
  'af Raw.index ->
  level option * normal * ('b, 'n) ext index

val lookup_invis : ('a, 'b) t -> 'b index -> level option * normal
val find_level : ('a, 'b) t -> level -> 'b index option
val env : ('a, 'b) t -> (D.zero, 'b) env
val eval : ('a, 'b) t -> 'b term -> value
val ext : ('a, 'b) t -> value -> ('a N.suc, ('b, D.zero) ext) t
val ext_let : ('a, 'b) t -> normal -> ('a N.suc, ('b, D.zero) ext) t

val exts :
  ('a, 'd) t ->
  ('b1, 'b2, 'b) N.plus ->
  ('a, 'b2, 'ab2) N.plus ->
  ('d, 'b, 'db, D.zero) exts ->
  (level option * normal, 'b) Bwv.t ->
  ('ab2, 'db) t

val ext_invis :
  ('a, 'd) t -> ('d, 'b, 'db, D.zero) exts -> (level option * normal, 'b) Bwv.t -> ('a, 'db) t

val ext_tel :
  ('a, 'e) t ->
  ('n, 'b) env ->
  ('b, 'c, 'bc) Telescope.t ->
  ('a, 'c, 'ac) N.plus ->
  ('e, 'c, 'ec, 'n) exts ->
  ('ac, 'ec) t * ('n, 'bc) env * (('n, value) CubeOf.t, 'c) Bwv.t

val bind_some : (level -> normal option) -> ('a, 'e) t -> ('a, 'e) t