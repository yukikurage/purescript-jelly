module Jelly.Data.Machine where

import Prelude

import Control.Monad.Rec.Class (class MonadRec, forever)
import Data.Either (Either(..))
import Effect (Effect)
import Effect.Aff (Aff, makeAff)
import Effect.Aff.Class (class MonadAff, liftAff)
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Class.Console (log)
import Jelly.Data.Emitter (Emitter, addEmitterListenerOnce, emit, newEmitter)

-- | Machine is connector between MonadAff Monad m and Event Handler
type Machine m = Emitter Effect (m Unit)

newMachine :: forall m. MonadEffect m => m (Machine m)
newMachine = liftEffect newEmitter

waitEvent :: forall m. Machine m -> Aff (m Unit)
waitEvent machine = makeAff \resolve -> do
  _ <- addEmitterListenerOnce machine \x -> do
    resolve (Right $ x)
  pure mempty

runMachine :: forall m. MonadAff m => MonadRec m => Machine m -> m Unit
runMachine machine = forever do
  event <- liftAff $ waitEvent machine
  log $ "Machine stepped"
  event

listenerWithMachine
  :: forall e m. Machine m -> (e -> m Unit) -> e -> Effect Unit
listenerWithMachine machine listener = \ev -> emit machine $
  listener ev
