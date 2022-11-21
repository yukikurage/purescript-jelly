module Test.Main where

import Prelude

import Control.Monad.Reader (class MonadTrans, ReaderT, ask, lift, runReaderT)
import Control.Monad.Rec.Class (class MonadRec)
import Data.Tuple.Nested (type (/\), (/\))
import Effect (Effect)
import Effect.Class (class MonadEffect)
import Effect.Class.Console (log)
import Jelly.Component (Component, hooks, raw, switch, text, textSig)
import Jelly.Element as JE
import Jelly.Hooks (class MonadHooks, Hooks, newStateEq, runHooks, runHooks_, useCleaner, useInterval)
import Jelly.Prop (on, onMount, (:=))
import Jelly.Render (render)
import Jelly.Signal (modifyChannel, readSignal, writeChannel)
import Web.HTML.Event.EventTypes (click)

newtype AppT a = AppT (ReaderT Int Hooks a)

class Monad m <= UseInt m where
  useInt :: m Int

instance (MonadTrans t, UseInt m, Monad (t m)) => UseInt (t m) where
  useInt = lift useInt

derive newtype instance Functor AppT
derive newtype instance Apply AppT
derive newtype instance Applicative AppT
derive newtype instance Bind AppT
derive newtype instance Monad AppT
derive newtype instance MonadEffect AppT
derive newtype instance MonadHooks AppT
derive newtype instance MonadRec AppT
instance UseInt AppT where
  useInt = AppT ask

runAppT :: forall a. AppT a -> Int -> Effect (a /\ Effect Unit)
runAppT (AppT rdr) i = runHooks (runReaderT rdr i)

runAppT_ :: AppT Unit -> Int -> Effect Unit
runAppT_ (AppT rdr) i = runHooks_ (runReaderT rdr i)

-- mountApp :: AppT HydrateM Unit -> Int -> Node -> Hooks Unit
-- mountApp (AppT m) int node = mount (runReaderT m int) node

main :: Effect Unit
main = runAppT_ app 123

app :: forall m. MonadRec m => MonadHooks m => UseInt m => m Unit
app = do
  rendered <- render root
  log =<< readSignal rendered
  pure unit

root :: forall m. MonadHooks m => UseInt m => Component m
root = do
  testComp
  testCounter
  testEffect
  testRaw
  testApp

testComp :: forall m. Component m
testComp = JE.div [ "class" := "test" ] $ text "Hello World!"

testState :: forall m. MonadHooks m => Component m
testState = hooks do
  timeSig /\ timeChannel <- newStateEq 0

  useInterval 1000 do
    modifyChannel timeChannel (_ + 1)

  pure $ JE.div' $ textSig $ show <$> timeSig

testCounter :: forall m. MonadHooks m => Component m
testCounter = hooks do
  countSig /\ countChannel <- newStateEq 0

  pure $ JE.div' do
    JE.button [ on click \_ -> modifyChannel countChannel (_ + 1) ] $ text "Increment"
    JE.div' $ textSig $ show <$> countSig

testEffect :: forall m. MonadHooks m => Component m
testEffect = hooks do
  fragSig /\ fragChannel <- newStateEq true

  pure $ JE.div' do
    JE.button [ on click \_ -> writeChannel fragChannel true ] $ text "Mount"
    JE.button [ on click \_ -> writeChannel fragChannel false ] $ text "Unmount"
    switch $ fragSig <#> \frag ->
      when frag $ hooks do
        useCleaner $ log "Unmounted"
        log "Mounted"
        pure $ JE.div [ onMount \_ -> log "Mounted(in props)" ] $ text "Mounted Elem"

testRaw :: forall m. Component m
testRaw = JE.div' do
  raw $ "<div>In Raw Element</div>"

testApp :: forall m. UseInt m => Component m
testApp = hooks do
  int <- useInt
  pure do
    JE.div' do
      text $ show int
