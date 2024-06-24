  $ narya -v solve.ny
   ￫ info[I0000]
   ￮ constant ℕ defined
  
   ￫ info[I0100]
   ￭ $TESTCASE_ROOT/solve.ny
   3 | def Nat : Type ≔ ?
     ^ hole ?0 generated:
       
       ----------------------------------------------------------------------
       Type
  
   ￫ info[I0000]
   ￮ constant Nat defined, containing 1 hole
  
   ￫ info[I0005]
   ￮ hole solved
  
   ￫ info[I0100]
   ￭ $TESTCASE_ROOT/solve.ny
   7 | def plus (x y : ℕ) : ℕ ≔ ?
     ^ hole ?1 generated:
       
       x : ℕ
       y : ℕ
       ----------------------------------------------------------------------
       ℕ
  
   ￫ info[I0000]
   ￮ constant plus defined, containing 1 hole
  
   ￫ info[I0100]
   ￭ $TESTCASE_ROOT/solve.ny
   9 | solve 1 ≔ match y [ zero. ↦ ? | suc. z ↦ ? ]
     ^ hole ?2 generated:
       
       x : ℕ
       y ≔ 0 : ℕ
       ----------------------------------------------------------------------
       ℕ
  
   ￫ info[I0100]
   ￭ $TESTCASE_ROOT/solve.ny
   9 | solve 1 ≔ match y [ zero. ↦ ? | suc. z ↦ ? ]
     ^ hole ?3 generated:
       
       x : ℕ
       z : ℕ
       y ≔ suc. z : ℕ
       ----------------------------------------------------------------------
       ℕ
  
   ￫ info[I0005]
   ￮ hole solved, containing 2 new holes
  
   ￫ info[I0005]
   ￮ hole solved
  
   ￫ info[I0005]
   ￮ hole solved
  
  9
    : ℕ
  
