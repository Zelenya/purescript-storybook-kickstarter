module Storybook (Decorator, Story, decorator, story) where

import Prelude

import Effect (Effect)
import Effect.Uncurried (EffectFn1, mkEffectFn1)
import Prim.Row (class Union)
import React.Basic (JSX)
import Unsafe.Coerce (unsafeCoerce)

type StoryProps = (title :: String, decorators :: Array Decorator)

-- | Create a story, title is a required field
story :: forall p p_. Union p p_ StoryProps => { title :: String | p } -> Story
story = unsafeCoerce

-- | Create a decorator
decorator :: (JSX -> Effect JSX) -> Decorator
decorator fn = toDecorator (mkEffectFn1 (_ >>= fn))
  where
  toDecorator :: (EffectFn1 (Effect JSX) JSX) -> Decorator
  toDecorator = unsafeCoerce

foreign import data Decorator :: Type
foreign import data Story :: Type
