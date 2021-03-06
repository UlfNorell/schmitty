{-# OPTIONS --allow-exec #-}

open import SMT.Theory

module SMT.Backend.CVC4 (theory : Theory) where

open Theory theory

open import Data.List as List using (List; _∷_; [])
open import Data.Maybe as Maybe using (Maybe; just; nothing)
open import Data.Product using (_×_; _,_; proj₁; proj₂)
open import Data.String as String using (String; _++_)
open import Data.Sum as Sum using (_⊎_; inj₁; inj₂; [_,_])
open import Data.Unit as Unit using (⊤)
open import Function using (case_of_; const; _$_; _∘_)
open import Reflection as Rfl using (return; _>>=_; _>>_)
open import Reflection.External
open import SMT.Script theory
open import Text.Parser.String using (runParser)

private
  variable
    Γ : Ctxt
    ξ : OutputType
    Ξ : OutputCtxt

cvc4TC : Script [] Γ (ξ ∷ Ξ) → Rfl.TC Rfl.Term
cvc4TC {Γ} {ξ} {Ξ} scr = do

  -- Print the SMT-LIB script and build the output parser.
  let (scr , parseOutputs) = showScript scr

  -- Construct the command specification.
  --
  -- TODO: Inspect the output type to see if any models should be produced,
  --       and set the --produce-models flag accordingly.
  --
  let cvc4Cmd = record
                { name  = "cvc4"
                ; args  = "--lang=smt2" ∷ "--output-lang=smt2" ∷ "--produce-models" ∷ "-q" ∷ "-" ∷ []
                ; input = scr
                }

  -- Run the Z3 command and parse the output.
  stdout ← runCmdTC cvc4Cmd
  case runParser parseOutputs stdout of λ where
    (inj₁ parserr) → parseError stdout parserr
    (inj₂ outputs) → return $ quoteOutputs outputs

macro
  cvc4 : Script [] Γ (ξ ∷ Ξ) → Rfl.Term → Rfl.TC ⊤
  cvc4 scr hole = cvc4TC scr >>= Rfl.unify hole
