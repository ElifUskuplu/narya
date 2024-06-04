def bool : Type ≔ data [ true. | false. ]
def ℕ : Type ≔ data [ zero. | suc. (_:ℕ) ]

def bool.and (x y : bool) : bool ≔ match x,y [
| true. , true. ↦ true.
| true. , false. ↦ false.
| false. , true. ↦ false.
| false. , false. ↦ false.
]

echo bool.and true. true.

echo bool.and false. true.

def plus (m n : ℕ) : ℕ ≔ match n [
| zero. ↦ m
| suc. n ↦ suc. (plus m n)
]

notation 5 plus : x "+" y ≔ plus x y

def fib (n : ℕ) : ℕ ≔ match n [
| zero. ↦ 1
| suc. zero. ↦ 1
| suc. (suc. n) ↦ fib n + fib (suc. n)
]

echo fib 6
echo fib 7

def even (n : ℕ) : Type ≔ match n [
| zero. ↦ data [ even_zero. ]
| suc. zero. ↦ data [ ]
| suc. (suc. n) ↦ data [ even_plus2. (_ : even n) ]
]

def ⊥ : Type ≔ data []

def one_not_even : even 1 → ⊥ ≔ [ ]

def suc_even_not_even (n : ℕ) (e : even n) (e1 : even (suc. n)) : ⊥ ≔ match n, e, e1 [
| zero. , even_zero. , _ ↦ .
| suc. zero. , _ , _ ↦ .
| suc. (suc. n) , even_plus2. e , even_plus2. e1 ↦ suc_even_not_even n e e1
]

{` We can omit the refutation cases `}
def suc_even_not_even' (n : ℕ) (e : even n) (e1 : even (suc. n)) : ⊥ ≔ match n, e, e1 [
| suc. (suc. n) , even_plus2. e , even_plus2. e1 ↦ suc_even_not_even n e e1
]

def ⊤ : Type ≔ sig ()

def sum (A B : Type) : Type ≔ data [ inl. (_:A) | inr. (_:B) ]

{` We can refute a new pattern variable `}
def sum⊥ (A : Type) (a : sum A ⊥) : A ≔ match a [
| inl. a ↦ a
| inr. _ ↦ .
]

{` And we can omit the refutation case if at least one constructor is given `}
def sum⊥' (A : Type) (a : sum A ⊥) : A ≔ match a [
| inl. a ↦ a
]

{` We check that omission of a branch doesn't break normalization `}
axiom oops : ⊥

echo sum⊥' Type (inr. oops)

def is_zero : ℕ → Type ≔ [ zero. ↦ ⊤ | suc. _ ↦ ⊥ ]

{` We can refute a later argument `}
def is_zero_eq_zero (n : ℕ) (z : is_zero n) : Id ℕ n 0 ≔ match n, z [
| zero. , _ ↦ refl (0:ℕ)
| suc. _ , _ ↦ .
]

{` And we can omit the refutation case if at least one constructor of the necessary split is given. `}
def is_zero_eq_zero' (n : ℕ) (z : is_zero n) : Id ℕ n 0 ≔ match n, z [
| zero. , _ ↦ refl (0:ℕ)
]

{` We can also refute an *earlier* argument. `}
def is_zero_eq_zero_rev (n : ℕ) (z : is_zero n) : Id ℕ n 0 ≔ match z, n [
| _, zero. ↦ refl (0:ℕ)
| _, suc. _  ↦ .
]

{` And we can similarly omit its case `}
def is_zero_eq_zero_rev' (n : ℕ) (z : is_zero n) : Id ℕ n 0 ≔ match z, n [
| _, zero. ↦ refl (0:ℕ)
]
