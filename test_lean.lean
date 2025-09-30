-- Test file per verificare lean.nvim
def test_function (n : Nat) (y: Nat) : Nat := n + y

#check test_function
#eval test_function 5 1

-- Esempio di codice funzionante
example : 2 + 2 = 4 := rfl
