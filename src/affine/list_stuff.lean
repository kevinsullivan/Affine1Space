open list

universes u v
variables (K : Type u) [field K] {α : Type v} [has_add α]
(x y : K) (xl : list K)

/-- addition function on `list α`, where `α` has an addition function -/
def ladd : list α → list α → list α := zip_with has_add.add

/- 
    The following theorems are stolen from data.list.zip and adapted for the zip_with function, which is
    more generic than the zip function the lemmata were initially used for. These lemmata are used in the
    file aff_coord_space to prove statements necessary to show aff_vec is a vector space. 
-/

/-- addition is compatible with list constructor -/
@[simp] theorem add_cons_cons (a b : α) (l₁ l₂ : list α) :
  ladd (a :: l₁) (b :: l₂) = (a + b) :: ladd l₁ l₂ := rfl

/-- adding the empty list to a list gives you the empty list -/
@[simp] theorem add_nil_left (l : list α) : ladd ([] : list α) l = [] := rfl

/-- adding a list to the empty list gives you the empty list -/
@[simp] theorem add_nil_right (l : list α) : ladd l ([] : list α) = [] :=
by cases l; refl

/-- The length of the sum of two lists is the length of the shorter list -/
@[simp] theorem length_sum : ∀ (l₁ : list α) (l₂ : list α),
   length (ladd l₁ l₂) = min (length l₁) (length l₂)
| []      l₂      := rfl
| l₁      []      := by simp -- TODO: figure out which simp lemmata are being used, and use "simp only"
| (a::l₁) (b::l₂) := by simp only [length, add_cons_cons, length_sum l₁ l₂, min_add_add_right]

/-- the length of nil is 0 -/
lemma len_nil : length ([] : list α) = 0 := rfl

lemma len_cons : length (x :: xl) = length xl + 1 := rfl

/-- Implements list addition coordinate-wise w.r.t. the addition function on the list entries. -/
instance (α : Type*) [has_add α] : has_add (list α) := ⟨ladd⟩

-- TODO: rename this lemma. It's actually important
lemma sum_test : ∀ a b : list K, a + b = ladd a b := by {intros, refl}

lemma sum_test' : ∀ a b : list K, a + b = (zip_with has_add.add) a b := by {intros, refl}

/-- returns list rep of 0 vector of given length. -/
def list.field_zero : ℕ → list K
| 0 := [0]
| (nat.succ n) := 0 :: (list.field_zero n)

/-- returns a list multiplied element-wise by a scalar. -/
def list.field_scalar : K → list K → list K
| x [] := []
| x (a :: l) := (x * a) :: (list.field_scalar x l)


lemma scalar_nil : list.field_scalar K x [] = [] := rfl

lemma scalar_cons : list.field_scalar K y (x :: xl) = (y * x) :: (list.field_scalar K y xl) := rfl

lemma scale_len : length (list.field_scalar K x xl) = length xl := 
begin
induction xl,
rw scalar_nil,
simp only [scalar_cons, len_cons, xl_ih],
end


--below are functions. TODO: remove 2 of the neg functions

def field_neg : K → K := λ a, -a

def list.neg : list K → list K := map (field_neg K)

def list.neg' : list K → list K := λ x, list.field_scalar K (-1 : K) x

def list.neg'' : list K → list K
| [] := []
| (x :: xl) := (-x) :: list.neg'' xl

lemma neg_cons : list.neg K (x :: xl) = (-x) :: list.neg K xl := rfl

lemma neg_nil_nil : list.neg K nil = nil := rfl

lemma len_succ : ∀ a : α, ∀ al : list α, length (a :: al) = length al + 1 := by intros; refl

@[simp] theorem list.len_neg : length (list.neg K xl) = length xl := 
begin
induction xl,
{
  rw neg_nil_nil
},
{
  have t : list.neg K (xl_hd :: xl_tl) = (-xl_hd :: list.neg K xl_tl) := rfl,
  simp only [t, len_succ, xl_ih],
},
end



