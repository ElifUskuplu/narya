axiom A : Type
def f : A → A → A ≔ a b ↦ b
axiom g : A → A → A
def h : A → A → A ≔ a b ↦ a
notation(0) x "+" y ≔ f x y
notation(1) x "*" y ≔ g x y
notation(-1) x "%" y ≔ h x y
axiom a : A
axiom b : A
axiom c : A
echo a + b * c
echo a * b + c
echo a % b + c
echo a + b % c
echo a * b % c
echo a % b * c
