module Test.Main where

import Prelude

import Control.Monad.Reader (ReaderT, ask, runReaderT)
import Data.Foldable (traverse_)
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Class.Console (log)
import Jelly.Aff (awaitBody)
import Jelly.Component (class Component, raw, text, textSig)
import Jelly.Element as JE
import Jelly.Hydrate (HydrateM, mount)
import Jelly.Prop (on, onMount, (:=))
import Signal (modifyChannel, writeChannel)
import Signal.Hooks (class MonadHooks, Hooks, newStateEq, runHooks_, useCleaner, useInterval, useWhen_)
import Web.DOM (Node)
import Web.HTML.Event.EventTypes (click)

newtype AppT :: forall k. (k -> Type) -> k -> Type
newtype AppT m a = AppT (ReaderT Int m a)

class UseInt m where
  useInt :: m Int

derive newtype instance Monad m => Functor (AppT m)
derive newtype instance Monad m => Apply (AppT m)
derive newtype instance Monad m => Applicative (AppT m)
derive newtype instance Monad m => Bind (AppT m)
derive newtype instance Monad m => Monad (AppT m)
derive newtype instance MonadEffect m => MonadEffect (AppT m)
derive newtype instance MonadHooks m => MonadHooks (AppT m)
derive newtype instance Component m => Component (AppT m)
instance Monad m => UseInt (AppT m) where
  useInt = AppT ask

mountApp :: Int -> AppT HydrateM Unit -> Node -> Hooks Unit
mountApp int (AppT m) node = mount (runReaderT m int) node

main :: Effect Unit
main = launchAff_ do
  bodyMaybe <- awaitBody
  liftEffect $ runHooks_ $ traverse_ (mountApp 123 root) bodyMaybe

root :: forall m. Component m => UseInt m => m Unit
root = do
  testComp
  testCounter
  testEffect
  testRaw
  testApp

testComp :: forall m. Component m => m Unit
testComp = JE.div [ "class" := "test" ] $ text "Hello World!"

testState :: forall m. Component m => m Unit
testState = do
  timeSig /\ timeChannel <- newStateEq 0

  useInterval 1000 do
    modifyChannel timeChannel (_ + 1)

  JE.div' $ textSig $ show <$> timeSig

testCounter :: forall m. Component m => m Unit
testCounter = do
  countSig /\ countChannel <- newStateEq 0

  JE.div' do
    JE.button [ on click \_ -> modifyChannel countChannel (_ + 1) ] $ text "Increment"
    JE.div' $ textSig $ show <$> countSig

testEffect :: forall m. Component m => m Unit
testEffect = do
  fragSig /\ fragChannel <- newStateEq true

  JE.div' do
    JE.button [ on click \_ -> writeChannel fragChannel true ] $ text "Mount"
    JE.button [ on click \_ -> writeChannel fragChannel false ] $ text "Unmount"
    useWhen_ fragSig do
      useCleaner $ log "Unmounted"
      log "Mounted"
      JE.div [ onMount \_ -> log "Mounted(in props)" ] $ text "Mounted Elem"

testRaw :: forall m. Component m => m Unit
testRaw = JE.div' do
  raw $ "<div>In Raw Element</div>"

testApp :: forall m. Component m => UseInt m => m Unit
testApp = do
  int <- useInt
  JE.div' $ text $ show int
