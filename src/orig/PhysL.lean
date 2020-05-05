/-
SCALAR_EXPR := (SCALAR_EXPR) | SCALAR_EXPR + SCALAR_EXPR | SCALAR_EXPR * SCALAR_EXPR | SCALAR_VAR | SCALAR_LITERAL
-/
namespace peirce
def scalar := ℕ

structure scalar_var : Type :=
mk :: (index : ℕ)

def scalar_interp := scalar_var → scalar

def init_scalar_interp := λ (s : scalar_var), 0

inductive scalar_expression : Type 
| scalar_lit : ℕ → scalar_expression
| scalar_paren : scalar_expression → scalar_expression
| scalar_mul : scalar_expression → scalar_expression → scalar_expression
| scalar_add : scalar_expression → scalar_expression → scalar_expression
| scalar_var : scalar_var → scalar_expression

open scalar_expression

def scalar_eval : scalar_expression → scalar_interp → scalar
| (scalar_lit n) i :=  n
| (scalar_paren e) i := scalar_eval e i
| (scalar_mul e1 e2) i := nat.mul (scalar_eval e1 i) (scalar_eval e2 i)
| (scalar_add e1 e2) i := nat.add (scalar_eval e1 i) (scalar_eval e2 i)
| (scalar_expression.scalar_var v) i := i v

/-
    VEC_EXPR := (VEC_EXPR) | VEC_EXPR + VEC_EXPR | VEC_EXPR * SCALAR_EXPR | VEC_VAR | VEC_LITERAL
-/

structure vector_space : Type :=
mk :: (index : ℕ)

structure vector_variable (sp : vector_space) : Type :=
mk :: (index : ℕ)

structure vector (sp : vector_space) : Type :=
mk :: (x y z : ℕ)

def vector_interp (sp : vector_space) := vector_variable sp → vector sp

inductive vector_vector_space_transformation : Type

inductive vector_vector_space_transformation_expressions : Type

inductive vector_expression (sp: vector_space) : Type 
| vector_literal : @vector sp → vector_expression
| scalar_vector_mul : scalar_expression → vector_expression → vector_expression
| vector_paren : vector_expression → vector_expression 
| vector_add : vector_expression → vector_expression → vector_expression
| vector_var : vector_variable sp → vector_expression

open vector_expression

def vector_eval (sp : vector_space) : vector_expression sp → vector_interp sp → scalar_interp → vector sp
| (vector_literal v) i_v i_s :=  v
| (scalar_vector_mul s v) i_v i_s :=
        let interp_v := (vector_eval v i_v i_s) in
        let interp_s := scalar_eval s i_s in
        (@vector.mk sp
            (interp_v.x * interp_s)
            (interp_v.y * interp_s)
            (interp_v.z * interp_s)
        )
| (vector_paren v) i_v i_s := vector_eval v i_v i_s
| (vector_add e1 e2) i_v i_s := 
        let interp_v1 := vector_eval e1 i_v i_s in
        let interp_v2 := vector_eval e2 i_v i_s in
        (@vector.mk sp
            (interp_v1.x + interp_v2.x)
            (interp_v1.y + interp_v2.y)
            (interp_v1.z + interp_v2.z)
        )
| (vector_var v) i_v i_s := i_v v

structure transform (inp outp: vector_space): Type

def transform_apply {sp1 sp2 : vector_space} (t : transform sp1 sp2) (inputvec : vector sp1) : 
    vector sp2 := 
        vector.mk sp2 0 0 0
def transform_compose {sp1 sp2 sp3: vector_space} (t1 : transform sp1 sp2) (t2 : transform sp2 sp3) : 
    transform sp1 sp3 := 
        transform.mk sp1 sp3
end peirce