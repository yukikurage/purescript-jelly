module Test.Main where

import Prelude

import Control.Monad.Reader (class MonadTrans, ReaderT, ask, lift, runReaderT)
import Control.Monad.Rec.Class (class MonadRec)
import Control.Safely (traverse_)
import Data.Tuple.Nested (type (/\), (/\))
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (class MonadEffect)
import Effect.Class.Console (log)
import Jelly.Aff (awaitBody)
import Jelly.Component (Component, hooks, raw, switch, text, textSig)
import Jelly.Element as JE
import Jelly.Hooks (class MonadHooks, Hooks, runHooks, runHooks_, useCleaner, useInterval, useStateEq)
import Jelly.Hydrate (mount)
import Jelly.Prop (on, onMount, (:=))
import Jelly.Signal (modifyChannel_, writeChannel)
import Web.HTML.Event.EventTypes (click)

newtype App a = App (ReaderT Int Hooks a)

newtype AppInfinite a = AppInfinite (ReaderT (AppInfinite Unit) Hooks a)

derive newtype instance Functor AppInfinite
derive newtype instance Apply AppInfinite
derive newtype instance Applicative AppInfinite
derive newtype instance Bind AppInfinite
derive newtype instance Monad AppInfinite
derive newtype instance MonadEffect AppInfinite
derive newtype instance MonadHooks AppInfinite
derive newtype instance MonadRec AppInfinite

runAppInfinite :: AppInfinite Unit -> AppInfinite Unit -> Effect Unit
runAppInfinite (AppInfinite m) r = runHooks_ (runReaderT m r)

appInfiniteLog :: AppInfinite Unit
appInfiniteLog = do
  log "appInfiniteLog"

class Monad m <= UseInt m where
  useInt :: m Int

instance (MonadTrans t, UseInt m, Monad (t m)) => UseInt (t m) where
  useInt = lift useInt

derive newtype instance Functor App
derive newtype instance Apply App
derive newtype instance Applicative App
derive newtype instance Bind App
derive newtype instance Monad App
derive newtype instance MonadEffect App
derive newtype instance MonadHooks App
derive newtype instance MonadRec App
instance UseInt App where
  useInt = App ask

runApp :: forall m a. MonadEffect m => App a -> Int -> m (a /\ Effect Unit)
runApp (App rdr) i = runHooks (runReaderT rdr i)

runApp_ :: forall m a. MonadEffect m => App a -> Int -> m Unit
runApp_ (App rdr) i = runHooks_ (runReaderT rdr i)

main :: Effect Unit
main = launchAff_ do
  nodeM <- awaitBody
  runApp_ (traverse_ (mount root) nodeM) 123

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
  timeSig /\ timeChannel <- useStateEq 0

  useInterval 1000 do
    modifyChannel_ timeChannel (_ + 1)

  pure $ JE.div' $ textSig $ show <$> timeSig

testCounter :: forall m. MonadHooks m => Component m
testCounter = hooks do
  countSig /\ countChannel <- useStateEq 0

  pure $ JE.div' do
    JE.button [ on click \_ -> modifyChannel_ countChannel (_ + 1) ] $ text "Increment"
    JE.div' $ textSig $ show <$> countSig

testEffect :: forall m. MonadHooks m => Component m
testEffect = hooks do
  fragSig /\ fragChannel <- useStateEq true

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
