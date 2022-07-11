module Story.SimpleButton
  ( clickMeStylized
  , default
  ) where

import Prelude

import Components.SimpleButton (simpleButton)
import Effect (Effect)
import React.Basic (JSX)
import React.Basic.DOM (css)
import React.Basic.DOM as R
import Storybook (Decorator, decorator, Story, story)

default :: Story
default = story
  { title: "Simple Button"
  , decorators: [ uglyBoxDecorator ]
  }

clickMeStylized :: Effect JSX
clickMeStylized = pure $ simpleButton
  { text: "Click me"
  , onClick: pure unit
  }

uglyBoxDecorator :: Decorator
uglyBoxDecorator = decorator \story -> pure $ mkBox [ story ]
  where
  mkBox children = R.div
    { className: "box"
    , style: css
        { backgroundColor: "lightGray"
        , height: "90px"
        , width: "160px"
        }
    , children
    }
