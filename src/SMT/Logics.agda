module SMT.Logics where

open import Algebra
open import Algebra.Structures
open import Data.Empty using (⊥-elim)
open import Data.Nat as Nat using (ℕ)
import Data.Nat.Induction as WfNat
open import Data.Product
open import Data.Sum
open import Function using (_on_)
open import Function.Equivalence using (equivalence)
open import Induction
open import Induction.WellFounded
open import Relation.Nullary
open import Relation.Nullary.Sum
open import Relation.Nullary.Decidable as Dec
open import Relation.Binary
open import Relation.Binary.PropositionalEquality using (_≡_; _≢_; refl)
open import Relation.Binary.Construct.Closure.Transitive using (Plus′; [_]; _∷_)

-- |Logics supported by SMT-LIB.
--
--  Logics and descriptions taken from <http://smtlib.cs.uiowa.edu/logics.shtml>.
--  Order is a linearisation of <http://smtlib.cs.uiowa.edu/Logics/logics.png>.
--
data Logic : Set where

  QF-AX     : Logic
  -- ^ Closed quantifier-free formulas over the theory of arrays with
  --   extensionality.
  QF-IDL    : Logic
  -- ^ Difference Logic over the integers. In essence, Boolean combinations of
  --   inequations of the form x - y < b where x and y are integer variables and
  --   b is an integer constant.
  QF-LIA    : Logic
  -- ^ Unquantified linear integer arithmetic. In essence, Boolean combinations
  --   of inequations between linear polynomials over integer variables.
  QF-NIA    : Logic
  -- ^ Quantifier-free integer arithmetic.
  NIA       : Logic
  -- ^ Non-linear integer arithmetic.
  UFNIA     : Logic
  -- ^ Non-linear integer arithmetic with uninterpreted sort and function symbols.
  AUFNIRA   : Logic
  -- ^ Closed formulas with free function and predicate symbols over a theory of
  --   arrays of arrays of integer index and real value.
  LIA       : Logic
  -- ^ Closed linear formulas over linear integer arithmetic.
  AUFLIRA   : Logic
  -- ^ Closed linear formulas with free sort and function symbols over one- and
  --   two-dimentional arrays of integer index and real value.
  ALIA      : Logic
  -- ^ Closed linear formulas over linear integer arithmetic and integer arrays.
  AUFLIA    : Logic
  -- ^ Closed formulas over the theory of linear integer arithmetic and arrays
  --   extended with free sort and function symbols but restricted to arrays
  --   with integer indices and values.
  QF-ALIA   : Logic
  -- ^ Unquantifier linear integer arithmetic and with one- and two-dimensional
  --   arrays of integers.
  QF-AUFLIA : Logic
  -- ^ Closed quantifier-free linear formulas over the theory of integer arrays
  --   extended with free sort and function symbols.
  QF-UFIDL  : Logic
  -- ^ Difference Logic over the integers (in essence) but with uninterpreted
  --   sort and function symbols.
  QF-UFLIA  : Logic
  -- ^ Unquantified linear integer arithmetic with uninterpreted sort and
  --   function symbols.
  QF-UFNIA  : Logic
  -- ^ Unquantified non-linear integer arithmetic with uninterpreted sort and
  --   function symbols.
  QF-UF     : Logic
  -- ^ Unquantified formulas built over a signature of uninterpreted (i.e.,
  --   free) sort and function symbols.
  QF-UFLRA  : Logic
  -- ^ Unquantified linear real arithmetic with uninterpreted sort and function
  --   symbols.
  UFLRA     : Logic
  -- ^ Linear real arithmetic with uninterpreted sort and function symbols.
  QF-UFNRA  : Logic
  -- ^ Unquantified non-linear real arithmetic with uninterpreted sort and
  --   function symbols.
  QF-UFBV   : Logic
  -- ^ Unquantified formulas over bitvectors with uninterpreted sort function
  --   and symbols.
  QF-AUFBV  : Logic
  -- ^ Closed quantifier-free formulas over the theory of bitvectors and
  --   bitvector arrays extended with free sort and function symbols.
  QF-BV     : Logic
  -- ^ Closed quantifier-free formulas over the theory of fixed-size bitvectors.
  QF-ABV    : Logic
  -- ^ Closed quantifier-free formulas over the theory of bitvectors and
  --   bitvector arrays.
  QF-RDL    : Logic
  -- ^ Difference Logic over the reals. In essence, Boolean combinations of
  --   inequations of the form x - y < b where x and y are real variables and b is
  --   a rational constant.
  QF-LRA    : Logic
  -- ^ Unquantified linear real arithmetic. In essence, Boolean combinations of
  --   inequations between linear polynomials over real variables.
  NRA       : Logic
  -- ^ Non-linear real arithmetic.
  LRA       : Logic
  -- ^ Closed linear formulas in linear real arithmetic.
  QF-NRA    : Logic
  -- ^ Quantifier-free real arithmetic.

private
  variable
    l l₁ l₂ l₃ : Logic


infix 4 _⇾_

-- |The ⇾-relation encodes the edges of the inclusion graph for SMT-LIB 2.
data _⇾_ : (l₁ l₂ : Logic) → Set where
  QF-IDL⇾QF-LIA      : QF-IDL     ⇾ QF-LIA
  QF-LIA⇾QF-NIA      : QF-LIA     ⇾ QF-NIA
  QF-NIA⇾NIA         : QF-NIA     ⇾ NIA
  NIA⇾UFNIA          : NIA        ⇾ UFNIA
  UFNIA⇾AUFNIRA      : UFNIA      ⇾ AUFNIRA
  QF-LIA⇾LIA         : QF-LIA     ⇾ LIA
  LIA⇾NIA            : LIA        ⇾ NIA
  LIA⇾AUFLIRA        : LIA        ⇾ AUFLIRA
  AUFLIRA⇾AUFNIRA    : AUFLIRA    ⇾ AUFNIRA
  LIA⇾ALIA           : LIA        ⇾ ALIA
  ALIA⇾AUFLIA        : ALIA       ⇾ AUFLIA
  QF-LIA⇾QF-ALIA     : QF-LIA     ⇾ QF-ALIA
  QF-ALIA⇾ALIA       : QF-ALIA    ⇾ ALIA
  QF-ALIA⇾QF-AUFLIA  : QF-ALIA    ⇾ QF-AUFLIA
  QF-AUFLIA⇾AUFLIA   : QF-AUFLIA  ⇾ AUFLIA
  QF-LIA⇾QF-UFLIA    : QF-LIA     ⇾ QF-UFLIA
  QF-UFLIA⇾QF-AUFLIA : QF-UFLIA   ⇾ QF-AUFLIA
  QF-UFLIA⇾QF-UFNIA  : QF-UFLIA   ⇾ QF-UFNIA
  QF-UFNIA⇾UFNIA     : QF-UFNIA   ⇾ UFNIA
  QF-IDL⇾QF-UFIDL    : QF-IDL     ⇾ QF-UFIDL
  QF-UFIDL⇾QF-UFLIA  : QF-UFIDL   ⇾ QF-UFLIA
  QF-UF⇾QF-UFIDL     : QF-UF      ⇾ QF-UFIDL
  QF-UF⇾QF-UFLRA     : QF-UF      ⇾ QF-UFLRA
  QF-UFLRA⇾UFLRA     : QF-UFLRA   ⇾ UFLRA
  UFLRA⇾AUFLIRA      : UFLRA      ⇾ AUFLIRA
  QF-UFLRA⇾QF-UFNRA  : QF-UFLRA   ⇾ QF-UFNRA
  QF-UFNRA⇾AUFNIRA   : QF-UFNRA   ⇾ AUFNIRA
  QF-UF⇾QF-UFBV      : QF-UF      ⇾ QF-UFBV
  QF-UFBV⇾QF-AUFBV   : QF-UFBV    ⇾ QF-AUFBV
  QF-BV⇾QF-UFBV      : QF-BV      ⇾ QF-UFBV
  QF-BV⇾QF-ABV       : QF-BV      ⇾ QF-ABV
  QF-ABV⇾QF-AUFBV    : QF-ABV     ⇾ QF-AUFBV
  QF-RDL⇾QF-LRA      : QF-RDL     ⇾ QF-LRA
  QF-LRA⇾QF-UFNRA    : QF-LRA     ⇾ QF-UFNRA
  QF-LRA⇾LRA         : QF-LRA     ⇾ LRA
  LRA⇾UFLRA          : LRA        ⇾ UFLRA
  LRA⇾NRA            : LRA        ⇾ NRA
  NRA⇾AUFNIRA        : NRA        ⇾ AUFNIRA
  QF-LRA⇾QF-NRA      : QF-LRA     ⇾ QF-NRA
  QF-NRA⇾QF-UFNRA    : QF-NRA     ⇾ QF-UFNRA
  QF-NRA⇾NRA         : QF-NRA     ⇾ NRA

-- |The ⇾-relation is irreflexive.
⇾-irreflexive : Irreflexive _≡_ _⇾_
⇾-irreflexive refl ()

-- |The ⇾-relation is asymmetric.
⇾-asymmetric : Asymmetric _⇾_
⇾-asymmetric QF-IDL⇾QF-LIA ()
⇾-asymmetric QF-LIA⇾QF-NIA ()
⇾-asymmetric NIA⇾UFNIA ()
⇾-asymmetric UFNIA⇾AUFNIRA ()
⇾-asymmetric QF-LIA⇾LIA ()
⇾-asymmetric LIA⇾AUFLIRA ()
⇾-asymmetric AUFLIRA⇾AUFNIRA ()
⇾-asymmetric LIA⇾ALIA ()
⇾-asymmetric ALIA⇾AUFLIA ()
⇾-asymmetric QF-LIA⇾QF-ALIA ()
⇾-asymmetric QF-ALIA⇾QF-AUFLIA ()
⇾-asymmetric QF-AUFLIA⇾AUFLIA ()
⇾-asymmetric QF-LIA⇾QF-UFLIA ()
⇾-asymmetric QF-UFLIA⇾QF-AUFLIA ()
⇾-asymmetric QF-UFLIA⇾QF-UFNIA ()
⇾-asymmetric QF-UFNIA⇾UFNIA ()
⇾-asymmetric QF-IDL⇾QF-UFIDL ()
⇾-asymmetric QF-UFIDL⇾QF-UFLIA ()
⇾-asymmetric QF-UF⇾QF-UFIDL ()
⇾-asymmetric QF-UF⇾QF-UFLRA ()
⇾-asymmetric QF-UFLRA⇾UFLRA ()
⇾-asymmetric UFLRA⇾AUFLIRA ()
⇾-asymmetric QF-UFLRA⇾QF-UFNRA ()
⇾-asymmetric QF-UFNRA⇾AUFNIRA ()
⇾-asymmetric QF-UF⇾QF-UFBV ()
⇾-asymmetric QF-UFBV⇾QF-AUFBV ()
⇾-asymmetric QF-BV⇾QF-UFBV ()
⇾-asymmetric QF-BV⇾QF-ABV ()
⇾-asymmetric QF-ABV⇾QF-AUFBV ()
⇾-asymmetric QF-RDL⇾QF-LRA ()
⇾-asymmetric QF-LRA⇾QF-UFNRA ()
⇾-asymmetric QF-LRA⇾LRA ()
⇾-asymmetric LRA⇾UFLRA ()
⇾-asymmetric LRA⇾NRA ()
⇾-asymmetric NRA⇾AUFNIRA ()
⇾-asymmetric QF-LRA⇾QF-NRA ()
⇾-asymmetric QF-NRA⇾NRA ()

-- |The transitive closure of the ⇾-relation.
_⇾⁺_ : Rel Logic _
_⇾⁺_ = Plus′ _⇾_

-- |The depth of a logic is the logiest path from any of the depth 0 logics.
--
--  NOTE: We are defining depth to help us induce a proof that _⇾_ and its
--        transitive closure _<_ are well-founded relations.
--
depth : Logic → ℕ
depth QF-AX     = 0
depth QF-IDL    = 0
depth QF-LIA    = 1
depth QF-NIA    = 2
depth NIA       = 3
depth UFNIA     = 4
depth AUFNIRA   = 5
depth LIA       = 2
depth AUFLIRA   = 4
depth ALIA      = 3
depth AUFLIA    = 4
depth QF-ALIA   = 2
depth QF-AUFLIA = 3
depth QF-UFIDL  = 1
depth QF-UFLIA  = 2
depth QF-UFNIA  = 3
depth QF-UF     = 0
depth QF-UFLRA  = 1
depth UFLRA     = 3
depth QF-UFNRA  = 3
depth QF-UFBV   = 1
depth QF-AUFBV  = 2
depth QF-BV     = 0
depth QF-ABV    = 1
depth QF-RDL    = 0
depth QF-LRA    = 1
depth NRA       = 3
depth LRA       = 2
depth QF-NRA    = 2

private
  auto : ∀ {n₁ n₂} {p : True (n₁ Nat.<? n₂)} → n₁ Nat.< n₂
  auto {p = p} = toWitness p

-- |The ⇾-relation respects depth.
⇾-depth : l₁ ⇾ l₂ → depth l₁ Nat.< depth l₂
⇾-depth QF-IDL⇾QF-LIA      = auto
⇾-depth QF-LIA⇾QF-NIA      = auto
⇾-depth QF-NIA⇾NIA         = auto
⇾-depth NIA⇾UFNIA          = auto
⇾-depth UFNIA⇾AUFNIRA      = auto
⇾-depth QF-LIA⇾LIA         = auto
⇾-depth LIA⇾NIA            = auto
⇾-depth LIA⇾AUFLIRA        = auto
⇾-depth AUFLIRA⇾AUFNIRA    = auto
⇾-depth LIA⇾ALIA           = auto
⇾-depth ALIA⇾AUFLIA        = auto
⇾-depth QF-LIA⇾QF-ALIA     = auto
⇾-depth QF-ALIA⇾ALIA       = auto
⇾-depth QF-ALIA⇾QF-AUFLIA  = auto
⇾-depth QF-AUFLIA⇾AUFLIA   = auto
⇾-depth QF-LIA⇾QF-UFLIA    = auto
⇾-depth QF-UFLIA⇾QF-AUFLIA = auto
⇾-depth QF-UFLIA⇾QF-UFNIA  = auto
⇾-depth QF-UFNIA⇾UFNIA     = auto
⇾-depth QF-IDL⇾QF-UFIDL    = auto
⇾-depth QF-UFIDL⇾QF-UFLIA  = auto
⇾-depth QF-UF⇾QF-UFIDL     = auto
⇾-depth QF-UF⇾QF-UFLRA     = auto
⇾-depth QF-UFLRA⇾UFLRA     = auto
⇾-depth UFLRA⇾AUFLIRA      = auto
⇾-depth QF-UFLRA⇾QF-UFNRA  = auto
⇾-depth QF-UFNRA⇾AUFNIRA   = auto
⇾-depth QF-UF⇾QF-UFBV      = auto
⇾-depth QF-UFBV⇾QF-AUFBV   = auto
⇾-depth QF-BV⇾QF-UFBV      = auto
⇾-depth QF-BV⇾QF-ABV       = auto
⇾-depth QF-ABV⇾QF-AUFBV    = auto
⇾-depth QF-RDL⇾QF-LRA      = auto
⇾-depth QF-LRA⇾QF-UFNRA    = auto
⇾-depth QF-LRA⇾LRA         = auto
⇾-depth LRA⇾UFLRA          = auto
⇾-depth LRA⇾NRA            = auto
⇾-depth NRA⇾AUFNIRA        = auto
⇾-depth QF-LRA⇾QF-NRA      = auto
⇾-depth QF-NRA⇾QF-UFNRA    = auto
⇾-depth QF-NRA⇾NRA         = auto

private
  module <-depth⇒< = InverseImage {_<_ = Nat._<_} depth
  module ⇾⇒<-depth = Subrelation {_<₁_ = _⇾_} {_<₂_ = Nat._<_ on depth} ⇾-depth
  module ⊂⇒⇾ = TransitiveClosure _⇾_

open ⊂⇒⇾ renaming (_<⁺_ to _⊂_) using ([_]; trans)

-- |The ⇾-relation is well-founded via depth.
⇾-wellFounded : WellFounded _⇾_
⇾-wellFounded = ⇾⇒<-depth.wellFounded (<-depth⇒<.wellFounded WfNat.<-wellFounded)

-- |The ⇾⁺-relation is a subrelation of the ⊂-relation.
⇾⁺-⊂ : l₁ ⇾⁺ l₃ → l₁ ⊂ l₃
⇾⁺-⊂ [ l₁⇾l₃ ] = [ l₁⇾l₃ ]
⇾⁺-⊂ (l₁⇾l₂ ∷ l₂⇾⁺l₃) = trans [ l₁⇾l₂ ] (⇾⁺-⊂ l₂⇾⁺l₃)

private
  module ⇾⁺⇒⊂ = Subrelation {_<₁_ = _⇾⁺_} {_<₂_ = _⊂_} ⇾⁺-⊂

-- |The ⇾⁺-relation is well-founded.
⇾⁺-wellFounded : WellFounded _⇾⁺_
⇾⁺-wellFounded = ⇾⁺⇒⊂.wellFounded (⊂⇒⇾.wellFounded ⇾-wellFounded)

