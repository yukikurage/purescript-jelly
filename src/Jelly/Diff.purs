module Jelly.Diff where

import Prelude

import Data.Array (foldl, index)
import Data.FoldableWithIndex (foldlWithIndex)
import Data.Map as Map
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..), snd)

-- | Compute the diff between two arrays with key.
-- | Keys must be unique.
-- | The key `Nothing` means that the item is always new.
-- | The result is `Tuple moved removed`
-- | In moved, `Nothing` means new item, `Just oldIndex` means moved item.
-- | removed is the list of removed items.
-- | ex) diff (\a -> if a == 0 then Nothing else a) [1, 3, 2, 0] [2, 1, 0, 4] == Tuple [Just 2, Just 0, Nothing, Nothing] [1]
diff
  :: forall a k
   . Ord k
  => Eq k
  => (a -> Maybe k)
  -> Array a
  -> Array a
  -> Tuple (Array (Maybe Int)) (Array Int) -- moved /\ removed
diff getKeyMaybe prevArray newArray =
  let
    keyMapF i acc _ = case getKeyMaybe =<< index prevArray i of
      Nothing -> acc
      Just k -> Map.insert k i acc
    keyMap = foldlWithIndex keyMapF Map.empty prevArray

    movedF a = (\k -> Map.lookup k keyMap) =<< getKeyMaybe a
    moved = map movedF newArray

    removedF acc a = case getKeyMaybe a of
      Nothing -> acc
      Just k -> Map.delete k acc
    removed =
      map snd $ Map.toUnfoldable $ foldl removedF keyMap newArray :: Array Int
  in
    Tuple moved removed
