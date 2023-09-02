open Util
open Dim
open Core
open Parser
open Term

let ([ nn; zero; suc; plus; times; ind ] : (Constant.t, N.six) Vec.t) =
  Vec.map Constant.intern [ "N"; "O"; "S"; "plus"; "times"; "ind" ]

let plus_scope = Scope.make "nat_plus"
let times_scope = Scope.make "nat_times"

let install () =
  Hashtbl.add Global.types nn UU;
  Hashtbl.add Global.types zero (Const nn);
  Hashtbl.add Global.types suc (Pi (Const nn, Const nn));
  Hashtbl.add Global.types plus (Pi (Const nn, Pi (Const nn, Const nn)));
  Hashtbl.add Global.types times (Pi (Const nn, Pi (Const nn, Const nn)));
  Hashtbl.add Global.trees plus
    (Lam
       ( Suc (Suc Zero),
         Branch
           ( Top,
             [
               Branch (zero, Zero, Zero, Leaf (Var (Pop Top)));
               Branch
                 ( suc,
                   Take Zero,
                   Suc Zero,
                   Leaf
                     (App
                        ( Const suc,
                          CubeOf.singleton
                            (App
                               ( App (Const plus, CubeOf.singleton (Var (Pop (Pop Top)))),
                                 CubeOf.singleton (Var Top) )) )) );
             ] ) ));
  Hashtbl.add Global.trees times
    (Lam
       ( Suc (Suc Zero),
         Branch
           ( Top,
             [
               Branch (zero, Zero, Zero, Leaf (Const zero));
               Branch
                 ( suc,
                   Take Zero,
                   Suc Zero,
                   Leaf
                     (App
                        ( App
                            ( Const plus,
                              CubeOf.singleton
                                (App
                                   ( App (Const times, CubeOf.singleton (Var (Pop (Pop Top)))),
                                     CubeOf.singleton (Var Top) )) ),
                          CubeOf.singleton (Var (Pop (Pop Top))) )) );
             ] ) ));
  Hashtbl.add Global.types ind
    (Pi
       ( (* P : *) Pi (Const nn, UU),
         Pi
           ( (* z : *) App (Var Top, CubeOf.singleton (Const zero)),
             Pi
               ( (* s : *)
                 Pi
                   ( (* n : *) Const nn,
                     Pi
                       ( (* pn : *)
                         App (Var (Pop (Pop Top)), CubeOf.singleton (Var Top)),
                         App
                           ( Var (Pop (Pop (Pop Top))),
                             CubeOf.singleton (App (Const suc, CubeOf.singleton (Var (Pop Top)))) )
                       ) ),
                 Pi ((* n : *) Const nn, App (Var (Pop (Pop (Pop Top))), CubeOf.singleton (Var Top)))
               ) ) ));
  Hashtbl.add Global.trees ind
    (Lam
       ( Suc (Suc (Suc (Suc Zero))),
         Branch
           ( Top,
             [
               Branch (zero, Zero, Zero, Leaf (Var (Pop (Pop Top))));
               Branch
                 ( suc,
                   Take Zero,
                   Suc Zero,
                   Leaf
                     (App
                        ( App (Var (Pop (Pop Top)), CubeOf.singleton (Var Top)),
                          CubeOf.singleton
                            (App
                               ( App
                                   ( App
                                       ( App
                                           ( Const ind,
                                             CubeOf.singleton (Var (Pop (Pop (Pop (Pop Top))))) ),
                                         CubeOf.singleton (Var (Pop (Pop (Pop Top)))) ),
                                     CubeOf.singleton (Var (Pop (Pop Top))) ),
                                 CubeOf.singleton (Var Top) )) )) );
             ] ) ));
  Parse.rightassoc_notations :=
    !Parse.rightassoc_notations
    |> Scope.Map.add plus_scope (new Notation.simple `Infix plus [ "+" ])
    |> Scope.Map.add times_scope (new Notation.simple `Infix times [ "*" ]);
  Option.get (Scope.add_prec plus_scope times_scope);
  Scope.open_scope plus_scope;
  Scope.open_scope times_scope