-- |The ⇾-relation for logics is decidable.
_⇾?_ : (l₁ l₂ : Logic) → Dec (l₁ ⇾ l₂)
QF-AX     ⇾? QF-AX     = no (λ ())
QF-AX     ⇾? QF-IDL    = no (λ ())
QF-AX     ⇾? QF-LIA    = no (λ ())
QF-AX     ⇾? QF-NIA    = no (λ ())
QF-AX     ⇾? NIA       = no (λ ())
QF-AX     ⇾? UFNIA     = no (λ ())
QF-AX     ⇾? AUFNIRA   = no (λ ())
QF-AX     ⇾? LIA       = no (λ ())
QF-AX     ⇾? AUFLIRA   = no (λ ())
QF-AX     ⇾? ALIA      = no (λ ())
QF-AX     ⇾? AUFLIA    = no (λ ())
QF-AX     ⇾? QF-ALIA   = no (λ ())
QF-AX     ⇾? QF-AUFLIA = no (λ ())
QF-AX     ⇾? QF-UFIDL  = no (λ ())
QF-AX     ⇾? QF-UFLIA  = no (λ ())
QF-AX     ⇾? QF-UFNIA  = no (λ ())
QF-AX     ⇾? QF-UF     = no (λ ())
QF-AX     ⇾? QF-UFLRA  = no (λ ())
QF-AX     ⇾? UFLRA     = no (λ ())
QF-AX     ⇾? QF-UFNRA  = no (λ ())
QF-AX     ⇾? QF-UFBV   = no (λ ())
QF-AX     ⇾? QF-AUFBV  = no (λ ())
QF-AX     ⇾? QF-BV     = no (λ ())
QF-AX     ⇾? QF-ABV    = no (λ ())
QF-AX     ⇾? QF-RDL    = no (λ ())
QF-AX     ⇾? QF-LRA    = no (λ ())
QF-AX     ⇾? NRA       = no (λ ())
QF-AX     ⇾? LRA       = no (λ ())
QF-AX     ⇾? QF-NRA    = no (λ ())
QF-IDL    ⇾? QF-AX     = no (λ ())
QF-IDL    ⇾? QF-IDL    = no (λ ())
QF-IDL    ⇾? QF-LIA    = yes QF-IDL⇾QF-LIA
QF-IDL    ⇾? QF-NIA    = no (λ ())
QF-IDL    ⇾? NIA       = no (λ ())
QF-IDL    ⇾? UFNIA     = no (λ ())
QF-IDL    ⇾? AUFNIRA   = no (λ ())
QF-IDL    ⇾? LIA       = no (λ ())
QF-IDL    ⇾? AUFLIRA   = no (λ ())
QF-IDL    ⇾? ALIA      = no (λ ())
QF-IDL    ⇾? AUFLIA    = no (λ ())
QF-IDL    ⇾? QF-ALIA   = no (λ ())
QF-IDL    ⇾? QF-AUFLIA = no (λ ())
QF-IDL    ⇾? QF-UFIDL  = yes QF-IDL⇾QF-UFIDL
QF-IDL    ⇾? QF-UFLIA  = no (λ ())
QF-IDL    ⇾? QF-UFNIA  = no (λ ())
QF-IDL    ⇾? QF-UF     = no (λ ())
QF-IDL    ⇾? QF-UFLRA  = no (λ ())
QF-IDL    ⇾? UFLRA     = no (λ ())
QF-IDL    ⇾? QF-UFNRA  = no (λ ())
QF-IDL    ⇾? QF-UFBV   = no (λ ())
QF-IDL    ⇾? QF-AUFBV  = no (λ ())
QF-IDL    ⇾? QF-BV     = no (λ ())
QF-IDL    ⇾? QF-ABV    = no (λ ())
QF-IDL    ⇾? QF-RDL    = no (λ ())
QF-IDL    ⇾? QF-LRA    = no (λ ())
QF-IDL    ⇾? NRA       = no (λ ())
QF-IDL    ⇾? LRA       = no (λ ())
QF-IDL    ⇾? QF-NRA    = no (λ ())
QF-LIA    ⇾? QF-AX     = no (λ ())
QF-LIA    ⇾? QF-IDL    = no (λ ())
QF-LIA    ⇾? QF-LIA    = no (λ ())
QF-LIA    ⇾? QF-NIA    = yes QF-LIA⇾QF-NIA
QF-LIA    ⇾? NIA       = no (λ ())
QF-LIA    ⇾? UFNIA     = no (λ ())
QF-LIA    ⇾? AUFNIRA   = no (λ ())
QF-LIA    ⇾? LIA       = yes QF-LIA⇾LIA
QF-LIA    ⇾? AUFLIRA   = no (λ ())
QF-LIA    ⇾? ALIA      = no (λ ())
QF-LIA    ⇾? AUFLIA    = no (λ ())
QF-LIA    ⇾? QF-ALIA   = yes QF-LIA⇾QF-ALIA
QF-LIA    ⇾? QF-AUFLIA = no (λ ())
QF-LIA    ⇾? QF-UFIDL  = no (λ ())
QF-LIA    ⇾? QF-UFLIA  = yes QF-LIA⇾QF-UFLIA
QF-LIA    ⇾? QF-UFNIA  = no (λ ())
QF-LIA    ⇾? QF-UF     = no (λ ())
QF-LIA    ⇾? QF-UFLRA  = no (λ ())
QF-LIA    ⇾? UFLRA     = no (λ ())
QF-LIA    ⇾? QF-UFNRA  = no (λ ())
QF-LIA    ⇾? QF-UFBV   = no (λ ())
QF-LIA    ⇾? QF-AUFBV  = no (λ ())
QF-LIA    ⇾? QF-BV     = no (λ ())
QF-LIA    ⇾? QF-ABV    = no (λ ())
QF-LIA    ⇾? QF-RDL    = no (λ ())
QF-LIA    ⇾? QF-LRA    = no (λ ())
QF-LIA    ⇾? NRA       = no (λ ())
QF-LIA    ⇾? LRA       = no (λ ())
QF-LIA    ⇾? QF-NRA    = no (λ ())
QF-NIA    ⇾? QF-AX     = no (λ ())
QF-NIA    ⇾? QF-IDL    = no (λ ())
QF-NIA    ⇾? QF-LIA    = no (λ ())
QF-NIA    ⇾? QF-NIA    = no (λ ())
QF-NIA    ⇾? NIA       = yes QF-NIA⇾NIA
QF-NIA    ⇾? UFNIA     = no (λ ())
QF-NIA    ⇾? AUFNIRA   = no (λ ())
QF-NIA    ⇾? LIA       = no (λ ())
QF-NIA    ⇾? AUFLIRA   = no (λ ())
QF-NIA    ⇾? ALIA      = no (λ ())
QF-NIA    ⇾? AUFLIA    = no (λ ())
QF-NIA    ⇾? QF-ALIA   = no (λ ())
QF-NIA    ⇾? QF-AUFLIA = no (λ ())
QF-NIA    ⇾? QF-UFIDL  = no (λ ())
QF-NIA    ⇾? QF-UFLIA  = no (λ ())
QF-NIA    ⇾? QF-UFNIA  = no (λ ())
QF-NIA    ⇾? QF-UF     = no (λ ())
QF-NIA    ⇾? QF-UFLRA  = no (λ ())
QF-NIA    ⇾? UFLRA     = no (λ ())
QF-NIA    ⇾? QF-UFNRA  = no (λ ())
QF-NIA    ⇾? QF-UFBV   = no (λ ())
QF-NIA    ⇾? QF-AUFBV  = no (λ ())
QF-NIA    ⇾? QF-BV     = no (λ ())
QF-NIA    ⇾? QF-ABV    = no (λ ())
QF-NIA    ⇾? QF-RDL    = no (λ ())
QF-NIA    ⇾? QF-LRA    = no (λ ())
QF-NIA    ⇾? NRA       = no (λ ())
QF-NIA    ⇾? LRA       = no (λ ())
QF-NIA    ⇾? QF-NRA    = no (λ ())
NIA       ⇾? QF-AX     = no (λ ())
NIA       ⇾? QF-IDL    = no (λ ())
NIA       ⇾? QF-LIA    = no (λ ())
NIA       ⇾? QF-NIA    = no (λ ())
NIA       ⇾? NIA       = no (λ ())
NIA       ⇾? UFNIA     = yes NIA⇾UFNIA
NIA       ⇾? AUFNIRA   = no (λ ())
NIA       ⇾? LIA       = no (λ ())
NIA       ⇾? AUFLIRA   = no (λ ())
NIA       ⇾? ALIA      = no (λ ())
NIA       ⇾? AUFLIA    = no (λ ())
NIA       ⇾? QF-ALIA   = no (λ ())
NIA       ⇾? QF-AUFLIA = no (λ ())
NIA       ⇾? QF-UFIDL  = no (λ ())
NIA       ⇾? QF-UFLIA  = no (λ ())
NIA       ⇾? QF-UFNIA  = no (λ ())
NIA       ⇾? QF-UF     = no (λ ())
NIA       ⇾? QF-UFLRA  = no (λ ())
NIA       ⇾? UFLRA     = no (λ ())
NIA       ⇾? QF-UFNRA  = no (λ ())
NIA       ⇾? QF-UFBV   = no (λ ())
NIA       ⇾? QF-AUFBV  = no (λ ())
NIA       ⇾? QF-BV     = no (λ ())
NIA       ⇾? QF-ABV    = no (λ ())
NIA       ⇾? QF-RDL    = no (λ ())
NIA       ⇾? QF-LRA    = no (λ ())
NIA       ⇾? NRA       = no (λ ())
NIA       ⇾? LRA       = no (λ ())
NIA       ⇾? QF-NRA    = no (λ ())
UFNIA     ⇾? QF-AX     = no (λ ())
UFNIA     ⇾? QF-IDL    = no (λ ())
UFNIA     ⇾? QF-LIA    = no (λ ())
UFNIA     ⇾? QF-NIA    = no (λ ())
UFNIA     ⇾? NIA       = no (λ ())
UFNIA     ⇾? UFNIA     = no (λ ())
UFNIA     ⇾? AUFNIRA   = yes UFNIA⇾AUFNIRA
UFNIA     ⇾? LIA       = no (λ ())
UFNIA     ⇾? AUFLIRA   = no (λ ())
UFNIA     ⇾? ALIA      = no (λ ())
UFNIA     ⇾? AUFLIA    = no (λ ())
UFNIA     ⇾? QF-ALIA   = no (λ ())
UFNIA     ⇾? QF-AUFLIA = no (λ ())
UFNIA     ⇾? QF-UFIDL  = no (λ ())
UFNIA     ⇾? QF-UFLIA  = no (λ ())
UFNIA     ⇾? QF-UFNIA  = no (λ ())
UFNIA     ⇾? QF-UF     = no (λ ())
UFNIA     ⇾? QF-UFLRA  = no (λ ())
UFNIA     ⇾? UFLRA     = no (λ ())
UFNIA     ⇾? QF-UFNRA  = no (λ ())
UFNIA     ⇾? QF-UFBV   = no (λ ())
UFNIA     ⇾? QF-AUFBV  = no (λ ())
UFNIA     ⇾? QF-BV     = no (λ ())
UFNIA     ⇾? QF-ABV    = no (λ ())
UFNIA     ⇾? QF-RDL    = no (λ ())
UFNIA     ⇾? QF-LRA    = no (λ ())
UFNIA     ⇾? NRA       = no (λ ())
UFNIA     ⇾? LRA       = no (λ ())
UFNIA     ⇾? QF-NRA    = no (λ ())
AUFNIRA   ⇾? QF-AX     = no (λ ())
AUFNIRA   ⇾? QF-IDL    = no (λ ())
AUFNIRA   ⇾? QF-LIA    = no (λ ())
AUFNIRA   ⇾? QF-NIA    = no (λ ())
AUFNIRA   ⇾? NIA       = no (λ ())
AUFNIRA   ⇾? UFNIA     = no (λ ())
AUFNIRA   ⇾? AUFNIRA   = no (λ ())
AUFNIRA   ⇾? LIA       = no (λ ())
AUFNIRA   ⇾? AUFLIRA   = no (λ ())
AUFNIRA   ⇾? ALIA      = no (λ ())
AUFNIRA   ⇾? AUFLIA    = no (λ ())
AUFNIRA   ⇾? QF-ALIA   = no (λ ())
AUFNIRA   ⇾? QF-AUFLIA = no (λ ())
AUFNIRA   ⇾? QF-UFIDL  = no (λ ())
AUFNIRA   ⇾? QF-UFLIA  = no (λ ())
AUFNIRA   ⇾? QF-UFNIA  = no (λ ())
AUFNIRA   ⇾? QF-UF     = no (λ ())
AUFNIRA   ⇾? QF-UFLRA  = no (λ ())
AUFNIRA   ⇾? UFLRA     = no (λ ())
AUFNIRA   ⇾? QF-UFNRA  = no (λ ())
AUFNIRA   ⇾? QF-UFBV   = no (λ ())
AUFNIRA   ⇾? QF-AUFBV  = no (λ ())
AUFNIRA   ⇾? QF-BV     = no (λ ())
AUFNIRA   ⇾? QF-ABV    = no (λ ())
AUFNIRA   ⇾? QF-RDL    = no (λ ())
AUFNIRA   ⇾? QF-LRA    = no (λ ())
AUFNIRA   ⇾? NRA       = no (λ ())
AUFNIRA   ⇾? LRA       = no (λ ())
AUFNIRA   ⇾? QF-NRA    = no (λ ())
LIA       ⇾? QF-AX     = no (λ ())
LIA       ⇾? QF-IDL    = no (λ ())
LIA       ⇾? QF-LIA    = no (λ ())
LIA       ⇾? QF-NIA    = no (λ ())
LIA       ⇾? NIA       = yes LIA⇾NIA
LIA       ⇾? UFNIA     = no (λ ())
LIA       ⇾? AUFNIRA   = no (λ ())
LIA       ⇾? LIA       = no (λ ())
LIA       ⇾? AUFLIRA   = yes LIA⇾AUFLIRA
LIA       ⇾? ALIA      = yes LIA⇾ALIA
LIA       ⇾? AUFLIA    = no (λ ())
LIA       ⇾? QF-ALIA   = no (λ ())
LIA       ⇾? QF-AUFLIA = no (λ ())
LIA       ⇾? QF-UFIDL  = no (λ ())
LIA       ⇾? QF-UFLIA  = no (λ ())
LIA       ⇾? QF-UFNIA  = no (λ ())
LIA       ⇾? QF-UF     = no (λ ())
LIA       ⇾? QF-UFLRA  = no (λ ())
LIA       ⇾? UFLRA     = no (λ ())
LIA       ⇾? QF-UFNRA  = no (λ ())
LIA       ⇾? QF-UFBV   = no (λ ())
LIA       ⇾? QF-AUFBV  = no (λ ())
LIA       ⇾? QF-BV     = no (λ ())
LIA       ⇾? QF-ABV    = no (λ ())
LIA       ⇾? QF-RDL    = no (λ ())
LIA       ⇾? QF-LRA    = no (λ ())
LIA       ⇾? NRA       = no (λ ())
LIA       ⇾? LRA       = no (λ ())
LIA       ⇾? QF-NRA    = no (λ ())
AUFLIRA   ⇾? QF-AX     = no (λ ())
AUFLIRA   ⇾? QF-IDL    = no (λ ())
AUFLIRA   ⇾? QF-LIA    = no (λ ())
AUFLIRA   ⇾? QF-NIA    = no (λ ())
AUFLIRA   ⇾? NIA       = no (λ ())
AUFLIRA   ⇾? UFNIA     = no (λ ())
AUFLIRA   ⇾? AUFNIRA   = yes AUFLIRA⇾AUFNIRA
AUFLIRA   ⇾? LIA       = no (λ ())
AUFLIRA   ⇾? AUFLIRA   = no (λ ())
AUFLIRA   ⇾? ALIA      = no (λ ())
AUFLIRA   ⇾? AUFLIA    = no (λ ())
AUFLIRA   ⇾? QF-ALIA   = no (λ ())
AUFLIRA   ⇾? QF-AUFLIA = no (λ ())
AUFLIRA   ⇾? QF-UFIDL  = no (λ ())
AUFLIRA   ⇾? QF-UFLIA  = no (λ ())
AUFLIRA   ⇾? QF-UFNIA  = no (λ ())
AUFLIRA   ⇾? QF-UF     = no (λ ())
AUFLIRA   ⇾? QF-UFLRA  = no (λ ())
AUFLIRA   ⇾? UFLRA     = no (λ ())
AUFLIRA   ⇾? QF-UFNRA  = no (λ ())
AUFLIRA   ⇾? QF-UFBV   = no (λ ())
AUFLIRA   ⇾? QF-AUFBV  = no (λ ())
AUFLIRA   ⇾? QF-BV     = no (λ ())
AUFLIRA   ⇾? QF-ABV    = no (λ ())
AUFLIRA   ⇾? QF-RDL    = no (λ ())
AUFLIRA   ⇾? QF-LRA    = no (λ ())
AUFLIRA   ⇾? NRA       = no (λ ())
AUFLIRA   ⇾? LRA       = no (λ ())
AUFLIRA   ⇾? QF-NRA    = no (λ ())
ALIA      ⇾? QF-AX     = no (λ ())
ALIA      ⇾? QF-IDL    = no (λ ())
ALIA      ⇾? QF-LIA    = no (λ ())
ALIA      ⇾? QF-NIA    = no (λ ())
ALIA      ⇾? NIA       = no (λ ())
ALIA      ⇾? UFNIA     = no (λ ())
ALIA      ⇾? AUFNIRA   = no (λ ())
ALIA      ⇾? LIA       = no (λ ())
ALIA      ⇾? AUFLIRA   = no (λ ())
ALIA      ⇾? ALIA      = no (λ ())
ALIA      ⇾? AUFLIA    = yes ALIA⇾AUFLIA
ALIA      ⇾? QF-ALIA   = no (λ ())
ALIA      ⇾? QF-AUFLIA = no (λ ())
ALIA      ⇾? QF-UFIDL  = no (λ ())
ALIA      ⇾? QF-UFLIA  = no (λ ())
ALIA      ⇾? QF-UFNIA  = no (λ ())
ALIA      ⇾? QF-UF     = no (λ ())
ALIA      ⇾? QF-UFLRA  = no (λ ())
ALIA      ⇾? UFLRA     = no (λ ())
ALIA      ⇾? QF-UFNRA  = no (λ ())
ALIA      ⇾? QF-UFBV   = no (λ ())
ALIA      ⇾? QF-AUFBV  = no (λ ())
ALIA      ⇾? QF-BV     = no (λ ())
ALIA      ⇾? QF-ABV    = no (λ ())
ALIA      ⇾? QF-RDL    = no (λ ())
ALIA      ⇾? QF-LRA    = no (λ ())
ALIA      ⇾? NRA       = no (λ ())
ALIA      ⇾? LRA       = no (λ ())
ALIA      ⇾? QF-NRA    = no (λ ())
AUFLIA    ⇾? QF-AX     = no (λ ())
AUFLIA    ⇾? QF-IDL    = no (λ ())
AUFLIA    ⇾? QF-LIA    = no (λ ())
AUFLIA    ⇾? QF-NIA    = no (λ ())
AUFLIA    ⇾? NIA       = no (λ ())
AUFLIA    ⇾? UFNIA     = no (λ ())
AUFLIA    ⇾? AUFNIRA   = no (λ ())
AUFLIA    ⇾? LIA       = no (λ ())
AUFLIA    ⇾? AUFLIRA   = no (λ ())
AUFLIA    ⇾? ALIA      = no (λ ())
AUFLIA    ⇾? AUFLIA    = no (λ ())
AUFLIA    ⇾? QF-ALIA   = no (λ ())
AUFLIA    ⇾? QF-AUFLIA = no (λ ())
AUFLIA    ⇾? QF-UFIDL  = no (λ ())
AUFLIA    ⇾? QF-UFLIA  = no (λ ())
AUFLIA    ⇾? QF-UFNIA  = no (λ ())
AUFLIA    ⇾? QF-UF     = no (λ ())
AUFLIA    ⇾? QF-UFLRA  = no (λ ())
AUFLIA    ⇾? UFLRA     = no (λ ())
AUFLIA    ⇾? QF-UFNRA  = no (λ ())
AUFLIA    ⇾? QF-UFBV   = no (λ ())
AUFLIA    ⇾? QF-AUFBV  = no (λ ())
AUFLIA    ⇾? QF-BV     = no (λ ())
AUFLIA    ⇾? QF-ABV    = no (λ ())
AUFLIA    ⇾? QF-RDL    = no (λ ())
AUFLIA    ⇾? QF-LRA    = no (λ ())
AUFLIA    ⇾? NRA       = no (λ ())
AUFLIA    ⇾? LRA       = no (λ ())
AUFLIA    ⇾? QF-NRA    = no (λ ())
QF-ALIA   ⇾? QF-AX     = no (λ ())
QF-ALIA   ⇾? QF-IDL    = no (λ ())
QF-ALIA   ⇾? QF-LIA    = no (λ ())
QF-ALIA   ⇾? QF-NIA    = no (λ ())
QF-ALIA   ⇾? NIA       = no (λ ())
QF-ALIA   ⇾? UFNIA     = no (λ ())
QF-ALIA   ⇾? AUFNIRA   = no (λ ())
QF-ALIA   ⇾? LIA       = no (λ ())
QF-ALIA   ⇾? AUFLIRA   = no (λ ())
QF-ALIA   ⇾? ALIA      = yes QF-ALIA⇾ALIA
QF-ALIA   ⇾? AUFLIA    = no (λ ())
QF-ALIA   ⇾? QF-ALIA   = no (λ ())
QF-ALIA   ⇾? QF-AUFLIA = yes QF-ALIA⇾QF-AUFLIA
QF-ALIA   ⇾? QF-UFIDL  = no (λ ())
QF-ALIA   ⇾? QF-UFLIA  = no (λ ())
QF-ALIA   ⇾? QF-UFNIA  = no (λ ())
QF-ALIA   ⇾? QF-UF     = no (λ ())
QF-ALIA   ⇾? QF-UFLRA  = no (λ ())
QF-ALIA   ⇾? UFLRA     = no (λ ())
QF-ALIA   ⇾? QF-UFNRA  = no (λ ())
QF-ALIA   ⇾? QF-UFBV   = no (λ ())
QF-ALIA   ⇾? QF-AUFBV  = no (λ ())
QF-ALIA   ⇾? QF-BV     = no (λ ())
QF-ALIA   ⇾? QF-ABV    = no (λ ())
QF-ALIA   ⇾? QF-RDL    = no (λ ())
QF-ALIA   ⇾? QF-LRA    = no (λ ())
QF-ALIA   ⇾? NRA       = no (λ ())
QF-ALIA   ⇾? LRA       = no (λ ())
QF-ALIA   ⇾? QF-NRA    = no (λ ())
QF-AUFLIA ⇾? QF-AX     = no (λ ())
QF-AUFLIA ⇾? QF-IDL    = no (λ ())
QF-AUFLIA ⇾? QF-LIA    = no (λ ())
QF-AUFLIA ⇾? QF-NIA    = no (λ ())
QF-AUFLIA ⇾? NIA       = no (λ ())
QF-AUFLIA ⇾? UFNIA     = no (λ ())
QF-AUFLIA ⇾? AUFNIRA   = no (λ ())
QF-AUFLIA ⇾? LIA       = no (λ ())
QF-AUFLIA ⇾? AUFLIRA   = no (λ ())
QF-AUFLIA ⇾? ALIA      = no (λ ())
QF-AUFLIA ⇾? AUFLIA    = yes QF-AUFLIA⇾AUFLIA
QF-AUFLIA ⇾? QF-ALIA   = no (λ ())
QF-AUFLIA ⇾? QF-AUFLIA = no (λ ())
QF-AUFLIA ⇾? QF-UFIDL  = no (λ ())
QF-AUFLIA ⇾? QF-UFLIA  = no (λ ())
QF-AUFLIA ⇾? QF-UFNIA  = no (λ ())
QF-AUFLIA ⇾? QF-UF     = no (λ ())
QF-AUFLIA ⇾? QF-UFLRA  = no (λ ())
QF-AUFLIA ⇾? UFLRA     = no (λ ())
QF-AUFLIA ⇾? QF-UFNRA  = no (λ ())
QF-AUFLIA ⇾? QF-UFBV   = no (λ ())
QF-AUFLIA ⇾? QF-AUFBV  = no (λ ())
QF-AUFLIA ⇾? QF-BV     = no (λ ())
QF-AUFLIA ⇾? QF-ABV    = no (λ ())
QF-AUFLIA ⇾? QF-RDL    = no (λ ())
QF-AUFLIA ⇾? QF-LRA    = no (λ ())
QF-AUFLIA ⇾? NRA       = no (λ ())
QF-AUFLIA ⇾? LRA       = no (λ ())
QF-AUFLIA ⇾? QF-NRA    = no (λ ())
QF-UFIDL  ⇾? QF-AX     = no (λ ())
QF-UFIDL  ⇾? QF-IDL    = no (λ ())
QF-UFIDL  ⇾? QF-LIA    = no (λ ())
QF-UFIDL  ⇾? QF-NIA    = no (λ ())
QF-UFIDL  ⇾? NIA       = no (λ ())
QF-UFIDL  ⇾? UFNIA     = no (λ ())
QF-UFIDL  ⇾? AUFNIRA   = no (λ ())
QF-UFIDL  ⇾? LIA       = no (λ ())
QF-UFIDL  ⇾? AUFLIRA   = no (λ ())
QF-UFIDL  ⇾? ALIA      = no (λ ())
QF-UFIDL  ⇾? AUFLIA    = no (λ ())
QF-UFIDL  ⇾? QF-ALIA   = no (λ ())
QF-UFIDL  ⇾? QF-AUFLIA = no (λ ())
QF-UFIDL  ⇾? QF-UFIDL  = no (λ ())
QF-UFIDL  ⇾? QF-UFLIA  = yes QF-UFIDL⇾QF-UFLIA
QF-UFIDL  ⇾? QF-UFNIA  = no (λ ())
QF-UFIDL  ⇾? QF-UF     = no (λ ())
QF-UFIDL  ⇾? QF-UFLRA  = no (λ ())
QF-UFIDL  ⇾? UFLRA     = no (λ ())
QF-UFIDL  ⇾? QF-UFNRA  = no (λ ())
QF-UFIDL  ⇾? QF-UFBV   = no (λ ())
QF-UFIDL  ⇾? QF-AUFBV  = no (λ ())
QF-UFIDL  ⇾? QF-BV     = no (λ ())
QF-UFIDL  ⇾? QF-ABV    = no (λ ())
QF-UFIDL  ⇾? QF-RDL    = no (λ ())
QF-UFIDL  ⇾? QF-LRA    = no (λ ())
QF-UFIDL  ⇾? NRA       = no (λ ())
QF-UFIDL  ⇾? LRA       = no (λ ())
QF-UFIDL  ⇾? QF-NRA    = no (λ ())
QF-UFLIA  ⇾? QF-AX     = no (λ ())
QF-UFLIA  ⇾? QF-IDL    = no (λ ())
QF-UFLIA  ⇾? QF-LIA    = no (λ ())
QF-UFLIA  ⇾? QF-NIA    = no (λ ())
QF-UFLIA  ⇾? NIA       = no (λ ())
QF-UFLIA  ⇾? UFNIA     = no (λ ())
QF-UFLIA  ⇾? AUFNIRA   = no (λ ())
QF-UFLIA  ⇾? LIA       = no (λ ())
QF-UFLIA  ⇾? AUFLIRA   = no (λ ())
QF-UFLIA  ⇾? ALIA      = no (λ ())
QF-UFLIA  ⇾? AUFLIA    = no (λ ())
QF-UFLIA  ⇾? QF-ALIA   = no (λ ())
QF-UFLIA  ⇾? QF-AUFLIA = yes QF-UFLIA⇾QF-AUFLIA
QF-UFLIA  ⇾? QF-UFIDL  = no (λ ())
QF-UFLIA  ⇾? QF-UFLIA  = no (λ ())
QF-UFLIA  ⇾? QF-UFNIA  = yes QF-UFLIA⇾QF-UFNIA
QF-UFLIA  ⇾? QF-UF     = no (λ ())
QF-UFLIA  ⇾? QF-UFLRA  = no (λ ())
QF-UFLIA  ⇾? UFLRA     = no (λ ())
QF-UFLIA  ⇾? QF-UFNRA  = no (λ ())
QF-UFLIA  ⇾? QF-UFBV   = no (λ ())
QF-UFLIA  ⇾? QF-AUFBV  = no (λ ())
QF-UFLIA  ⇾? QF-BV     = no (λ ())
QF-UFLIA  ⇾? QF-ABV    = no (λ ())
QF-UFLIA  ⇾? QF-RDL    = no (λ ())
QF-UFLIA  ⇾? QF-LRA    = no (λ ())
QF-UFLIA  ⇾? NRA       = no (λ ())
QF-UFLIA  ⇾? LRA       = no (λ ())
QF-UFLIA  ⇾? QF-NRA    = no (λ ())
QF-UFNIA  ⇾? QF-AX     = no (λ ())
QF-UFNIA  ⇾? QF-IDL    = no (λ ())
QF-UFNIA  ⇾? QF-LIA    = no (λ ())
QF-UFNIA  ⇾? QF-NIA    = no (λ ())
QF-UFNIA  ⇾? NIA       = no (λ ())
QF-UFNIA  ⇾? UFNIA     = yes QF-UFNIA⇾UFNIA
QF-UFNIA  ⇾? AUFNIRA   = no (λ ())
QF-UFNIA  ⇾? LIA       = no (λ ())
QF-UFNIA  ⇾? AUFLIRA   = no (λ ())
QF-UFNIA  ⇾? ALIA      = no (λ ())
QF-UFNIA  ⇾? AUFLIA    = no (λ ())
QF-UFNIA  ⇾? QF-ALIA   = no (λ ())
QF-UFNIA  ⇾? QF-AUFLIA = no (λ ())
QF-UFNIA  ⇾? QF-UFIDL  = no (λ ())
QF-UFNIA  ⇾? QF-UFLIA  = no (λ ())
QF-UFNIA  ⇾? QF-UFNIA  = no (λ ())
QF-UFNIA  ⇾? QF-UF     = no (λ ())
QF-UFNIA  ⇾? QF-UFLRA  = no (λ ())
QF-UFNIA  ⇾? UFLRA     = no (λ ())
QF-UFNIA  ⇾? QF-UFNRA  = no (λ ())
QF-UFNIA  ⇾? QF-UFBV   = no (λ ())
QF-UFNIA  ⇾? QF-AUFBV  = no (λ ())
QF-UFNIA  ⇾? QF-BV     = no (λ ())
QF-UFNIA  ⇾? QF-ABV    = no (λ ())
QF-UFNIA  ⇾? QF-RDL    = no (λ ())
QF-UFNIA  ⇾? QF-LRA    = no (λ ())
QF-UFNIA  ⇾? NRA       = no (λ ())
QF-UFNIA  ⇾? LRA       = no (λ ())
QF-UFNIA  ⇾? QF-NRA    = no (λ ())
QF-UF     ⇾? QF-AX     = no (λ ())
QF-UF     ⇾? QF-IDL    = no (λ ())
QF-UF     ⇾? QF-LIA    = no (λ ())
QF-UF     ⇾? QF-NIA    = no (λ ())
QF-UF     ⇾? NIA       = no (λ ())
QF-UF     ⇾? UFNIA     = no (λ ())
QF-UF     ⇾? AUFNIRA   = no (λ ())
QF-UF     ⇾? LIA       = no (λ ())
QF-UF     ⇾? AUFLIRA   = no (λ ())
QF-UF     ⇾? ALIA      = no (λ ())
QF-UF     ⇾? AUFLIA    = no (λ ())
QF-UF     ⇾? QF-ALIA   = no (λ ())
QF-UF     ⇾? QF-AUFLIA = no (λ ())
QF-UF     ⇾? QF-UFIDL  = yes QF-UF⇾QF-UFIDL
QF-UF     ⇾? QF-UFLIA  = no (λ ())
QF-UF     ⇾? QF-UFNIA  = no (λ ())
QF-UF     ⇾? QF-UF     = no (λ ())
QF-UF     ⇾? QF-UFLRA  = yes QF-UF⇾QF-UFLRA
QF-UF     ⇾? UFLRA     = no (λ ())
QF-UF     ⇾? QF-UFNRA  = no (λ ())
QF-UF     ⇾? QF-UFBV   = yes QF-UF⇾QF-UFBV
QF-UF     ⇾? QF-AUFBV  = no (λ ())
QF-UF     ⇾? QF-BV     = no (λ ())
QF-UF     ⇾? QF-ABV    = no (λ ())
QF-UF     ⇾? QF-RDL    = no (λ ())
QF-UF     ⇾? QF-LRA    = no (λ ())
QF-UF     ⇾? NRA       = no (λ ())
QF-UF     ⇾? LRA       = no (λ ())
QF-UF     ⇾? QF-NRA    = no (λ ())
QF-UFLRA  ⇾? QF-AX     = no (λ ())
QF-UFLRA  ⇾? QF-IDL    = no (λ ())
QF-UFLRA  ⇾? QF-LIA    = no (λ ())
QF-UFLRA  ⇾? QF-NIA    = no (λ ())
QF-UFLRA  ⇾? NIA       = no (λ ())
QF-UFLRA  ⇾? UFNIA     = no (λ ())
QF-UFLRA  ⇾? AUFNIRA   = no (λ ())
QF-UFLRA  ⇾? LIA       = no (λ ())
QF-UFLRA  ⇾? AUFLIRA   = no (λ ())
QF-UFLRA  ⇾? ALIA      = no (λ ())
QF-UFLRA  ⇾? AUFLIA    = no (λ ())
QF-UFLRA  ⇾? QF-ALIA   = no (λ ())
QF-UFLRA  ⇾? QF-AUFLIA = no (λ ())
QF-UFLRA  ⇾? QF-UFIDL  = no (λ ())
QF-UFLRA  ⇾? QF-UFLIA  = no (λ ())
QF-UFLRA  ⇾? QF-UFNIA  = no (λ ())
QF-UFLRA  ⇾? QF-UF     = no (λ ())
QF-UFLRA  ⇾? QF-UFLRA  = no (λ ())
QF-UFLRA  ⇾? UFLRA     = yes QF-UFLRA⇾UFLRA
QF-UFLRA  ⇾? QF-UFNRA  = yes QF-UFLRA⇾QF-UFNRA
QF-UFLRA  ⇾? QF-UFBV   = no (λ ())
QF-UFLRA  ⇾? QF-AUFBV  = no (λ ())
QF-UFLRA  ⇾? QF-BV     = no (λ ())
QF-UFLRA  ⇾? QF-ABV    = no (λ ())
QF-UFLRA  ⇾? QF-RDL    = no (λ ())
QF-UFLRA  ⇾? QF-LRA    = no (λ ())
QF-UFLRA  ⇾? NRA       = no (λ ())
QF-UFLRA  ⇾? LRA       = no (λ ())
QF-UFLRA  ⇾? QF-NRA    = no (λ ())
UFLRA     ⇾? QF-AX     = no (λ ())
UFLRA     ⇾? QF-IDL    = no (λ ())
UFLRA     ⇾? QF-LIA    = no (λ ())
UFLRA     ⇾? QF-NIA    = no (λ ())
UFLRA     ⇾? NIA       = no (λ ())
UFLRA     ⇾? UFNIA     = no (λ ())
UFLRA     ⇾? AUFNIRA   = no (λ ())
UFLRA     ⇾? LIA       = no (λ ())
UFLRA     ⇾? AUFLIRA   = yes UFLRA⇾AUFLIRA
UFLRA     ⇾? ALIA      = no (λ ())
UFLRA     ⇾? AUFLIA    = no (λ ())
UFLRA     ⇾? QF-ALIA   = no (λ ())
UFLRA     ⇾? QF-AUFLIA = no (λ ())
UFLRA     ⇾? QF-UFIDL  = no (λ ())
UFLRA     ⇾? QF-UFLIA  = no (λ ())
UFLRA     ⇾? QF-UFNIA  = no (λ ())
UFLRA     ⇾? QF-UF     = no (λ ())
UFLRA     ⇾? QF-UFLRA  = no (λ ())
UFLRA     ⇾? UFLRA     = no (λ ())
UFLRA     ⇾? QF-UFNRA  = no (λ ())
UFLRA     ⇾? QF-UFBV   = no (λ ())
UFLRA     ⇾? QF-AUFBV  = no (λ ())
UFLRA     ⇾? QF-BV     = no (λ ())
UFLRA     ⇾? QF-ABV    = no (λ ())
UFLRA     ⇾? QF-RDL    = no (λ ())
UFLRA     ⇾? QF-LRA    = no (λ ())
UFLRA     ⇾? NRA       = no (λ ())
UFLRA     ⇾? LRA       = no (λ ())
UFLRA     ⇾? QF-NRA    = no (λ ())
QF-UFNRA  ⇾? QF-AX     = no (λ ())
QF-UFNRA  ⇾? QF-IDL    = no (λ ())
QF-UFNRA  ⇾? QF-LIA    = no (λ ())
QF-UFNRA  ⇾? QF-NIA    = no (λ ())
QF-UFNRA  ⇾? NIA       = no (λ ())
QF-UFNRA  ⇾? UFNIA     = no (λ ())
QF-UFNRA  ⇾? AUFNIRA   = yes QF-UFNRA⇾AUFNIRA
QF-UFNRA  ⇾? LIA       = no (λ ())
QF-UFNRA  ⇾? AUFLIRA   = no (λ ())
QF-UFNRA  ⇾? ALIA      = no (λ ())
QF-UFNRA  ⇾? AUFLIA    = no (λ ())
QF-UFNRA  ⇾? QF-ALIA   = no (λ ())
QF-UFNRA  ⇾? QF-AUFLIA = no (λ ())
QF-UFNRA  ⇾? QF-UFIDL  = no (λ ())
QF-UFNRA  ⇾? QF-UFLIA  = no (λ ())
QF-UFNRA  ⇾? QF-UFNIA  = no (λ ())
QF-UFNRA  ⇾? QF-UF     = no (λ ())
QF-UFNRA  ⇾? QF-UFLRA  = no (λ ())
QF-UFNRA  ⇾? UFLRA     = no (λ ())
QF-UFNRA  ⇾? QF-UFNRA  = no (λ ())
QF-UFNRA  ⇾? QF-UFBV   = no (λ ())
QF-UFNRA  ⇾? QF-AUFBV  = no (λ ())
QF-UFNRA  ⇾? QF-BV     = no (λ ())
QF-UFNRA  ⇾? QF-ABV    = no (λ ())
QF-UFNRA  ⇾? QF-RDL    = no (λ ())
QF-UFNRA  ⇾? QF-LRA    = no (λ ())
QF-UFNRA  ⇾? NRA       = no (λ ())
QF-UFNRA  ⇾? LRA       = no (λ ())
QF-UFNRA  ⇾? QF-NRA    = no (λ ())
QF-UFBV   ⇾? QF-AX     = no (λ ())
QF-UFBV   ⇾? QF-IDL    = no (λ ())
QF-UFBV   ⇾? QF-LIA    = no (λ ())
QF-UFBV   ⇾? QF-NIA    = no (λ ())
QF-UFBV   ⇾? NIA       = no (λ ())
QF-UFBV   ⇾? UFNIA     = no (λ ())
QF-UFBV   ⇾? AUFNIRA   = no (λ ())
QF-UFBV   ⇾? LIA       = no (λ ())
QF-UFBV   ⇾? AUFLIRA   = no (λ ())
QF-UFBV   ⇾? ALIA      = no (λ ())
QF-UFBV   ⇾? AUFLIA    = no (λ ())
QF-UFBV   ⇾? QF-ALIA   = no (λ ())
QF-UFBV   ⇾? QF-AUFLIA = no (λ ())
QF-UFBV   ⇾? QF-UFIDL  = no (λ ())
QF-UFBV   ⇾? QF-UFLIA  = no (λ ())
QF-UFBV   ⇾? QF-UFNIA  = no (λ ())
QF-UFBV   ⇾? QF-UF     = no (λ ())
QF-UFBV   ⇾? QF-UFLRA  = no (λ ())
QF-UFBV   ⇾? UFLRA     = no (λ ())
QF-UFBV   ⇾? QF-UFNRA  = no (λ ())
QF-UFBV   ⇾? QF-UFBV   = no (λ ())
QF-UFBV   ⇾? QF-AUFBV  = yes QF-UFBV⇾QF-AUFBV
QF-UFBV   ⇾? QF-BV     = no (λ ())
QF-UFBV   ⇾? QF-ABV    = no (λ ())
QF-UFBV   ⇾? QF-RDL    = no (λ ())
QF-UFBV   ⇾? QF-LRA    = no (λ ())
QF-UFBV   ⇾? NRA       = no (λ ())
QF-UFBV   ⇾? LRA       = no (λ ())
QF-UFBV   ⇾? QF-NRA    = no (λ ())
QF-AUFBV  ⇾? QF-AX     = no (λ ())
QF-AUFBV  ⇾? QF-IDL    = no (λ ())
QF-AUFBV  ⇾? QF-LIA    = no (λ ())
QF-AUFBV  ⇾? QF-NIA    = no (λ ())
QF-AUFBV  ⇾? NIA       = no (λ ())
QF-AUFBV  ⇾? UFNIA     = no (λ ())
QF-AUFBV  ⇾? AUFNIRA   = no (λ ())
QF-AUFBV  ⇾? LIA       = no (λ ())
QF-AUFBV  ⇾? AUFLIRA   = no (λ ())
QF-AUFBV  ⇾? ALIA      = no (λ ())
QF-AUFBV  ⇾? AUFLIA    = no (λ ())
QF-AUFBV  ⇾? QF-ALIA   = no (λ ())
QF-AUFBV  ⇾? QF-AUFLIA = no (λ ())
QF-AUFBV  ⇾? QF-UFIDL  = no (λ ())
QF-AUFBV  ⇾? QF-UFLIA  = no (λ ())
QF-AUFBV  ⇾? QF-UFNIA  = no (λ ())
QF-AUFBV  ⇾? QF-UF     = no (λ ())
QF-AUFBV  ⇾? QF-UFLRA  = no (λ ())
QF-AUFBV  ⇾? UFLRA     = no (λ ())
QF-AUFBV  ⇾? QF-UFNRA  = no (λ ())
QF-AUFBV  ⇾? QF-UFBV   = no (λ ())
QF-AUFBV  ⇾? QF-AUFBV  = no (λ ())
QF-AUFBV  ⇾? QF-BV     = no (λ ())
QF-AUFBV  ⇾? QF-ABV    = no (λ ())
QF-AUFBV  ⇾? QF-RDL    = no (λ ())
QF-AUFBV  ⇾? QF-LRA    = no (λ ())
QF-AUFBV  ⇾? NRA       = no (λ ())
QF-AUFBV  ⇾? LRA       = no (λ ())
QF-AUFBV  ⇾? QF-NRA    = no (λ ())
QF-BV     ⇾? QF-AX     = no (λ ())
QF-BV     ⇾? QF-IDL    = no (λ ())
QF-BV     ⇾? QF-LIA    = no (λ ())
QF-BV     ⇾? QF-NIA    = no (λ ())
QF-BV     ⇾? NIA       = no (λ ())
QF-BV     ⇾? UFNIA     = no (λ ())
QF-BV     ⇾? AUFNIRA   = no (λ ())
QF-BV     ⇾? LIA       = no (λ ())
QF-BV     ⇾? AUFLIRA   = no (λ ())
QF-BV     ⇾? ALIA      = no (λ ())
QF-BV     ⇾? AUFLIA    = no (λ ())
QF-BV     ⇾? QF-ALIA   = no (λ ())
QF-BV     ⇾? QF-AUFLIA = no (λ ())
QF-BV     ⇾? QF-UFIDL  = no (λ ())
QF-BV     ⇾? QF-UFLIA  = no (λ ())
QF-BV     ⇾? QF-UFNIA  = no (λ ())
QF-BV     ⇾? QF-UF     = no (λ ())
QF-BV     ⇾? QF-UFLRA  = no (λ ())
QF-BV     ⇾? UFLRA     = no (λ ())
QF-BV     ⇾? QF-UFNRA  = no (λ ())
QF-BV     ⇾? QF-UFBV   = yes QF-BV⇾QF-UFBV
QF-BV     ⇾? QF-AUFBV  = no (λ ())
QF-BV     ⇾? QF-BV     = no (λ ())
QF-BV     ⇾? QF-ABV    = yes QF-BV⇾QF-ABV
QF-BV     ⇾? QF-RDL    = no (λ ())
QF-BV     ⇾? QF-LRA    = no (λ ())
QF-BV     ⇾? NRA       = no (λ ())
QF-BV     ⇾? LRA       = no (λ ())
QF-BV     ⇾? QF-NRA    = no (λ ())
QF-ABV    ⇾? QF-AX     = no (λ ())
QF-ABV    ⇾? QF-IDL    = no (λ ())
QF-ABV    ⇾? QF-LIA    = no (λ ())
QF-ABV    ⇾? QF-NIA    = no (λ ())
QF-ABV    ⇾? NIA       = no (λ ())
QF-ABV    ⇾? UFNIA     = no (λ ())
QF-ABV    ⇾? AUFNIRA   = no (λ ())
QF-ABV    ⇾? LIA       = no (λ ())
QF-ABV    ⇾? AUFLIRA   = no (λ ())
QF-ABV    ⇾? ALIA      = no (λ ())
QF-ABV    ⇾? AUFLIA    = no (λ ())
QF-ABV    ⇾? QF-ALIA   = no (λ ())
QF-ABV    ⇾? QF-AUFLIA = no (λ ())
QF-ABV    ⇾? QF-UFIDL  = no (λ ())
QF-ABV    ⇾? QF-UFLIA  = no (λ ())
QF-ABV    ⇾? QF-UFNIA  = no (λ ())
QF-ABV    ⇾? QF-UF     = no (λ ())
QF-ABV    ⇾? QF-UFLRA  = no (λ ())
QF-ABV    ⇾? UFLRA     = no (λ ())
QF-ABV    ⇾? QF-UFNRA  = no (λ ())
QF-ABV    ⇾? QF-UFBV   = no (λ ())
QF-ABV    ⇾? QF-AUFBV  = yes QF-ABV⇾QF-AUFBV
QF-ABV    ⇾? QF-BV     = no (λ ())
QF-ABV    ⇾? QF-ABV    = no (λ ())
QF-ABV    ⇾? QF-RDL    = no (λ ())
QF-ABV    ⇾? QF-LRA    = no (λ ())
QF-ABV    ⇾? NRA       = no (λ ())
QF-ABV    ⇾? LRA       = no (λ ())
QF-ABV    ⇾? QF-NRA    = no (λ ())
QF-RDL    ⇾? QF-AX     = no (λ ())
QF-RDL    ⇾? QF-IDL    = no (λ ())
QF-RDL    ⇾? QF-LIA    = no (λ ())
QF-RDL    ⇾? QF-NIA    = no (λ ())
QF-RDL    ⇾? NIA       = no (λ ())
QF-RDL    ⇾? UFNIA     = no (λ ())
QF-RDL    ⇾? AUFNIRA   = no (λ ())
QF-RDL    ⇾? LIA       = no (λ ())
QF-RDL    ⇾? AUFLIRA   = no (λ ())
QF-RDL    ⇾? ALIA      = no (λ ())
QF-RDL    ⇾? AUFLIA    = no (λ ())
QF-RDL    ⇾? QF-ALIA   = no (λ ())
QF-RDL    ⇾? QF-AUFLIA = no (λ ())
QF-RDL    ⇾? QF-UFIDL  = no (λ ())
QF-RDL    ⇾? QF-UFLIA  = no (λ ())
QF-RDL    ⇾? QF-UFNIA  = no (λ ())
QF-RDL    ⇾? QF-UF     = no (λ ())
QF-RDL    ⇾? QF-UFLRA  = no (λ ())
QF-RDL    ⇾? UFLRA     = no (λ ())
QF-RDL    ⇾? QF-UFNRA  = no (λ ())
QF-RDL    ⇾? QF-UFBV   = no (λ ())
QF-RDL    ⇾? QF-AUFBV  = no (λ ())
QF-RDL    ⇾? QF-BV     = no (λ ())
QF-RDL    ⇾? QF-ABV    = no (λ ())
QF-RDL    ⇾? QF-RDL    = no (λ ())
QF-RDL    ⇾? QF-LRA    = yes QF-RDL⇾QF-LRA
QF-RDL    ⇾? NRA       = no (λ ())
QF-RDL    ⇾? LRA       = no (λ ())
QF-RDL    ⇾? QF-NRA    = no (λ ())
QF-LRA    ⇾? QF-AX     = no (λ ())
QF-LRA    ⇾? QF-IDL    = no (λ ())
QF-LRA    ⇾? QF-LIA    = no (λ ())
QF-LRA    ⇾? QF-NIA    = no (λ ())
QF-LRA    ⇾? NIA       = no (λ ())
QF-LRA    ⇾? UFNIA     = no (λ ())
QF-LRA    ⇾? AUFNIRA   = no (λ ())
QF-LRA    ⇾? LIA       = no (λ ())
QF-LRA    ⇾? AUFLIRA   = no (λ ())
QF-LRA    ⇾? ALIA      = no (λ ())
QF-LRA    ⇾? AUFLIA    = no (λ ())
QF-LRA    ⇾? QF-ALIA   = no (λ ())
QF-LRA    ⇾? QF-AUFLIA = no (λ ())
QF-LRA    ⇾? QF-UFIDL  = no (λ ())
QF-LRA    ⇾? QF-UFLIA  = no (λ ())
QF-LRA    ⇾? QF-UFNIA  = no (λ ())
QF-LRA    ⇾? QF-UF     = no (λ ())
QF-LRA    ⇾? QF-UFLRA  = no (λ ())
QF-LRA    ⇾? UFLRA     = no (λ ())
QF-LRA    ⇾? QF-UFNRA  = yes QF-LRA⇾QF-UFNRA
QF-LRA    ⇾? QF-UFBV   = no (λ ())
QF-LRA    ⇾? QF-AUFBV  = no (λ ())
QF-LRA    ⇾? QF-BV     = no (λ ())
QF-LRA    ⇾? QF-ABV    = no (λ ())
QF-LRA    ⇾? QF-RDL    = no (λ ())
QF-LRA    ⇾? QF-LRA    = no (λ ())
QF-LRA    ⇾? NRA       = no (λ ())
QF-LRA    ⇾? LRA       = yes QF-LRA⇾LRA
QF-LRA    ⇾? QF-NRA    = yes QF-LRA⇾QF-NRA
NRA       ⇾? QF-AX     = no (λ ())
NRA       ⇾? QF-IDL    = no (λ ())
NRA       ⇾? QF-LIA    = no (λ ())
NRA       ⇾? QF-NIA    = no (λ ())
NRA       ⇾? NIA       = no (λ ())
NRA       ⇾? UFNIA     = no (λ ())
NRA       ⇾? AUFNIRA   = yes NRA⇾AUFNIRA
NRA       ⇾? LIA       = no (λ ())
NRA       ⇾? AUFLIRA   = no (λ ())
NRA       ⇾? ALIA      = no (λ ())
NRA       ⇾? AUFLIA    = no (λ ())
NRA       ⇾? QF-ALIA   = no (λ ())
NRA       ⇾? QF-AUFLIA = no (λ ())
NRA       ⇾? QF-UFIDL  = no (λ ())
NRA       ⇾? QF-UFLIA  = no (λ ())
NRA       ⇾? QF-UFNIA  = no (λ ())
NRA       ⇾? QF-UF     = no (λ ())
NRA       ⇾? QF-UFLRA  = no (λ ())
NRA       ⇾? UFLRA     = no (λ ())
NRA       ⇾? QF-UFNRA  = no (λ ())
NRA       ⇾? QF-UFBV   = no (λ ())
NRA       ⇾? QF-AUFBV  = no (λ ())
NRA       ⇾? QF-BV     = no (λ ())
NRA       ⇾? QF-ABV    = no (λ ())
NRA       ⇾? QF-RDL    = no (λ ())
NRA       ⇾? QF-LRA    = no (λ ())
NRA       ⇾? NRA       = no (λ ())
NRA       ⇾? LRA       = no (λ ())
NRA       ⇾? QF-NRA    = no (λ ())
LRA       ⇾? QF-AX     = no (λ ())
LRA       ⇾? QF-IDL    = no (λ ())
LRA       ⇾? QF-LIA    = no (λ ())
LRA       ⇾? QF-NIA    = no (λ ())
LRA       ⇾? NIA       = no (λ ())
LRA       ⇾? UFNIA     = no (λ ())
LRA       ⇾? AUFNIRA   = no (λ ())
LRA       ⇾? LIA       = no (λ ())
LRA       ⇾? AUFLIRA   = no (λ ())
LRA       ⇾? ALIA      = no (λ ())
LRA       ⇾? AUFLIA    = no (λ ())
LRA       ⇾? QF-ALIA   = no (λ ())
LRA       ⇾? QF-AUFLIA = no (λ ())
LRA       ⇾? QF-UFIDL  = no (λ ())
LRA       ⇾? QF-UFLIA  = no (λ ())
LRA       ⇾? QF-UFNIA  = no (λ ())
LRA       ⇾? QF-UF     = no (λ ())
LRA       ⇾? QF-UFLRA  = no (λ ())
LRA       ⇾? UFLRA     = yes LRA⇾UFLRA
LRA       ⇾? QF-UFNRA  = no (λ ())
LRA       ⇾? QF-UFBV   = no (λ ())
LRA       ⇾? QF-AUFBV  = no (λ ())
LRA       ⇾? QF-BV     = no (λ ())
LRA       ⇾? QF-ABV    = no (λ ())
LRA       ⇾? QF-RDL    = no (λ ())
LRA       ⇾? QF-LRA    = no (λ ())
LRA       ⇾? NRA       = yes LRA⇾NRA
LRA       ⇾? LRA       = no (λ ())
LRA       ⇾? QF-NRA    = no (λ ())
QF-NRA    ⇾? QF-AX     = no (λ ())
QF-NRA    ⇾? QF-IDL    = no (λ ())
QF-NRA    ⇾? QF-LIA    = no (λ ())
QF-NRA    ⇾? QF-NIA    = no (λ ())
QF-NRA    ⇾? NIA       = no (λ ())
QF-NRA    ⇾? UFNIA     = no (λ ())
QF-NRA    ⇾? AUFNIRA   = no (λ ())
QF-NRA    ⇾? LIA       = no (λ ())
QF-NRA    ⇾? AUFLIRA   = no (λ ())
QF-NRA    ⇾? ALIA      = no (λ ())
QF-NRA    ⇾? AUFLIA    = no (λ ())
QF-NRA    ⇾? QF-ALIA   = no (λ ())
QF-NRA    ⇾? QF-AUFLIA = no (λ ())
QF-NRA    ⇾? QF-UFIDL  = no (λ ())
QF-NRA    ⇾? QF-UFLIA  = no (λ ())
QF-NRA    ⇾? QF-UFNIA  = no (λ ())
QF-NRA    ⇾? QF-UF     = no (λ ())
QF-NRA    ⇾? QF-UFLRA  = no (λ ())
QF-NRA    ⇾? UFLRA     = no (λ ())
QF-NRA    ⇾? QF-UFNRA  = yes QF-NRA⇾QF-UFNRA
QF-NRA    ⇾? QF-UFBV   = no (λ ())
QF-NRA    ⇾? QF-AUFBV  = no (λ ())
QF-NRA    ⇾? QF-BV     = no (λ ())
QF-NRA    ⇾? QF-ABV    = no (λ ())
QF-NRA    ⇾? QF-RDL    = no (λ ())
QF-NRA    ⇾? QF-LRA    = no (λ ())
QF-NRA    ⇾? NRA       = yes QF-NRA⇾NRA
QF-NRA    ⇾? LRA       = no (λ ())
QF-NRA    ⇾? QF-NRA    = no (λ ())

