open Bwd
open Bwd.Infix
open Dim
open Core
open Util
open Term
open Nat

let ([ vec; concat; ind ] : (Constant.t, N.three) Vec.t) =
  Vec.map Constant.intern [ "Vec"; "concat"; "Vec_ind" ]

let ([ nil; cons ] : (Constr.t, N.two) Vec.t) = Vec.map Constr.intern [ "nil"; "cons" ]

let install () =
  Nat.install ();
  Hashtbl.add Global.types vec (pi (UU D.zero) (pi (Const nn) (UU D.zero)));
  Hashtbl.add Global.constants vec
    (Data
       {
         params = N.one;
         indices = Suc Zero;
         constrs =
           Constr.Map.empty
           |> Constr.Map.add nil
                (Global.Constr { args = Emp; indices = Snoc (Emp, Constr (zero', D.zero, Emp)) })
           |> Constr.Map.add cons
                (Global.Constr
                   {
                     args =
                       Ext
                         ( Const nn,
                           Ext
                             ( Var (Pop Top),
                               Ext
                                 ( App
                                     ( App (Const vec, CubeOf.singleton (Term.Var (Pop (Pop Top)))),
                                       CubeOf.singleton (Term.Var (Pop Top)) ),
                                   Emp ) ) );
                     indices =
                       Snoc
                         ( Emp,
                           Constr (suc', D.zero, Emp <: CubeOf.singleton (Term.Var (Pop (Pop Top))))
                         );
                   });
       });
  Hashtbl.add Global.types concat
    (pi (UU D.zero)
       (pi (Const nn)
          (pi (Const nn)
             (pi
                (apps (Const vec) [ Var (Pop (Pop Top)); Var (Pop Top) ])
                (pi
                   (apps (Const vec) [ Var (Pop (Pop (Pop Top))); Var (Pop Top) ])
                   (apps (Const vec)
                      [
                        Var (Pop (Pop (Pop (Pop Top))));
                        apps (Const plus) [ Var (Pop (Pop (Pop Top))); Var (Pop (Pop Top)) ];
                      ]))))));
  Hashtbl.add Global.types ind
    (pi (UU D.zero)
       (pi
          (pi (Const nn) (pi (apps (Const vec) [ Var (Pop Top); Var Top ]) (UU D.zero)))
          (pi
             (apps (Var Top) [ constr zero' Emp; constr nil Emp ])
             (pi
                (pi (Const nn)
                   (pi (Var (Pop (Pop (Pop Top))))
                      (pi
                         (apps (Const vec) [ Var (Pop (Pop (Pop (Pop Top)))); Var (Pop Top) ])
                         (pi
                            (apps (Var (Pop (Pop (Pop (Pop Top))))) [ Var (Pop (Pop Top)); Var Top ])
                            (apps (Var (Pop (Pop (Pop (Pop (Pop Top))))))
                               [
                                 constr suc' (Emp <: Var (Pop (Pop (Pop Top))));
                                 constr cons
                                   (Emp
                                   <: Var (Pop (Pop (Pop Top)))
                                   <: Var (Pop (Pop Top))
                                   <: Var (Pop Top));
                               ])))))
                (pi (Const nn)
                   (pi
                      (apps (Const vec) [ Var (Pop (Pop (Pop (Pop Top)))); Var Top ])
                      (apps (Var (Pop (Pop (Pop (Pop Top))))) [ Var (Pop Top); Var Top ])))))));
  Hashtbl.add Global.constants ind
    (Defined
       (Lam
          (Lam
             (Lam
                (Lam
                   (Lam
                      (Lam
                         (Branches
                            ( Top,
                              Constr.Map.of_list
                                [
                                  (nil, Case.Branch (Zero, Leaf (Var (Pop (Pop (Pop Top))))));
                                  ( cons,
                                    Branch
                                      ( Suc (Suc (Suc Zero)),
                                        Leaf
                                          (apps (Var (Pop (Pop (Pop (Pop (Pop Top))))))
                                             [
                                               Var (Pop (Pop Top));
                                               Var (Pop Top);
                                               Var Top;
                                               apps (Const ind)
                                                 [
                                                   Var
                                                     (Pop
                                                        (Pop (Pop (Pop (Pop (Pop (Pop (Pop Top))))))));
                                                   Var (Pop (Pop (Pop (Pop (Pop (Pop (Pop Top)))))));
                                                   Var (Pop (Pop (Pop (Pop (Pop (Pop Top))))));
                                                   Var (Pop (Pop (Pop (Pop (Pop Top)))));
                                                   Var (Pop (Pop Top));
                                                   Var Top;
                                                 ];
                                             ]) ) );
                                ] )))))))))
