module Story.ReactPlayer
  ( brokenLink
  , default
  , rick
  ) where

import Prelude

import Effect (Effect)
import Foreign.ReactPlayer (reactPlayer)
import React.Basic (JSX)
import React.Basic.Hooks (element)
import Storybook (Story, story)

default :: Story
default = story { title: "React Player" }

rick :: Effect JSX
rick = pure $ element reactPlayer
  { className: "screen"
  , controls: true
  , light: true
  , url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
  }

brokenLink :: Effect JSX
brokenLink = pure $ element reactPlayer
  { className: "screen"
  , controls: true
  , light: true
  , url: "broken-link"
  }