-- |Equality for logics is decidable.
_≟_ : (l₁ l₂ : Logic) → Dec (l₁ ≡ l₂)
QF-AX     ≟ QF-AX     = yes refl
QF-AX     ≟ QF-IDL    = no (λ ())
QF-AX     ≟ QF-LIA    = no (λ ())
QF-AX     ≟ QF-NIA    = no (λ ())
QF-AX     ≟ NIA       = no (λ ())
QF-AX     ≟ UFNIA     = no (λ ())
QF-AX     ≟ AUFNIRA   = no (λ ())
QF-AX     ≟ LIA       = no (λ ())
QF-AX     ≟ AUFLIRA   = no (λ ())
QF-AX     ≟ ALIA      = no (λ ())
QF-AX     ≟ AUFLIA    = no (λ ())
QF-AX     ≟ QF-ALIA   = no (λ ())
QF-AX     ≟ QF-AUFLIA = no (λ ())
QF-AX     ≟ QF-UFIDL  = no (λ ())
QF-AX     ≟ QF-UFLIA  = no (λ ())
QF-AX     ≟ QF-UFNIA  = no (λ ())
QF-AX     ≟ QF-UF     = no (λ ())
QF-AX     ≟ QF-UFLRA  = no (λ ())
QF-AX     ≟ UFLRA     = no (λ ())
QF-AX     ≟ QF-UFNRA  = no (λ ())
QF-AX     ≟ QF-UFBV   = no (λ ())
QF-AX     ≟ QF-AUFBV  = no (λ ())
QF-AX     ≟ QF-BV     = no (λ ())
QF-AX     ≟ QF-ABV    = no (λ ())
QF-AX     ≟ QF-RDL    = no (λ ())
QF-AX     ≟ QF-LRA    = no (λ ())
QF-AX     ≟ NRA       = no (λ ())
QF-AX     ≟ LRA       = no (λ ())
QF-AX     ≟ QF-NRA    = no (λ ())
QF-IDL    ≟ QF-AX     = no (λ ())
QF-IDL    ≟ QF-IDL    = yes refl
QF-IDL    ≟ QF-LIA    = no (λ ())
QF-IDL    ≟ QF-NIA    = no (λ ())
QF-IDL    ≟ NIA       = no (λ ())
QF-IDL    ≟ UFNIA     = no (λ ())
QF-IDL    ≟ AUFNIRA   = no (λ ())
QF-IDL    ≟ LIA       = no (λ ())
QF-IDL    ≟ AUFLIRA   = no (λ ())
QF-IDL    ≟ ALIA      = no (λ ())
QF-IDL    ≟ AUFLIA    = no (λ ())
QF-IDL    ≟ QF-ALIA   = no (λ ())
QF-IDL    ≟ QF-AUFLIA = no (λ ())
QF-IDL    ≟ QF-UFIDL  = no (λ ())
QF-IDL    ≟ QF-UFLIA  = no (λ ())
QF-IDL    ≟ QF-UFNIA  = no (λ ())
QF-IDL    ≟ QF-UF     = no (λ ())
QF-IDL    ≟ QF-UFLRA  = no (λ ())
QF-IDL    ≟ UFLRA     = no (λ ())
QF-IDL    ≟ QF-UFNRA  = no (λ ())
QF-IDL    ≟ QF-UFBV   = no (λ ())
QF-IDL    ≟ QF-AUFBV  = no (λ ())
QF-IDL    ≟ QF-BV     = no (λ ())
QF-IDL    ≟ QF-ABV    = no (λ ())
QF-IDL    ≟ QF-RDL    = no (λ ())
QF-IDL    ≟ QF-LRA    = no (λ ())
QF-IDL    ≟ NRA       = no (λ ())
QF-IDL    ≟ LRA       = no (λ ())
QF-IDL    ≟ QF-NRA    = no (λ ())
QF-LIA    ≟ QF-AX     = no (λ ())
QF-LIA    ≟ QF-IDL    = no (λ ())
QF-LIA    ≟ QF-LIA    = yes refl
QF-LIA    ≟ QF-NIA    = no (λ ())
QF-LIA    ≟ NIA       = no (λ ())
QF-LIA    ≟ UFNIA     = no (λ ())
QF-LIA    ≟ AUFNIRA   = no (λ ())
QF-LIA    ≟ LIA       = no (λ ())
QF-LIA    ≟ AUFLIRA   = no (λ ())
QF-LIA    ≟ ALIA      = no (λ ())
QF-LIA    ≟ AUFLIA    = no (λ ())
QF-LIA    ≟ QF-ALIA   = no (λ ())
QF-LIA    ≟ QF-AUFLIA = no (λ ())
QF-LIA    ≟ QF-UFIDL  = no (λ ())
QF-LIA    ≟ QF-UFLIA  = no (λ ())
QF-LIA    ≟ QF-UFNIA  = no (λ ())
QF-LIA    ≟ QF-UF     = no (λ ())
QF-LIA    ≟ QF-UFLRA  = no (λ ())
QF-LIA    ≟ UFLRA     = no (λ ())
QF-LIA    ≟ QF-UFNRA  = no (λ ())
QF-LIA    ≟ QF-UFBV   = no (λ ())
QF-LIA    ≟ QF-AUFBV  = no (λ ())
QF-LIA    ≟ QF-BV     = no (λ ())
QF-LIA    ≟ QF-ABV    = no (λ ())
QF-LIA    ≟ QF-RDL    = no (λ ())
QF-LIA    ≟ QF-LRA    = no (λ ())
QF-LIA    ≟ NRA       = no (λ ())
QF-LIA    ≟ LRA       = no (λ ())
QF-LIA    ≟ QF-NRA    = no (λ ())
QF-NIA    ≟ QF-AX     = no (λ ())
QF-NIA    ≟ QF-IDL    = no (λ ())
QF-NIA    ≟ QF-LIA    = no (λ ())
QF-NIA    ≟ QF-NIA    = yes refl
QF-NIA    ≟ NIA       = no (λ ())
QF-NIA    ≟ UFNIA     = no (λ ())
QF-NIA    ≟ AUFNIRA   = no (λ ())
QF-NIA    ≟ LIA       = no (λ ())
QF-NIA    ≟ AUFLIRA   = no (λ ())
QF-NIA    ≟ ALIA      = no (λ ())
QF-NIA    ≟ AUFLIA    = no (λ ())
QF-NIA    ≟ QF-ALIA   = no (λ ())
QF-NIA    ≟ QF-AUFLIA = no (λ ())
QF-NIA    ≟ QF-UFIDL  = no (λ ())
QF-NIA    ≟ QF-UFLIA  = no (λ ())
QF-NIA    ≟ QF-UFNIA  = no (λ ())
QF-NIA    ≟ QF-UF     = no (λ ())
QF-NIA    ≟ QF-UFLRA  = no (λ ())
QF-NIA    ≟ UFLRA     = no (λ ())
QF-NIA    ≟ QF-UFNRA  = no (λ ())
QF-NIA    ≟ QF-UFBV   = no (λ ())
QF-NIA    ≟ QF-AUFBV  = no (λ ())
QF-NIA    ≟ QF-BV     = no (λ ())
QF-NIA    ≟ QF-ABV    = no (λ ())
QF-NIA    ≟ QF-RDL    = no (λ ())
QF-NIA    ≟ QF-LRA    = no (λ ())
QF-NIA    ≟ NRA       = no (λ ())
QF-NIA    ≟ LRA       = no (λ ())
QF-NIA    ≟ QF-NRA    = no (λ ())
NIA       ≟ QF-AX     = no (λ ())
NIA       ≟ QF-IDL    = no (λ ())
NIA       ≟ QF-LIA    = no (λ ())
NIA       ≟ QF-NIA    = no (λ ())
NIA       ≟ NIA       = yes refl
NIA       ≟ UFNIA     = no (λ ())
NIA       ≟ AUFNIRA   = no (λ ())
NIA       ≟ LIA       = no (λ ())
NIA       ≟ AUFLIRA   = no (λ ())
NIA       ≟ ALIA      = no (λ ())
NIA       ≟ AUFLIA    = no (λ ())
NIA       ≟ QF-ALIA   = no (λ ())
NIA       ≟ QF-AUFLIA = no (λ ())
NIA       ≟ QF-UFIDL  = no (λ ())
NIA       ≟ QF-UFLIA  = no (λ ())
NIA       ≟ QF-UFNIA  = no (λ ())
NIA       ≟ QF-UF     = no (λ ())
NIA       ≟ QF-UFLRA  = no (λ ())
NIA       ≟ UFLRA     = no (λ ())
NIA       ≟ QF-UFNRA  = no (λ ())
NIA       ≟ QF-UFBV   = no (λ ())
NIA       ≟ QF-AUFBV  = no (λ ())
NIA       ≟ QF-BV     = no (λ ())
NIA       ≟ QF-ABV    = no (λ ())
NIA       ≟ QF-RDL    = no (λ ())
NIA       ≟ QF-LRA    = no (λ ())
NIA       ≟ NRA       = no (λ ())
NIA       ≟ LRA       = no (λ ())
NIA       ≟ QF-NRA    = no (λ ())
UFNIA     ≟ QF-AX     = no (λ ())
UFNIA     ≟ QF-IDL    = no (λ ())
UFNIA     ≟ QF-LIA    = no (λ ())
UFNIA     ≟ QF-NIA    = no (λ ())
UFNIA     ≟ NIA       = no (λ ())
UFNIA     ≟ UFNIA     = yes refl
UFNIA     ≟ AUFNIRA   = no (λ ())
UFNIA     ≟ LIA       = no (λ ())
UFNIA     ≟ AUFLIRA   = no (λ ())
UFNIA     ≟ ALIA      = no (λ ())
UFNIA     ≟ AUFLIA    = no (λ ())
UFNIA     ≟ QF-ALIA   = no (λ ())
UFNIA     ≟ QF-AUFLIA = no (λ ())
UFNIA     ≟ QF-UFIDL  = no (λ ())
UFNIA     ≟ QF-UFLIA  = no (λ ())
UFNIA     ≟ QF-UFNIA  = no (λ ())
UFNIA     ≟ QF-UF     = no (λ ())
UFNIA     ≟ QF-UFLRA  = no (λ ())
UFNIA     ≟ UFLRA     = no (λ ())
UFNIA     ≟ QF-UFNRA  = no (λ ())
UFNIA     ≟ QF-UFBV   = no (λ ())
UFNIA     ≟ QF-AUFBV  = no (λ ())
UFNIA     ≟ QF-BV     = no (λ ())
UFNIA     ≟ QF-ABV    = no (λ ())
UFNIA     ≟ QF-RDL    = no (λ ())
UFNIA     ≟ QF-LRA    = no (λ ())
UFNIA     ≟ NRA       = no (λ ())
UFNIA     ≟ LRA       = no (λ ())
UFNIA     ≟ QF-NRA    = no (λ ())
AUFNIRA   ≟ QF-AX     = no (λ ())
AUFNIRA   ≟ QF-IDL    = no (λ ())
AUFNIRA   ≟ QF-LIA    = no (λ ())
AUFNIRA   ≟ QF-NIA    = no (λ ())
AUFNIRA   ≟ NIA       = no (λ ())
AUFNIRA   ≟ UFNIA     = no (λ ())
AUFNIRA   ≟ AUFNIRA   = yes refl
AUFNIRA   ≟ LIA       = no (λ ())
AUFNIRA   ≟ AUFLIRA   = no (λ ())
AUFNIRA   ≟ ALIA      = no (λ ())
AUFNIRA   ≟ AUFLIA    = no (λ ())
AUFNIRA   ≟ QF-ALIA   = no (λ ())
AUFNIRA   ≟ QF-AUFLIA = no (λ ())
AUFNIRA   ≟ QF-UFIDL  = no (λ ())
AUFNIRA   ≟ QF-UFLIA  = no (λ ())
AUFNIRA   ≟ QF-UFNIA  = no (λ ())
AUFNIRA   ≟ QF-UF     = no (λ ())
AUFNIRA   ≟ QF-UFLRA  = no (λ ())
AUFNIRA   ≟ UFLRA     = no (λ ())
AUFNIRA   ≟ QF-UFNRA  = no (λ ())
AUFNIRA   ≟ QF-UFBV   = no (λ ())
AUFNIRA   ≟ QF-AUFBV  = no (λ ())
AUFNIRA   ≟ QF-BV     = no (λ ())
AUFNIRA   ≟ QF-ABV    = no (λ ())
AUFNIRA   ≟ QF-RDL    = no (λ ())
AUFNIRA   ≟ QF-LRA    = no (λ ())
AUFNIRA   ≟ NRA       = no (λ ())
AUFNIRA   ≟ LRA       = no (λ ())
AUFNIRA   ≟ QF-NRA    = no (λ ())
LIA       ≟ QF-AX     = no (λ ())
LIA       ≟ QF-IDL    = no (λ ())
LIA       ≟ QF-LIA    = no (λ ())
LIA       ≟ QF-NIA    = no (λ ())
LIA       ≟ NIA       = no (λ ())
LIA       ≟ UFNIA     = no (λ ())
LIA       ≟ AUFNIRA   = no (λ ())
LIA       ≟ LIA       = yes refl
LIA       ≟ AUFLIRA   = no (λ ())
LIA       ≟ ALIA      = no (λ ())
LIA       ≟ AUFLIA    = no (λ ())
LIA       ≟ QF-ALIA   = no (λ ())
LIA       ≟ QF-AUFLIA = no (λ ())
LIA       ≟ QF-UFIDL  = no (λ ())
LIA       ≟ QF-UFLIA  = no (λ ())
LIA       ≟ QF-UFNIA  = no (λ ())
LIA       ≟ QF-UF     = no (λ ())
LIA       ≟ QF-UFLRA  = no (λ ())
LIA       ≟ UFLRA     = no (λ ())
LIA       ≟ QF-UFNRA  = no (λ ())
LIA       ≟ QF-UFBV   = no (λ ())
LIA       ≟ QF-AUFBV  = no (λ ())
LIA       ≟ QF-BV     = no (λ ())
LIA       ≟ QF-ABV    = no (λ ())
LIA       ≟ QF-RDL    = no (λ ())
LIA       ≟ QF-LRA    = no (λ ())
LIA       ≟ NRA       = no (λ ())
LIA       ≟ LRA       = no (λ ())
LIA       ≟ QF-NRA    = no (λ ())
AUFLIRA   ≟ QF-AX     = no (λ ())
AUFLIRA   ≟ QF-IDL    = no (λ ())
AUFLIRA   ≟ QF-LIA    = no (λ ())
AUFLIRA   ≟ QF-NIA    = no (λ ())
AUFLIRA   ≟ NIA       = no (λ ())
AUFLIRA   ≟ UFNIA     = no (λ ())
AUFLIRA   ≟ AUFNIRA   = no (λ ())
AUFLIRA   ≟ LIA       = no (λ ())
AUFLIRA   ≟ AUFLIRA   = yes refl
AUFLIRA   ≟ ALIA      = no (λ ())
AUFLIRA   ≟ AUFLIA    = no (λ ())
AUFLIRA   ≟ QF-ALIA   = no (λ ())
AUFLIRA   ≟ QF-AUFLIA = no (λ ())
AUFLIRA   ≟ QF-UFIDL  = no (λ ())
AUFLIRA   ≟ QF-UFLIA  = no (λ ())
AUFLIRA   ≟ QF-UFNIA  = no (λ ())
AUFLIRA   ≟ QF-UF     = no (λ ())
AUFLIRA   ≟ QF-UFLRA  = no (λ ())
AUFLIRA   ≟ UFLRA     = no (λ ())
AUFLIRA   ≟ QF-UFNRA  = no (λ ())
AUFLIRA   ≟ QF-UFBV   = no (λ ())
AUFLIRA   ≟ QF-AUFBV  = no (λ ())
AUFLIRA   ≟ QF-BV     = no (λ ())
AUFLIRA   ≟ QF-ABV    = no (λ ())
AUFLIRA   ≟ QF-RDL    = no (λ ())
AUFLIRA   ≟ QF-LRA    = no (λ ())
AUFLIRA   ≟ NRA       = no (λ ())
AUFLIRA   ≟ LRA       = no (λ ())
AUFLIRA   ≟ QF-NRA    = no (λ ())
ALIA      ≟ QF-AX     = no (λ ())
ALIA      ≟ QF-IDL    = no (λ ())
ALIA      ≟ QF-LIA    = no (λ ())
ALIA      ≟ QF-NIA    = no (λ ())
ALIA      ≟ NIA       = no (λ ())
ALIA      ≟ UFNIA     = no (λ ())
ALIA      ≟ AUFNIRA   = no (λ ())
ALIA      ≟ LIA       = no (λ ())
ALIA      ≟ AUFLIRA   = no (λ ())
ALIA      ≟ ALIA      = yes refl
ALIA      ≟ AUFLIA    = no (λ ())
ALIA      ≟ QF-ALIA   = no (λ ())
ALIA      ≟ QF-AUFLIA = no (λ ())
ALIA      ≟ QF-UFIDL  = no (λ ())
ALIA      ≟ QF-UFLIA  = no (λ ())
ALIA      ≟ QF-UFNIA  = no (λ ())
ALIA      ≟ QF-UF     = no (λ ())
ALIA      ≟ QF-UFLRA  = no (λ ())
ALIA      ≟ UFLRA     = no (λ ())
ALIA      ≟ QF-UFNRA  = no (λ ())
ALIA      ≟ QF-UFBV   = no (λ ())
ALIA      ≟ QF-AUFBV  = no (λ ())
ALIA      ≟ QF-BV     = no (λ ())
ALIA      ≟ QF-ABV    = no (λ ())
ALIA      ≟ QF-RDL    = no (λ ())
ALIA      ≟ QF-LRA    = no (λ ())
ALIA      ≟ NRA       = no (λ ())
ALIA      ≟ LRA       = no (λ ())
ALIA      ≟ QF-NRA    = no (λ ())
AUFLIA    ≟ QF-AX     = no (λ ())
AUFLIA    ≟ QF-IDL    = no (λ ())
AUFLIA    ≟ QF-LIA    = no (λ ())
AUFLIA    ≟ QF-NIA    = no (λ ())
AUFLIA    ≟ NIA       = no (λ ())
AUFLIA    ≟ UFNIA     = no (λ ())
AUFLIA    ≟ AUFNIRA   = no (λ ())
AUFLIA    ≟ LIA       = no (λ ())
AUFLIA    ≟ AUFLIRA   = no (λ ())
AUFLIA    ≟ ALIA      = no (λ ())
AUFLIA    ≟ AUFLIA    = yes refl
AUFLIA    ≟ QF-ALIA   = no (λ ())
AUFLIA    ≟ QF-AUFLIA = no (λ ())
AUFLIA    ≟ QF-UFIDL  = no (λ ())
AUFLIA    ≟ QF-UFLIA  = no (λ ())
AUFLIA    ≟ QF-UFNIA  = no (λ ())
AUFLIA    ≟ QF-UF     = no (λ ())
AUFLIA    ≟ QF-UFLRA  = no (λ ())
AUFLIA    ≟ UFLRA     = no (λ ())
AUFLIA    ≟ QF-UFNRA  = no (λ ())
AUFLIA    ≟ QF-UFBV   = no (λ ())
AUFLIA    ≟ QF-AUFBV  = no (λ ())
AUFLIA    ≟ QF-BV     = no (λ ())
AUFLIA    ≟ QF-ABV    = no (λ ())
AUFLIA    ≟ QF-RDL    = no (λ ())
AUFLIA    ≟ QF-LRA    = no (λ ())
AUFLIA    ≟ NRA       = no (λ ())
AUFLIA    ≟ LRA       = no (λ ())
AUFLIA    ≟ QF-NRA    = no (λ ())
QF-ALIA   ≟ QF-AX     = no (λ ())
QF-ALIA   ≟ QF-IDL    = no (λ ())
QF-ALIA   ≟ QF-LIA    = no (λ ())
QF-ALIA   ≟ QF-NIA    = no (λ ())
QF-ALIA   ≟ NIA       = no (λ ())
QF-ALIA   ≟ UFNIA     = no (λ ())
QF-ALIA   ≟ AUFNIRA   = no (λ ())
QF-ALIA   ≟ LIA       = no (λ ())
QF-ALIA   ≟ AUFLIRA   = no (λ ())
QF-ALIA   ≟ ALIA      = no (λ ())
QF-ALIA   ≟ AUFLIA    = no (λ ())
QF-ALIA   ≟ QF-ALIA   = yes refl
QF-ALIA   ≟ QF-AUFLIA = no (λ ())
QF-ALIA   ≟ QF-UFIDL  = no (λ ())
QF-ALIA   ≟ QF-UFLIA  = no (λ ())
QF-ALIA   ≟ QF-UFNIA  = no (λ ())
QF-ALIA   ≟ QF-UF     = no (λ ())
QF-ALIA   ≟ QF-UFLRA  = no (λ ())
QF-ALIA   ≟ UFLRA     = no (λ ())
QF-ALIA   ≟ QF-UFNRA  = no (λ ())
QF-ALIA   ≟ QF-UFBV   = no (λ ())
QF-ALIA   ≟ QF-AUFBV  = no (λ ())
QF-ALIA   ≟ QF-BV     = no (λ ())
QF-ALIA   ≟ QF-ABV    = no (λ ())
QF-ALIA   ≟ QF-RDL    = no (λ ())
QF-ALIA   ≟ QF-LRA    = no (λ ())
QF-ALIA   ≟ NRA       = no (λ ())
QF-ALIA   ≟ LRA       = no (λ ())
QF-ALIA   ≟ QF-NRA    = no (λ ())
QF-AUFLIA ≟ QF-AX     = no (λ ())
QF-AUFLIA ≟ QF-IDL    = no (λ ())
QF-AUFLIA ≟ QF-LIA    = no (λ ())
QF-AUFLIA ≟ QF-NIA    = no (λ ())
QF-AUFLIA ≟ NIA       = no (λ ())
QF-AUFLIA ≟ UFNIA     = no (λ ())
QF-AUFLIA ≟ AUFNIRA   = no (λ ())
QF-AUFLIA ≟ LIA       = no (λ ())
QF-AUFLIA ≟ AUFLIRA   = no (λ ())
QF-AUFLIA ≟ ALIA      = no (λ ())
QF-AUFLIA ≟ AUFLIA    = no (λ ())
QF-AUFLIA ≟ QF-ALIA   = no (λ ())
QF-AUFLIA ≟ QF-AUFLIA = yes refl
QF-AUFLIA ≟ QF-UFIDL  = no (λ ())
QF-AUFLIA ≟ QF-UFLIA  = no (λ ())
QF-AUFLIA ≟ QF-UFNIA  = no (λ ())
QF-AUFLIA ≟ QF-UF     = no (λ ())
QF-AUFLIA ≟ QF-UFLRA  = no (λ ())
QF-AUFLIA ≟ UFLRA     = no (λ ())
QF-AUFLIA ≟ QF-UFNRA  = no (λ ())
QF-AUFLIA ≟ QF-UFBV   = no (λ ())
QF-AUFLIA ≟ QF-AUFBV  = no (λ ())
QF-AUFLIA ≟ QF-BV     = no (λ ())
QF-AUFLIA ≟ QF-ABV    = no (λ ())
QF-AUFLIA ≟ QF-RDL    = no (λ ())
QF-AUFLIA ≟ QF-LRA    = no (λ ())
QF-AUFLIA ≟ NRA       = no (λ ())
QF-AUFLIA ≟ LRA       = no (λ ())
QF-AUFLIA ≟ QF-NRA    = no (λ ())
QF-UFIDL  ≟ QF-AX     = no (λ ())
QF-UFIDL  ≟ QF-IDL    = no (λ ())
QF-UFIDL  ≟ QF-LIA    = no (λ ())
QF-UFIDL  ≟ QF-NIA    = no (λ ())
QF-UFIDL  ≟ NIA       = no (λ ())
QF-UFIDL  ≟ UFNIA     = no (λ ())
QF-UFIDL  ≟ AUFNIRA   = no (λ ())
QF-UFIDL  ≟ LIA       = no (λ ())
QF-UFIDL  ≟ AUFLIRA   = no (λ ())
QF-UFIDL  ≟ ALIA      = no (λ ())
QF-UFIDL  ≟ AUFLIA    = no (λ ())
QF-UFIDL  ≟ QF-ALIA   = no (λ ())
QF-UFIDL  ≟ QF-AUFLIA = no (λ ())
QF-UFIDL  ≟ QF-UFIDL  = yes refl
QF-UFIDL  ≟ QF-UFLIA  = no (λ ())
QF-UFIDL  ≟ QF-UFNIA  = no (λ ())
QF-UFIDL  ≟ QF-UF     = no (λ ())
QF-UFIDL  ≟ QF-UFLRA  = no (λ ())
QF-UFIDL  ≟ UFLRA     = no (λ ())
QF-UFIDL  ≟ QF-UFNRA  = no (λ ())
QF-UFIDL  ≟ QF-UFBV   = no (λ ())
QF-UFIDL  ≟ QF-AUFBV  = no (λ ())
QF-UFIDL  ≟ QF-BV     = no (λ ())
QF-UFIDL  ≟ QF-ABV    = no (λ ())
QF-UFIDL  ≟ QF-RDL    = no (λ ())
QF-UFIDL  ≟ QF-LRA    = no (λ ())
QF-UFIDL  ≟ NRA       = no (λ ())
QF-UFIDL  ≟ LRA       = no (λ ())
QF-UFIDL  ≟ QF-NRA    = no (λ ())
QF-UFLIA  ≟ QF-AX     = no (λ ())
QF-UFLIA  ≟ QF-IDL    = no (λ ())
QF-UFLIA  ≟ QF-LIA    = no (λ ())
QF-UFLIA  ≟ QF-NIA    = no (λ ())
QF-UFLIA  ≟ NIA       = no (λ ())
QF-UFLIA  ≟ UFNIA     = no (λ ())
QF-UFLIA  ≟ AUFNIRA   = no (λ ())
QF-UFLIA  ≟ LIA       = no (λ ())
QF-UFLIA  ≟ AUFLIRA   = no (λ ())
QF-UFLIA  ≟ ALIA      = no (λ ())
QF-UFLIA  ≟ AUFLIA    = no (λ ())
QF-UFLIA  ≟ QF-ALIA   = no (λ ())
QF-UFLIA  ≟ QF-AUFLIA = no (λ ())
QF-UFLIA  ≟ QF-UFIDL  = no (λ ())
QF-UFLIA  ≟ QF-UFLIA  = yes refl
QF-UFLIA  ≟ QF-UFNIA  = no (λ ())
QF-UFLIA  ≟ QF-UF     = no (λ ())
QF-UFLIA  ≟ QF-UFLRA  = no (λ ())
QF-UFLIA  ≟ UFLRA     = no (λ ())
QF-UFLIA  ≟ QF-UFNRA  = no (λ ())
QF-UFLIA  ≟ QF-UFBV   = no (λ ())
QF-UFLIA  ≟ QF-AUFBV  = no (λ ())
QF-UFLIA  ≟ QF-BV     = no (λ ())
QF-UFLIA  ≟ QF-ABV    = no (λ ())
QF-UFLIA  ≟ QF-RDL    = no (λ ())
QF-UFLIA  ≟ QF-LRA    = no (λ ())
QF-UFLIA  ≟ NRA       = no (λ ())
QF-UFLIA  ≟ LRA       = no (λ ())
QF-UFLIA  ≟ QF-NRA    = no (λ ())
QF-UFNIA  ≟ QF-AX     = no (λ ())
QF-UFNIA  ≟ QF-IDL    = no (λ ())
QF-UFNIA  ≟ QF-LIA    = no (λ ())
QF-UFNIA  ≟ QF-NIA    = no (λ ())
QF-UFNIA  ≟ NIA       = no (λ ())
QF-UFNIA  ≟ UFNIA     = no (λ ())
QF-UFNIA  ≟ AUFNIRA   = no (λ ())
QF-UFNIA  ≟ LIA       = no (λ ())
QF-UFNIA  ≟ AUFLIRA   = no (λ ())
QF-UFNIA  ≟ ALIA      = no (λ ())
QF-UFNIA  ≟ AUFLIA    = no (λ ())
QF-UFNIA  ≟ QF-ALIA   = no (λ ())
QF-UFNIA  ≟ QF-AUFLIA = no (λ ())
QF-UFNIA  ≟ QF-UFIDL  = no (λ ())
QF-UFNIA  ≟ QF-UFLIA  = no (λ ())
QF-UFNIA  ≟ QF-UFNIA  = yes refl
QF-UFNIA  ≟ QF-UF     = no (λ ())
QF-UFNIA  ≟ QF-UFLRA  = no (λ ())
QF-UFNIA  ≟ UFLRA     = no (λ ())
QF-UFNIA  ≟ QF-UFNRA  = no (λ ())
QF-UFNIA  ≟ QF-UFBV   = no (λ ())
QF-UFNIA  ≟ QF-AUFBV  = no (λ ())
QF-UFNIA  ≟ QF-BV     = no (λ ())
QF-UFNIA  ≟ QF-ABV    = no (λ ())
QF-UFNIA  ≟ QF-RDL    = no (λ ())
QF-UFNIA  ≟ QF-LRA    = no (λ ())
QF-UFNIA  ≟ NRA       = no (λ ())
QF-UFNIA  ≟ LRA       = no (λ ())
QF-UFNIA  ≟ QF-NRA    = no (λ ())
QF-UF     ≟ QF-AX     = no (λ ())
QF-UF     ≟ QF-IDL    = no (λ ())
QF-UF     ≟ QF-LIA    = no (λ ())
QF-UF     ≟ QF-NIA    = no (λ ())
QF-UF     ≟ NIA       = no (λ ())
QF-UF     ≟ UFNIA     = no (λ ())
QF-UF     ≟ AUFNIRA   = no (λ ())
QF-UF     ≟ LIA       = no (λ ())
QF-UF     ≟ AUFLIRA   = no (λ ())
QF-UF     ≟ ALIA      = no (λ ())
QF-UF     ≟ AUFLIA    = no (λ ())
QF-UF     ≟ QF-ALIA   = no (λ ())
QF-UF     ≟ QF-AUFLIA = no (λ ())
QF-UF     ≟ QF-UFIDL  = no (λ ())
QF-UF     ≟ QF-UFLIA  = no (λ ())
QF-UF     ≟ QF-UFNIA  = no (λ ())
QF-UF     ≟ QF-UF     = yes refl
QF-UF     ≟ QF-UFLRA  = no (λ ())
QF-UF     ≟ UFLRA     = no (λ ())
QF-UF     ≟ QF-UFNRA  = no (λ ())
QF-UF     ≟ QF-UFBV   = no (λ ())
QF-UF     ≟ QF-AUFBV  = no (λ ())
QF-UF     ≟ QF-BV     = no (λ ())
QF-UF     ≟ QF-ABV    = no (λ ())
QF-UF     ≟ QF-RDL    = no (λ ())
QF-UF     ≟ QF-LRA    = no (λ ())
QF-UF     ≟ NRA       = no (λ ())
QF-UF     ≟ LRA       = no (λ ())
QF-UF     ≟ QF-NRA    = no (λ ())
QF-UFLRA  ≟ QF-AX     = no (λ ())
QF-UFLRA  ≟ QF-IDL    = no (λ ())
QF-UFLRA  ≟ QF-LIA    = no (λ ())
QF-UFLRA  ≟ QF-NIA    = no (λ ())
QF-UFLRA  ≟ NIA       = no (λ ())
QF-UFLRA  ≟ UFNIA     = no (λ ())
QF-UFLRA  ≟ AUFNIRA   = no (λ ())
QF-UFLRA  ≟ LIA       = no (λ ())
QF-UFLRA  ≟ AUFLIRA   = no (λ ())
QF-UFLRA  ≟ ALIA      = no (λ ())
QF-UFLRA  ≟ AUFLIA    = no (λ ())
QF-UFLRA  ≟ QF-ALIA   = no (λ ())
QF-UFLRA  ≟ QF-AUFLIA = no (λ ())
QF-UFLRA  ≟ QF-UFIDL  = no (λ ())
QF-UFLRA  ≟ QF-UFLIA  = no (λ ())
QF-UFLRA  ≟ QF-UFNIA  = no (λ ())
QF-UFLRA  ≟ QF-UF     = no (λ ())
QF-UFLRA  ≟ QF-UFLRA  = yes refl
QF-UFLRA  ≟ UFLRA     = no (λ ())
QF-UFLRA  ≟ QF-UFNRA  = no (λ ())
QF-UFLRA  ≟ QF-UFBV   = no (λ ())
QF-UFLRA  ≟ QF-AUFBV  = no (λ ())
QF-UFLRA  ≟ QF-BV     = no (λ ())
QF-UFLRA  ≟ QF-ABV    = no (λ ())
QF-UFLRA  ≟ QF-RDL    = no (λ ())
QF-UFLRA  ≟ QF-LRA    = no (λ ())
QF-UFLRA  ≟ NRA       = no (λ ())
QF-UFLRA  ≟ LRA       = no (λ ())
QF-UFLRA  ≟ QF-NRA    = no (λ ())
UFLRA     ≟ QF-AX     = no (λ ())
UFLRA     ≟ QF-IDL    = no (λ ())
UFLRA     ≟ QF-LIA    = no (λ ())
UFLRA     ≟ QF-NIA    = no (λ ())
UFLRA     ≟ NIA       = no (λ ())
UFLRA     ≟ UFNIA     = no (λ ())
UFLRA     ≟ AUFNIRA   = no (λ ())
UFLRA     ≟ LIA       = no (λ ())
UFLRA     ≟ AUFLIRA   = no (λ ())
UFLRA     ≟ ALIA      = no (λ ())
UFLRA     ≟ AUFLIA    = no (λ ())
UFLRA     ≟ QF-ALIA   = no (λ ())
UFLRA     ≟ QF-AUFLIA = no (λ ())
UFLRA     ≟ QF-UFIDL  = no (λ ())
UFLRA     ≟ QF-UFLIA  = no (λ ())
UFLRA     ≟ QF-UFNIA  = no (λ ())
UFLRA     ≟ QF-UF     = no (λ ())
UFLRA     ≟ QF-UFLRA  = no (λ ())
UFLRA     ≟ UFLRA     = yes refl
UFLRA     ≟ QF-UFNRA  = no (λ ())
UFLRA     ≟ QF-UFBV   = no (λ ())
UFLRA     ≟ QF-AUFBV  = no (λ ())
UFLRA     ≟ QF-BV     = no (λ ())
UFLRA     ≟ QF-ABV    = no (λ ())
UFLRA     ≟ QF-RDL    = no (λ ())
UFLRA     ≟ QF-LRA    = no (λ ())
UFLRA     ≟ NRA       = no (λ ())
UFLRA     ≟ LRA       = no (λ ())
UFLRA     ≟ QF-NRA    = no (λ ())
QF-UFNRA  ≟ QF-AX     = no (λ ())
QF-UFNRA  ≟ QF-IDL    = no (λ ())
QF-UFNRA  ≟ QF-LIA    = no (λ ())
QF-UFNRA  ≟ QF-NIA    = no (λ ())
QF-UFNRA  ≟ NIA       = no (λ ())
QF-UFNRA  ≟ UFNIA     = no (λ ())
QF-UFNRA  ≟ AUFNIRA   = no (λ ())
QF-UFNRA  ≟ LIA       = no (λ ())
QF-UFNRA  ≟ AUFLIRA   = no (λ ())
QF-UFNRA  ≟ ALIA      = no (λ ())
QF-UFNRA  ≟ AUFLIA    = no (λ ())
QF-UFNRA  ≟ QF-ALIA   = no (λ ())
QF-UFNRA  ≟ QF-AUFLIA = no (λ ())
QF-UFNRA  ≟ QF-UFIDL  = no (λ ())
QF-UFNRA  ≟ QF-UFLIA  = no (λ ())
QF-UFNRA  ≟ QF-UFNIA  = no (λ ())
QF-UFNRA  ≟ QF-UF     = no (λ ())
QF-UFNRA  ≟ QF-UFLRA  = no (λ ())
QF-UFNRA  ≟ UFLRA     = no (λ ())
QF-UFNRA  ≟ QF-UFNRA  = yes refl
QF-UFNRA  ≟ QF-UFBV   = no (λ ())
QF-UFNRA  ≟ QF-AUFBV  = no (λ ())
QF-UFNRA  ≟ QF-BV     = no (λ ())
QF-UFNRA  ≟ QF-ABV    = no (λ ())
QF-UFNRA  ≟ QF-RDL    = no (λ ())
QF-UFNRA  ≟ QF-LRA    = no (λ ())
QF-UFNRA  ≟ NRA       = no (λ ())
QF-UFNRA  ≟ LRA       = no (λ ())
QF-UFNRA  ≟ QF-NRA    = no (λ ())
QF-UFBV   ≟ QF-AX     = no (λ ())
QF-UFBV   ≟ QF-IDL    = no (λ ())
QF-UFBV   ≟ QF-LIA    = no (λ ())
QF-UFBV   ≟ QF-NIA    = no (λ ())
QF-UFBV   ≟ NIA       = no (λ ())
QF-UFBV   ≟ UFNIA     = no (λ ())
QF-UFBV   ≟ AUFNIRA   = no (λ ())
QF-UFBV   ≟ LIA       = no (λ ())
QF-UFBV   ≟ AUFLIRA   = no (λ ())
QF-UFBV   ≟ ALIA      = no (λ ())
QF-UFBV   ≟ AUFLIA    = no (λ ())
QF-UFBV   ≟ QF-ALIA   = no (λ ())
QF-UFBV   ≟ QF-AUFLIA = no (λ ())
QF-UFBV   ≟ QF-UFIDL  = no (λ ())
QF-UFBV   ≟ QF-UFLIA  = no (λ ())
QF-UFBV   ≟ QF-UFNIA  = no (λ ())
QF-UFBV   ≟ QF-UF     = no (λ ())
QF-UFBV   ≟ QF-UFLRA  = no (λ ())
QF-UFBV   ≟ UFLRA     = no (λ ())
QF-UFBV   ≟ QF-UFNRA  = no (λ ())
QF-UFBV   ≟ QF-UFBV   = yes refl
QF-UFBV   ≟ QF-AUFBV  = no (λ ())
QF-UFBV   ≟ QF-BV     = no (λ ())
QF-UFBV   ≟ QF-ABV    = no (λ ())
QF-UFBV   ≟ QF-RDL    = no (λ ())
QF-UFBV   ≟ QF-LRA    = no (λ ())
QF-UFBV   ≟ NRA       = no (λ ())
QF-UFBV   ≟ LRA       = no (λ ())
QF-UFBV   ≟ QF-NRA    = no (λ ())
QF-AUFBV  ≟ QF-AX     = no (λ ())
QF-AUFBV  ≟ QF-IDL    = no (λ ())
QF-AUFBV  ≟ QF-LIA    = no (λ ())
QF-AUFBV  ≟ QF-NIA    = no (λ ())
QF-AUFBV  ≟ NIA       = no (λ ())
QF-AUFBV  ≟ UFNIA     = no (λ ())
QF-AUFBV  ≟ AUFNIRA   = no (λ ())
QF-AUFBV  ≟ LIA       = no (λ ())
QF-AUFBV  ≟ AUFLIRA   = no (λ ())
QF-AUFBV  ≟ ALIA      = no (λ ())
QF-AUFBV  ≟ AUFLIA    = no (λ ())
QF-AUFBV  ≟ QF-ALIA   = no (λ ())
QF-AUFBV  ≟ QF-AUFLIA = no (λ ())
QF-AUFBV  ≟ QF-UFIDL  = no (λ ())
QF-AUFBV  ≟ QF-UFLIA  = no (λ ())
QF-AUFBV  ≟ QF-UFNIA  = no (λ ())
QF-AUFBV  ≟ QF-UF     = no (λ ())
QF-AUFBV  ≟ QF-UFLRA  = no (λ ())
QF-AUFBV  ≟ UFLRA     = no (λ ())
QF-AUFBV  ≟ QF-UFNRA  = no (λ ())
QF-AUFBV  ≟ QF-UFBV   = no (λ ())
QF-AUFBV  ≟ QF-AUFBV  = yes refl
QF-AUFBV  ≟ QF-BV     = no (λ ())
QF-AUFBV  ≟ QF-ABV    = no (λ ())
QF-AUFBV  ≟ QF-RDL    = no (λ ())
QF-AUFBV  ≟ QF-LRA    = no (λ ())
QF-AUFBV  ≟ NRA       = no (λ ())
QF-AUFBV  ≟ LRA       = no (λ ())
QF-AUFBV  ≟ QF-NRA    = no (λ ())
QF-BV     ≟ QF-AX     = no (λ ())
QF-BV     ≟ QF-IDL    = no (λ ())
QF-BV     ≟ QF-LIA    = no (λ ())
QF-BV     ≟ QF-NIA    = no (λ ())
QF-BV     ≟ NIA       = no (λ ())
QF-BV     ≟ UFNIA     = no (λ ())
QF-BV     ≟ AUFNIRA   = no (λ ())
QF-BV     ≟ LIA       = no (λ ())
QF-BV     ≟ AUFLIRA   = no (λ ())
QF-BV     ≟ ALIA      = no (λ ())
QF-BV     ≟ AUFLIA    = no (λ ())
QF-BV     ≟ QF-ALIA   = no (λ ())
QF-BV     ≟ QF-AUFLIA = no (λ ())
QF-BV     ≟ QF-UFIDL  = no (λ ())
QF-BV     ≟ QF-UFLIA  = no (λ ())
QF-BV     ≟ QF-UFNIA  = no (λ ())
QF-BV     ≟ QF-UF     = no (λ ())
QF-BV     ≟ QF-UFLRA  = no (λ ())
QF-BV     ≟ UFLRA     = no (λ ())
QF-BV     ≟ QF-UFNRA  = no (λ ())
QF-BV     ≟ QF-UFBV   = no (λ ())
QF-BV     ≟ QF-AUFBV  = no (λ ())
QF-BV     ≟ QF-BV     = yes refl
QF-BV     ≟ QF-ABV    = no (λ ())
QF-BV     ≟ QF-RDL    = no (λ ())
QF-BV     ≟ QF-LRA    = no (λ ())
QF-BV     ≟ NRA       = no (λ ())
QF-BV     ≟ LRA       = no (λ ())
QF-BV     ≟ QF-NRA    = no (λ ())
QF-ABV    ≟ QF-AX     = no (λ ())
QF-ABV    ≟ QF-IDL    = no (λ ())
QF-ABV    ≟ QF-LIA    = no (λ ())
QF-ABV    ≟ QF-NIA    = no (λ ())
QF-ABV    ≟ NIA       = no (λ ())
QF-ABV    ≟ UFNIA     = no (λ ())
QF-ABV    ≟ AUFNIRA   = no (λ ())
QF-ABV    ≟ LIA       = no (λ ())
QF-ABV    ≟ AUFLIRA   = no (λ ())
QF-ABV    ≟ ALIA      = no (λ ())
QF-ABV    ≟ AUFLIA    = no (λ ())
QF-ABV    ≟ QF-ALIA   = no (λ ())
QF-ABV    ≟ QF-AUFLIA = no (λ ())
QF-ABV    ≟ QF-UFIDL  = no (λ ())
QF-ABV    ≟ QF-UFLIA  = no (λ ())
QF-ABV    ≟ QF-UFNIA  = no (λ ())
QF-ABV    ≟ QF-UF     = no (λ ())
QF-ABV    ≟ QF-UFLRA  = no (λ ())
QF-ABV    ≟ UFLRA     = no (λ ())
QF-ABV    ≟ QF-UFNRA  = no (λ ())
QF-ABV    ≟ QF-UFBV   = no (λ ())
QF-ABV    ≟ QF-AUFBV  = no (λ ())
QF-ABV    ≟ QF-BV     = no (λ ())
QF-ABV    ≟ QF-ABV    = yes refl
QF-ABV    ≟ QF-RDL    = no (λ ())
QF-ABV    ≟ QF-LRA    = no (λ ())
QF-ABV    ≟ NRA       = no (λ ())
QF-ABV    ≟ LRA       = no (λ ())
QF-ABV    ≟ QF-NRA    = no (λ ())
QF-RDL    ≟ QF-AX     = no (λ ())
QF-RDL    ≟ QF-IDL    = no (λ ())
QF-RDL    ≟ QF-LIA    = no (λ ())
QF-RDL    ≟ QF-NIA    = no (λ ())
QF-RDL    ≟ NIA       = no (λ ())
QF-RDL    ≟ UFNIA     = no (λ ())
QF-RDL    ≟ AUFNIRA   = no (λ ())
QF-RDL    ≟ LIA       = no (λ ())
QF-RDL    ≟ AUFLIRA   = no (λ ())
QF-RDL    ≟ ALIA      = no (λ ())
QF-RDL    ≟ AUFLIA    = no (λ ())
QF-RDL    ≟ QF-ALIA   = no (λ ())
QF-RDL    ≟ QF-AUFLIA = no (λ ())
QF-RDL    ≟ QF-UFIDL  = no (λ ())
QF-RDL    ≟ QF-UFLIA  = no (λ ())
QF-RDL    ≟ QF-UFNIA  = no (λ ())
QF-RDL    ≟ QF-UF     = no (λ ())
QF-RDL    ≟ QF-UFLRA  = no (λ ())
QF-RDL    ≟ UFLRA     = no (λ ())
QF-RDL    ≟ QF-UFNRA  = no (λ ())
QF-RDL    ≟ QF-UFBV   = no (λ ())
QF-RDL    ≟ QF-AUFBV  = no (λ ())
QF-RDL    ≟ QF-BV     = no (λ ())
QF-RDL    ≟ QF-ABV    = no (λ ())
QF-RDL    ≟ QF-RDL    = yes refl
QF-RDL    ≟ QF-LRA    = no (λ ())
QF-RDL    ≟ NRA       = no (λ ())
QF-RDL    ≟ LRA       = no (λ ())
QF-RDL    ≟ QF-NRA    = no (λ ())
QF-LRA    ≟ QF-AX     = no (λ ())
QF-LRA    ≟ QF-IDL    = no (λ ())
QF-LRA    ≟ QF-LIA    = no (λ ())
QF-LRA    ≟ QF-NIA    = no (λ ())
QF-LRA    ≟ NIA       = no (λ ())
QF-LRA    ≟ UFNIA     = no (λ ())
QF-LRA    ≟ AUFNIRA   = no (λ ())
QF-LRA    ≟ LIA       = no (λ ())
QF-LRA    ≟ AUFLIRA   = no (λ ())
QF-LRA    ≟ ALIA      = no (λ ())
QF-LRA    ≟ AUFLIA    = no (λ ())
QF-LRA    ≟ QF-ALIA   = no (λ ())
QF-LRA    ≟ QF-AUFLIA = no (λ ())
QF-LRA    ≟ QF-UFIDL  = no (λ ())
QF-LRA    ≟ QF-UFLIA  = no (λ ())
QF-LRA    ≟ QF-UFNIA  = no (λ ())
QF-LRA    ≟ QF-UF     = no (λ ())
QF-LRA    ≟ QF-UFLRA  = no (λ ())
QF-LRA    ≟ UFLRA     = no (λ ())
QF-LRA    ≟ QF-UFNRA  = no (λ ())
QF-LRA    ≟ QF-UFBV   = no (λ ())
QF-LRA    ≟ QF-AUFBV  = no (λ ())
QF-LRA    ≟ QF-BV     = no (λ ())
QF-LRA    ≟ QF-ABV    = no (λ ())
QF-LRA    ≟ QF-RDL    = no (λ ())
QF-LRA    ≟ QF-LRA    = yes refl
QF-LRA    ≟ NRA       = no (λ ())
QF-LRA    ≟ LRA       = no (λ ())
QF-LRA    ≟ QF-NRA    = no (λ ())
NRA       ≟ QF-AX     = no (λ ())
NRA       ≟ QF-IDL    = no (λ ())
NRA       ≟ QF-LIA    = no (λ ())
NRA       ≟ QF-NIA    = no (λ ())
NRA       ≟ NIA       = no (λ ())
NRA       ≟ UFNIA     = no (λ ())
NRA       ≟ AUFNIRA   = no (λ ())
NRA       ≟ LIA       = no (λ ())
NRA       ≟ AUFLIRA   = no (λ ())
NRA       ≟ ALIA      = no (λ ())
NRA       ≟ AUFLIA    = no (λ ())
NRA       ≟ QF-ALIA   = no (λ ())
NRA       ≟ QF-AUFLIA = no (λ ())
NRA       ≟ QF-UFIDL  = no (λ ())
NRA       ≟ QF-UFLIA  = no (λ ())
NRA       ≟ QF-UFNIA  = no (λ ())
NRA       ≟ QF-UF     = no (λ ())
NRA       ≟ QF-UFLRA  = no (λ ())
NRA       ≟ UFLRA     = no (λ ())
NRA       ≟ QF-UFNRA  = no (λ ())
NRA       ≟ QF-UFBV   = no (λ ())
NRA       ≟ QF-AUFBV  = no (λ ())
NRA       ≟ QF-BV     = no (λ ())
NRA       ≟ QF-ABV    = no (λ ())
NRA       ≟ QF-RDL    = no (λ ())
NRA       ≟ QF-LRA    = no (λ ())
NRA       ≟ NRA       = yes refl
NRA       ≟ LRA       = no (λ ())
NRA       ≟ QF-NRA    = no (λ ())
LRA       ≟ QF-AX     = no (λ ())
LRA       ≟ QF-IDL    = no (λ ())
LRA       ≟ QF-LIA    = no (λ ())
LRA       ≟ QF-NIA    = no (λ ())
LRA       ≟ NIA       = no (λ ())
LRA       ≟ UFNIA     = no (λ ())
LRA       ≟ AUFNIRA   = no (λ ())
LRA       ≟ LIA       = no (λ ())
LRA       ≟ AUFLIRA   = no (λ ())
LRA       ≟ ALIA      = no (λ ())
LRA       ≟ AUFLIA    = no (λ ())
LRA       ≟ QF-ALIA   = no (λ ())
LRA       ≟ QF-AUFLIA = no (λ ())
LRA       ≟ QF-UFIDL  = no (λ ())
LRA       ≟ QF-UFLIA  = no (λ ())
LRA       ≟ QF-UFNIA  = no (λ ())
LRA       ≟ QF-UF     = no (λ ())
LRA       ≟ QF-UFLRA  = no (λ ())
LRA       ≟ UFLRA     = no (λ ())
LRA       ≟ QF-UFNRA  = no (λ ())
LRA       ≟ QF-UFBV   = no (λ ())
LRA       ≟ QF-AUFBV  = no (λ ())
LRA       ≟ QF-BV     = no (λ ())
LRA       ≟ QF-ABV    = no (λ ())
LRA       ≟ QF-RDL    = no (λ ())
LRA       ≟ QF-LRA    = no (λ ())
LRA       ≟ NRA       = no (λ ())
LRA       ≟ LRA       = yes refl
LRA       ≟ QF-NRA    = no (λ ())
QF-NRA    ≟ QF-AX     = no (λ ())
QF-NRA    ≟ QF-IDL    = no (λ ())
QF-NRA    ≟ QF-LIA    = no (λ ())
QF-NRA    ≟ QF-NIA    = no (λ ())
QF-NRA    ≟ NIA       = no (λ ())
QF-NRA    ≟ UFNIA     = no (λ ())
QF-NRA    ≟ AUFNIRA   = no (λ ())
QF-NRA    ≟ LIA       = no (λ ())
QF-NRA    ≟ AUFLIRA   = no (λ ())
QF-NRA    ≟ ALIA      = no (λ ())
QF-NRA    ≟ AUFLIA    = no (λ ())
QF-NRA    ≟ QF-ALIA   = no (λ ())
QF-NRA    ≟ QF-AUFLIA = no (λ ())
QF-NRA    ≟ QF-UFIDL  = no (λ ())
QF-NRA    ≟ QF-UFLIA  = no (λ ())
QF-NRA    ≟ QF-UFNIA  = no (λ ())
QF-NRA    ≟ QF-UF     = no (λ ())
QF-NRA    ≟ QF-UFLRA  = no (λ ())
QF-NRA    ≟ UFLRA     = no (λ ())
QF-NRA    ≟ QF-UFNRA  = no (λ ())
QF-NRA    ≟ QF-UFBV   = no (λ ())
QF-NRA    ≟ QF-AUFBV  = no (λ ())
QF-NRA    ≟ QF-BV     = no (λ ())
QF-NRA    ≟ QF-ABV    = no (λ ())
QF-NRA    ≟ QF-RDL    = no (λ ())
QF-NRA    ≟ QF-LRA    = no (λ ())
QF-NRA    ≟ NRA       = no (λ ())
QF-NRA    ≟ LRA       = no (λ ())
QF-NRA    ≟ QF-NRA    = yes refl