lemma field_zero_sep : ∀ n : ℕ, n ≠ 0 → list.field_zero K n = 0 :: list.field_zero K (n - 1) :=
begin
intros n h,
induction n with n',
{contradiction},
{refl}
end

-- TODO: clean up this lemma
lemma list.add_zero : ∀ x : list K, x + (list.field_zero K (length x - 1)) = x :=
begin
intro x,
induction x,
{refl},
{
  have tl_len : length (x_hd :: x_tl) - 1 = length x_tl := rfl,
  rw tl_len,
  induction x_tl,
  {
    rw len_nil,
    have field_zero_zero : list.field_zero K 0 = [0] := rfl,
    rw field_zero_zero,
    have add_list : [x_hd] + [0] = [x_hd + 0] := rfl,
    rw [add_list, add_zero],
  },
  {
    have zero_tl : list.field_zero K (length (x_tl_hd :: x_tl_tl)) = 0 :: list.field_zero K (length (x_tl_hd :: x_tl_tl) - 1) :=
      begin
      have len_x : length (x_tl_hd :: x_tl_tl) ≠ 0 :=
        begin
        intro h,
        have len_x' : length (x_tl_hd :: x_tl_tl) = length x_tl_tl + 1 := rfl,
        contradiction
        end,
      apply field_zero_sep,
      exact len_x
      end,
    rw zero_tl,
    have sep_head : x_hd :: (x_tl_hd :: x_tl_tl) + 0 :: list.field_zero K (length (x_tl_hd :: x_tl_tl) - 1) =
      (x_hd + 0) :: ((x_tl_hd :: x_tl_tl) + list.field_zero K (length (x_tl_hd :: x_tl_tl) - 1)) := rfl,
    rw sep_head,
    have head_add : x_hd + 0 = x_hd := by simp,
    rw head_add,
    rw x_ih
  }
}
end

lemma list.add_comm : ∀ x y : list K, x + y = y + x :=
begin
intros x y,
induction x,
{
  have nil_y : nil + y = nil := rfl,
  rw nil_y,
  induction y,
  {refl},
  {refl}
},
{
  induction y,
  {refl},
  {
    have sep_head_xy : (x_hd :: x_tl) + (y_hd :: y_tl) = (x_hd + y_hd) :: (x_tl + y_tl) := rfl,
    rw sep_head_xy,
    have sep_head_yx : (y_hd :: y_tl) + (x_hd :: x_tl) = (y_hd + x_hd) :: (y_tl + x_tl) := rfl,
    rw sep_head_yx,
    have hd_comm : x_hd + y_hd = y_hd + x_hd := by apply add_comm,
    rw hd_comm,
    have tl_comm : x_tl + y_tl = y_tl + x_tl := sorry,
      -- begin
      -- induction x_tl,
      -- {
      --   have nil_y : nil + y_tl = nil := rfl,
      --   rw nil_y,
      --   induction y_tl,
      --   {refl},
      --   {refl}
      -- },
      -- {
      --   induction y_tl,
      --   {refl},
      --   {
      --   have sep_head_xty : x_tl_hd :: x_tl_tl + y_tl_hd :: y_tl_tl = (x_tl_hd + y_tl_hd) :: (x_tl_tl + y_tl_tl) := rfl,
      --   rw sep_head_xty,
      --   have sep_head_yxt : y_tl_hd :: y_tl_tl + x_tl_hd :: x_tl_tl = (y_tl_hd + x_tl_hd) :: (y_tl_tl + x_tl_tl) := rfl,
      --   rw sep_head_yxt,
      --   have tl_hd_comm : x_tl_hd + y_tl_hd = y_tl_hd + x_tl_hd := by apply add_comm,
      --   rw tl_hd_comm,
      --   have tl_tl_comm : x_tl_tl + y_tl_tl = y_tl_tl + x_tl_tl := sorry,
      --   rw tl_tl_comm
      --   }
      -- }
      -- end,
    rw tl_comm
  }
}
end