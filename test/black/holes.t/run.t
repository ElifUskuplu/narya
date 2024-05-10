  $ narya -v holes.ny
   ￫ info[I0001]
   ￮ Axiom A assumed
  
   ￫ info[I0001]
   ￮ Axiom B assumed
  
   ￫ info[I0000]
   ￮ Constant id defined
  
   ￫ info[I0100]
   ￭ holes.ny
   7 | def f : A → B ≔ ?
   8 | 
   9 | def f' : A → B ≔ x ↦ ?
     ^ hole ?0 generated:
       
       ----------------------------------------------------------------------
       A → B
  
   ￫ info[I0000]
   ￮ Constant f defined
  
   ￫ info[I0100]
   ￭ holes.ny
    9 | def f' : A → B ≔ x ↦ ?
   10 | 
   11 | def ℕ : Type ≔ data [
      ^ hole ?1 generated:
        
        x : A
        ----------------------------------------------------------------------
        B
  
   ￫ info[I0000]
   ￮ Constant f' defined
  
   ￫ info[I0000]
   ￮ Constant ℕ defined
  
   ￫ info[I0100]
   ￭ holes.ny
   17 | | zero. ↦ ?
   18 | | suc. n ↦ ?
      ^ hole ?2 generated:
        
        m : ℕ
        n ≔ 0 : ℕ
        ----------------------------------------------------------------------
        ℕ
  
   ￫ info[I0100]
   ￭ holes.ny
   18 | | suc. n ↦ ?
   19 | ]
      ^ hole ?3 generated:
        
        m : ℕ
        n : ℕ
        n0 ≔ suc. n : ℕ (not in scope)
        ----------------------------------------------------------------------
        ℕ
  
   ￫ info[I0000]
   ￮ Constant plus defined
  
   ￫ info[I0001]
   ￮ Axiom P assumed
  
   ￫ info[I0100]
   ￭ holes.ny
   23 | def anop : ℕ → ℕ → (x : ℕ) → P x ≔ n n0 n ↦ ?
   24 | 
   25 | {` The user's "n0" should not be shadowed by an auto-generated one `}
   26 | def anop' : ℕ → ℕ → (x : ℕ) → P x ≔ n0 n n ↦ ?
      ^ hole ?4 generated:
        
        n1 : ℕ (not in scope)
        n0 : ℕ
        n : ℕ
        ----------------------------------------------------------------------
        P n
  
   ￫ info[I0000]
   ￮ Constant anop defined
  
   ￫ info[I0100]
   ￭ holes.ny
   26 | def anop' : ℕ → ℕ → (x : ℕ) → P x ≔ n0 n n ↦ ?
   27 | 
   28 | def anop'' : ℕ → ℕ → (x : ℕ) → P x ≔ n _ n ↦ ?
      ^ hole ?5 generated:
        
        n0 : ℕ
        n1 : ℕ (not in scope)
        n : ℕ
        ----------------------------------------------------------------------
        P n
  
   ￫ info[I0000]
   ￮ Constant anop' defined
  
   ￫ info[I0100]
   ￭ holes.ny
   28 | def anop'' : ℕ → ℕ → (x : ℕ) → P x ≔ n _ n ↦ ?
   29 | 
   30 | {` Nor the user's H be shadowed by an auto-generated one `}
   31 | def anop''' : ℕ → ℕ → (x : ℕ) → P x ≔ H _ n ↦ ?
      ^ hole ?6 generated:
        
        n0 : ℕ (not in scope)
        H : ℕ (not in scope)
        n : ℕ
        ----------------------------------------------------------------------
        P n
  
   ￫ info[I0000]
   ￮ Constant anop'' defined
  
   ￫ info[I0100]
   ￭ holes.ny
   31 | def anop''' : ℕ → ℕ → (x : ℕ) → P x ≔ H _ n ↦ ?
   32 | 
   33 | def Σ (A:Type) (B : A → Type) : Type ≔ sig (
      ^ hole ?7 generated:
        
        H : ℕ
        H0 : ℕ (not in scope)
        n : ℕ
        ----------------------------------------------------------------------
        P n
  
   ￫ info[I0000]
   ￮ Constant anop''' defined
  
   ￫ info[I0000]
   ￮ Constant Σ defined
  
   ￫ info[I0100]
   ￭ holes.ny
   39 | def pp : Σ Type (X ↦ X) ≔ ( ? , ? )
      ^ hole ?8 generated:
        
        ----------------------------------------------------------------------
        Type
  
   ￫ info[I0100]
   ￭ holes.ny
   39 | def pp : Σ Type (X ↦ X) ≔ ( ? , ? )
      ^ hole ?9 generated:
        
        ----------------------------------------------------------------------
        pp .fst
  
   ￫ info[I0000]
   ￮ Constant pp defined
  
   ￫ info[I0100]
   ￭ holes.ny
   43 | def pp' : Σ Type (X ↦ X) ≔ ( id ? , ? )
      ^ hole ?10 generated:
        
        ----------------------------------------------------------------------
        Type
  
   ￫ info[I0100]
   ￭ holes.ny
   43 | def pp' : Σ Type (X ↦ X) ≔ ( id ? , ? )
      ^ hole ?11 generated:
        
        ----------------------------------------------------------------------
        ?10
  
   ￫ info[I0000]
   ￮ Constant pp' defined
  
   ￫ info[I0100]
   ￭ holes.ny
   49 |   baz : ?,
      ^ hole ?12 generated:
        
        H : foo (not in scope)
        bar : ℕ
        ----------------------------------------------------------------------
        Type
  
   ￫ info[I0000]
   ￮ Constant foo defined
  
   ￫ info[I0001]
   ￮ Axiom C assumed
  
   ￫ info[I0000]
   ￮ Constant AC defined
  
   ￫ info[I0100]
   ￭ holes.ny
   60 |   a ≔ ?,
      ^ hole ?13 generated:
        
        ----------------------------------------------------------------------
        ℕ → A
  
   ￫ info[I0100]
   ￭ holes.ny
   61 |   c ≔ ?
   62 | )
      ^ hole ?14 generated:
        
        ----------------------------------------------------------------------
        C (ac .a 0)
  
   ￫ info[I0000]
   ￮ Constant ac defined
  
   ￫ info[I0000]
   ￮ Constant ida defined
  
   ￫ info[I0000]
   ￮ Constant ideqid defined
  
  u u0 u1 ↦ u1
  
   ￫ info[I0000]
   ￮ Constant ideqid' defined
  
  u u0 u00 ↦ u00
  
   ￫ info[I0100]
   ￭ holes.ny
   75 | def ideqid'' : Id (A -> A) ida ida := ((x |-> x) : Id (A -> A ) ida ida -> Id (A -> A) ida ida) (u u u |-> ?)
      ^ hole ?15 generated:
        
        u1 : A (not in scope)
        u0 : A (not in scope)
        u : refl A u1 u0
        ----------------------------------------------------------------------
        refl A u1 u0
  
   ￫ info[I0000]
   ￮ Constant ideqid'' defined
  
   ￫ info[I0100]
   ￭ holes.ny
   78 | def afam : Type → Type ≔ X ↦ id ?
   79 | 
   80 | {` This requires comparing a metavariable to equal itself when evaluated in equal environments. `}
   81 | def idafam (X:Type) : afam X → afam X ≔ x ↦ x
      ^ hole ?16 generated:
        
        X : Type
        ----------------------------------------------------------------------
        Type
  
   ￫ info[I0000]
   ￮ Constant afam defined
  
   ￫ info[I0000]
   ￮ Constant idafam defined
  
   ￫ error[E3000]
   ￮ There are open holes
  
  [1]

  $ narya -v -dtt dtt-holes.ny
   ￫ info[I0000]
   ￮ Constant f defined
  
   ￫ info[I0100]
   ￭ dtt-holes.ny
   4 | def g (X : Type) : Type⁽ᵈ⁾ X ≔ (f ?)⁽ᵈ⁾
     ^ hole ?0 generated:
       
       X : Type (blocked by modal lock)
       ----------------------------------------------------------------------
       Type
  
   ￫ error[E0401]
   ￭ dtt-holes.ny
   4 | def g (X : Type) : Type⁽ᵈ⁾ X ≔ (f ?)⁽ᵈ⁾
   5 | 
     ^ term synthesized type
         Type⁽ᵈ⁾ ?0
       but is being checked against type
         Type⁽ᵈ⁾ X
  
  [1]