QF-LIA⇾⁺ : ¬ QF-LIA ⇾ l
         → Dec (QF-NIA ⇾⁺ l ⊎ LIA ⇾⁺ l ⊎ QF-ALIA ⇾⁺ l ⊎ QF-UFLIA ⇾⁺ l)
         → Dec (QF-LIA ⇾⁺ l)
QF-LIA⇾⁺ {l} ¬⇾l = Dec.map (equivalence to from)
  where
  to = [ QF-LIA⇾QF-NIA ∷_ , [ QF-LIA⇾LIA ∷_ , [ QF-LIA⇾QF-ALIA ∷_ , QF-LIA⇾QF-UFLIA ∷_ ]′ ]′ ]′
  from : (QF-LIA ⇾⁺ l) → (QF-NIA ⇾⁺ l ⊎ LIA ⇾⁺ l ⊎ QF-ALIA ⇾⁺ l ⊎ QF-UFLIA ⇾⁺ l)
  from [ p ] = ⊥-elim (¬⇾l p)
  from (QF-LIA⇾QF-NIA   ∷ p) = inj₁ p
  from (QF-LIA⇾LIA      ∷ p) = inj₂ (inj₁ p)
  from (QF-LIA⇾QF-ALIA  ∷ p) = inj₂ (inj₂ (inj₁ p))
  from (QF-LIA⇾QF-UFLIA ∷ p) = inj₂ (inj₂ (inj₂ p))


