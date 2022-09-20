module Test.Chunk where

import Prelude

data Chunk = Profile | Posts

derive instance Eq Chunk
derive instance Ord Chunk
instance Show Chunk where
  show Profile = "Profile"
  show Posts = "Posts"
