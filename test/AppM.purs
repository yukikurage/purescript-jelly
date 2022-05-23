module Test.AppM where

import Control.Monad.State (StateT)
import Effect.Aff (Aff)

type AppState = Int

type AppM = StateT AppState Aff
