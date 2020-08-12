import .....math.affine.real_affine_space
import ..metrology.dimension 

structure classicalTime : Type :=
mk :: (name : ℕ) -- name serves as unique ID for a given geometric space

noncomputable def classicalTimeAlgebra : classicalTime → Algebra
| (classicalTime.mk n) := Algebra.affine_space (to_affine 1)

-- Kevin: add has_to_algebra typeclass