infix 4 _⇾⁺?_

-- |Decision procedure for the transitive closure of the ⇾-relation.
--
--  NOTE: Walks down all possible paths in the graph from l₁ and checks
--        if it encounters l₃ at any point. May traverse certain nodes
--        multiple times. I've marked this function as TERMINATING, since
--        each step is guarded by a step along the ⇾-relation, and we've
--        already shown that ⇾ and ⇾⁺ are well-founded.
--
{-# TERMINATING #-}
_⇾⁺?_ : (l₁ l₃ : Logic) → Dec (l₁ ⇾⁺ l₃)
l₁ ⇾⁺? l₃ with l₁ ⇾? l₃
l₁ ⇾⁺? l₃ | yes l₁⇾l₃ = yes [ l₁⇾l₃ ]

QF-AX     ⇾⁺? l₃ | no ¬l₁⇾l₃
  = no λ { [ () ] ; (() ∷ _) }

QF-IDL    ⇾⁺? l₃ | no ¬l₁⇾l₃
  = Dec.map (equivalence to from) (QF-LIA ⇾⁺? l₃ ⊎-dec QF-UFIDL ⇾⁺? l₃)
  where
    to = [ QF-IDL⇾QF-LIA ∷_ , QF-IDL⇾QF-UFIDL ∷_ ]′
    from : (QF-IDL ⇾⁺ l₃) → (QF-LIA ⇾⁺ l₃ ⊎ QF-UFIDL ⇾⁺ l₃)
    from [ p ] = ⊥-elim (¬l₁⇾l₃ p)
    from (QF-IDL⇾QF-LIA   ∷ p) = inj₁ p
    from (QF-IDL⇾QF-UFIDL ∷ p) = inj₂ p

QF-LIA ⇾⁺? l₃ | no ¬l₁⇾l₃
  = Dec.map (equivalence to from) (QF-NIA ⇾⁺? l₃ ⊎-dec LIA ⇾⁺? l₃ ⊎-dec QF-ALIA ⇾⁺? l₃ ⊎-dec QF-UFLIA ⇾⁺? l₃)
  where
    to = [ QF-LIA⇾QF-NIA ∷_ , [ QF-LIA⇾LIA ∷_ , [ QF-LIA⇾QF-ALIA ∷_ , QF-LIA⇾QF-UFLIA ∷_ ]′ ]′ ]′
    from : (QF-LIA ⇾⁺ l₃) → (QF-NIA ⇾⁺ l₃ ⊎ LIA ⇾⁺ l₃ ⊎ QF-ALIA ⇾⁺ l₃ ⊎ QF-UFLIA ⇾⁺ l₃)
    from [ p ] = ⊥-elim (¬l₁⇾l₃ p)
    from (QF-LIA⇾QF-NIA   ∷ p) = inj₁ p
    from (QF-LIA⇾LIA      ∷ p) = inj₂ (inj₁ p)
    from (QF-LIA⇾QF-ALIA  ∷ p) = inj₂ (inj₂ (inj₁ p))
    from (QF-LIA⇾QF-UFLIA ∷ p) = inj₂ (inj₂ (inj₂ p))

QF-NIA    ⇾⁺? l₃ | no ¬l₁⇾l₃
  = Dec.map (equivalence
            (QF-NIA⇾NIA ∷_)
            (λ { [ l₁⇾l₃ ] → ⊥-elim (¬l₁⇾l₃ l₁⇾l₃) ; (QF-NIA⇾NIA ∷ p) → p}))
            (NIA ⇾⁺? l₃)

NIA       ⇾⁺? l₃ | no ¬l₁⇾l₃
  = Dec.map (equivalence
            (NIA⇾UFNIA ∷_)
            (λ { [ l₁⇾l₃ ] → ⊥-elim (¬l₁⇾l₃ l₁⇾l₃) ; (NIA⇾UFNIA ∷ p) → p}))
            (UFNIA ⇾⁺? l₃)

UFNIA     ⇾⁺? l₃ | no ¬l₁⇾l₃
  = Dec.map (equivalence
            (UFNIA⇾AUFNIRA ∷_)
            (λ { [ l₁⇾l₃ ] → ⊥-elim (¬l₁⇾l₃ l₁⇾l₃) ; (UFNIA⇾AUFNIRA ∷ p) → p}))
            (AUFNIRA ⇾⁺? l₃)

AUFNIRA   ⇾⁺? l₃ | no ¬l₁⇾l₃
  = no λ { [ () ] ; (() ∷ _) }

LIA       ⇾⁺? l₃ | no ¬l₁⇾l₃
  = Dec.map (equivalence to from) (NIA ⇾⁺? l₃ ⊎-dec AUFLIRA ⇾⁺? l₃ ⊎-dec ALIA ⇾⁺? l₃)
  where
    to = [ LIA⇾NIA ∷_ , [ LIA⇾AUFLIRA ∷_ , LIA⇾ALIA ∷_ ]′ ]′
    from : (LIA ⇾⁺ l₃) → (NIA ⇾⁺ l₃ ⊎ AUFLIRA ⇾⁺ l₃ ⊎ ALIA ⇾⁺ l₃)
    from [ l₁⇾l₃ ] = ⊥-elim (¬l₁⇾l₃ l₁⇾l₃ )
    from (LIA⇾NIA     ∷ p) = inj₁ p
    from (LIA⇾AUFLIRA ∷ p) = inj₂ (inj₁ p)
    from (LIA⇾ALIA    ∷ p) = inj₂ (inj₂ p)

AUFLIRA   ⇾⁺? l₃ | no ¬l₁⇾l₃
  = Dec.map (equivalence
            (AUFLIRA⇾AUFNIRA ∷_)
            (λ { [ l₁⇾l₃ ] → ⊥-elim (¬l₁⇾l₃ l₁⇾l₃) ; (AUFLIRA⇾AUFNIRA ∷ p) → p}))
            (AUFNIRA ⇾⁺? l₃)

ALIA      ⇾⁺? l₃ | no ¬l₁⇾l₃
  = Dec.map (equivalence
            (ALIA⇾AUFLIA ∷_)
            (λ { [ l₁⇾l₃ ] → ⊥-elim (¬l₁⇾l₃ l₁⇾l₃) ; (ALIA⇾AUFLIA ∷ p) → p}))
            (AUFLIA ⇾⁺? l₃)

AUFLIA    ⇾⁺? l₃ | no ¬l₁⇾l₃
  = no λ { [ () ] ; (() ∷ _) }

QF-ALIA   ⇾⁺? l₃ | no ¬l₁⇾l₃
  = Dec.map (equivalence to from) (ALIA ⇾⁺? l₃ ⊎-dec QF-AUFLIA ⇾⁺? l₃)
  where
    to = [ QF-ALIA⇾ALIA ∷_ , QF-ALIA⇾QF-AUFLIA ∷_ ]′
    from : (QF-ALIA ⇾⁺ l₃) → (ALIA ⇾⁺ l₃ ⊎ QF-AUFLIA ⇾⁺ l₃)
    from [ l₁⇾l₃ ] = ⊥-elim (¬l₁⇾l₃ l₁⇾l₃)
    from (QF-ALIA⇾ALIA      ∷ p) = inj₁ p
    from (QF-ALIA⇾QF-AUFLIA ∷ p) = inj₂ p

QF-AUFLIA ⇾⁺? l₃ | no ¬l₁⇾l₃
  = Dec.map (equivalence
            (QF-AUFLIA⇾AUFLIA ∷_)
            (λ { [ l₁⇾l₃ ] → ⊥-elim (¬l₁⇾l₃ l₁⇾l₃) ; (QF-AUFLIA⇾AUFLIA ∷ p) → p}))
            (AUFLIA ⇾⁺? l₃)

QF-UFIDL  ⇾⁺? l₃ | no ¬l₁⇾l₃
  = Dec.map (equivalence
            (QF-UFIDL⇾QF-UFLIA ∷_)
            (λ { [ l₁⇾l₃ ] → ⊥-elim (¬l₁⇾l₃ l₁⇾l₃) ; (QF-UFIDL⇾QF-UFLIA ∷ p) → p}))
            (QF-UFLIA ⇾⁺? l₃)

QF-UFLIA  ⇾⁺? l₃ | no ¬l₁⇾l₃
  = Dec.map (equivalence to from) (QF-AUFLIA ⇾⁺? l₃ ⊎-dec QF-UFNIA ⇾⁺? l₃)
  where
    to = [ QF-UFLIA⇾QF-AUFLIA ∷_ , QF-UFLIA⇾QF-UFNIA ∷_ ]′
    from : (QF-UFLIA ⇾⁺ l₃) → (QF-AUFLIA ⇾⁺ l₃ ⊎ QF-UFNIA ⇾⁺ l₃)
    from [ l₁⇾l₃ ] = ⊥-elim (¬l₁⇾l₃ l₁⇾l₃)
    from (QF-UFLIA⇾QF-AUFLIA ∷ p) = inj₁ p
    from (QF-UFLIA⇾QF-UFNIA  ∷ p) = inj₂ p

QF-UFNIA  ⇾⁺? l₃ | no ¬l₁⇾l₃
  = Dec.map (equivalence
            (QF-UFNIA⇾UFNIA ∷_)
            (λ { [ l₁⇾l₃ ] → ⊥-elim (¬l₁⇾l₃ l₁⇾l₃) ; (QF-UFNIA⇾UFNIA ∷ p) → p}))
            (UFNIA ⇾⁺? l₃)

QF-UF     ⇾⁺? l₃ | no ¬l₁⇾l₃
  = Dec.map (equivalence to from) (QF-UFIDL ⇾⁺? l₃ ⊎-dec QF-UFLRA ⇾⁺? l₃ ⊎-dec QF-UFBV ⇾⁺? l₃)
  where
    to = [ QF-UF⇾QF-UFIDL ∷_ , [ QF-UF⇾QF-UFLRA ∷_ , QF-UF⇾QF-UFBV ∷_ ]′ ]′
    from : (QF-UF ⇾⁺ l₃) → (QF-UFIDL ⇾⁺ l₃ ⊎ QF-UFLRA ⇾⁺ l₃ ⊎ QF-UFBV ⇾⁺ l₃)
    from [ l₁⇾l₃ ] = ⊥-elim (¬l₁⇾l₃ l₁⇾l₃ )
    from (QF-UF⇾QF-UFIDL ∷ p) = inj₁ p
    from (QF-UF⇾QF-UFLRA ∷ p) = inj₂ (inj₁ p)
    from (QF-UF⇾QF-UFBV  ∷ p) = inj₂ (inj₂ p)

QF-UFLRA  ⇾⁺? l₃ | no ¬l₁⇾l₃
  = Dec.map (equivalence to from) (UFLRA ⇾⁺? l₃ ⊎-dec QF-UFNRA ⇾⁺? l₃)
  where
    to = [ QF-UFLRA⇾UFLRA ∷_ , QF-UFLRA⇾QF-UFNRA ∷_ ]′
    from : (QF-UFLRA ⇾⁺ l₃) → (UFLRA ⇾⁺ l₃ ⊎ QF-UFNRA ⇾⁺ l₃)
    from [ l₁⇾l₃ ] = ⊥-elim (¬l₁⇾l₃ l₁⇾l₃)
    from (QF-UFLRA⇾UFLRA ∷ p) = inj₁ p
    from (QF-UFLRA⇾QF-UFNRA  ∷ p) = inj₂ p

UFLRA     ⇾⁺? l₃ | no ¬l₁⇾l₃
  = Dec.map (equivalence
            (UFLRA⇾AUFLIRA ∷_)
            (λ { [ l₁⇾l₃ ] → ⊥-elim (¬l₁⇾l₃ l₁⇾l₃) ; (UFLRA⇾AUFLIRA ∷ p) → p}))
            (AUFLIRA ⇾⁺? l₃)

QF-UFNRA  ⇾⁺? l₃ | no ¬l₁⇾l₃
  = Dec.map (equivalence
            (QF-UFNRA⇾AUFNIRA ∷_)
            (λ { [ l₁⇾l₃ ] → ⊥-elim (¬l₁⇾l₃ l₁⇾l₃) ; (QF-UFNRA⇾AUFNIRA ∷ p) → p}))
            (AUFNIRA ⇾⁺? l₃)

QF-UFBV   ⇾⁺? l₃ | no ¬l₁⇾l₃
  = Dec.map (equivalence
            (QF-UFBV⇾QF-AUFBV ∷_)
            (λ { [ l₁⇾l₃ ] → ⊥-elim (¬l₁⇾l₃ l₁⇾l₃) ; (QF-UFBV⇾QF-AUFBV ∷ p) → p}))
            (QF-AUFBV ⇾⁺? l₃)

QF-AUFBV  ⇾⁺? l₃ | no ¬l₁⇾l₃
  = no λ { [ () ] ; (() ∷ _) }

QF-BV     ⇾⁺? l₃ | no ¬l₁⇾l₃
  = Dec.map (equivalence to from) (QF-UFBV ⇾⁺? l₃ ⊎-dec QF-ABV ⇾⁺? l₃)
  where
    to = [ QF-BV⇾QF-UFBV ∷_ , QF-BV⇾QF-ABV ∷_ ]′
    from : (QF-BV ⇾⁺ l₃) → (QF-UFBV ⇾⁺ l₃ ⊎ QF-ABV ⇾⁺ l₃)
    from [ l₁⇾l₃ ] = ⊥-elim (¬l₁⇾l₃ l₁⇾l₃)
    from (QF-BV⇾QF-UFBV ∷ p) = inj₁ p
    from (QF-BV⇾QF-ABV  ∷ p) = inj₂ p

QF-ABV    ⇾⁺? l₃ | no ¬l₁⇾l₃
  = Dec.map (equivalence
            (QF-ABV⇾QF-AUFBV ∷_)
            (λ { [ l₁⇾l₃ ] → ⊥-elim (¬l₁⇾l₃ l₁⇾l₃) ; (QF-ABV⇾QF-AUFBV ∷ p) → p}))
            (QF-AUFBV ⇾⁺? l₃)

QF-RDL    ⇾⁺? l₃ | no ¬l₁⇾l₃
  = Dec.map (equivalence
            (QF-RDL⇾QF-LRA ∷_)
            (λ { [ l₁⇾l₃ ] → ⊥-elim (¬l₁⇾l₃ l₁⇾l₃) ; (QF-RDL⇾QF-LRA ∷ p) → p}))
            (QF-LRA ⇾⁺? l₃)

QF-LRA    ⇾⁺? l₃ | no ¬l₁⇾l₃
  = Dec.map (equivalence to from) (QF-UFNRA ⇾⁺? l₃ ⊎-dec LRA ⇾⁺? l₃ ⊎-dec QF-NRA ⇾⁺? l₃)
  where
    to = [ QF-LRA⇾QF-UFNRA ∷_ , [ QF-LRA⇾LRA ∷_ , QF-LRA⇾QF-NRA ∷_ ]′ ]′
    from : (QF-LRA ⇾⁺ l₃) → (QF-UFNRA ⇾⁺ l₃ ⊎ LRA ⇾⁺ l₃ ⊎ QF-NRA ⇾⁺ l₃)
    from [ l₁⇾l₃ ] = ⊥-elim (¬l₁⇾l₃ l₁⇾l₃ )
    from (QF-LRA⇾QF-UFNRA ∷ p) = inj₁ p
    from (QF-LRA⇾LRA      ∷ p) = inj₂ (inj₁ p)
    from (QF-LRA⇾QF-NRA   ∷ p) = inj₂ (inj₂ p)

NRA       ⇾⁺? l₃ | no ¬l₁⇾l₃
  = Dec.map (equivalence
            (NRA⇾AUFNIRA ∷_)
            (λ { [ l₁⇾l₃ ] → ⊥-elim (¬l₁⇾l₃ l₁⇾l₃) ; (NRA⇾AUFNIRA ∷ p) → p}))
            (AUFNIRA ⇾⁺? l₃)

LRA       ⇾⁺? l₃ | no ¬l₁⇾l₃
  = Dec.map (equivalence to from) (UFLRA ⇾⁺? l₃ ⊎-dec NRA ⇾⁺? l₃)
  where
    to = [ LRA⇾UFLRA ∷_ , LRA⇾NRA ∷_ ]′
    from : (LRA ⇾⁺ l₃) → (UFLRA ⇾⁺ l₃ ⊎ NRA ⇾⁺ l₃)
    from [ l₁⇾l₃ ] = ⊥-elim (¬l₁⇾l₃ l₁⇾l₃)
    from (LRA⇾UFLRA ∷ p) = inj₁ p
    from (LRA⇾NRA   ∷ p) = inj₂ p

QF-NRA    ⇾⁺? l₃ | no ¬l₁⇾l₃
  = Dec.map (equivalence to from) (QF-UFNRA ⇾⁺? l₃ ⊎-dec NRA ⇾⁺? l₃)
  where
    to = [ QF-NRA⇾QF-UFNRA ∷_ , QF-NRA⇾NRA ∷_ ]′
    from : (QF-NRA ⇾⁺ l₃) → (QF-UFNRA ⇾⁺ l₃ ⊎ NRA ⇾⁺ l₃)
    from [ l₁⇾l₃ ] = ⊥-elim (¬l₁⇾l₃ l₁⇾l₃)
    from (QF-NRA⇾QF-UFNRA ∷ p) = inj₁ p
    from (QF-NRA⇾NRA      ∷ p) = inj₂ p
