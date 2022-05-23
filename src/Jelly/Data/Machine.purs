module Jelly.Data.Machine where

import Prelude

import Control.Monad.Rec.Class (class MonadRec, forever)
import Data.Either (Either(..))
import Effect (Effect)
import Effect.Aff (Aff, makeAff)
import Effect.Aff.Class (class MonadAff, liftAff)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import Jelly.Data.Emitter (Emitter, addEmitterListenerOnce, emit, newEmitter)

-- | Machine is connector between MonadAff Monad m and Event Handler
type Machine m = Emitter Effect (m Unit)

newMachine :: forall m. Effect (Machine m)
newMachine = newEmitter

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

tellMachine :: forall m. Machine m -> m Unit -> Effect Unit
tellMachine machine event = do
  liftEffect $ emit machine event
