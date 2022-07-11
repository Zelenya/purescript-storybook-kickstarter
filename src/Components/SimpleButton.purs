module Components.SimpleButton where

import Prelude

import Effect (Effect)
import React.Basic.DOM as R
import React.Basic.Events (handler_)
import React.Basic.Hooks (JSX)

type SimpleButtonProps =
  { onClick :: Effect Unit
  , text :: String
  }

simpleButton :: SimpleButtonProps -> JSX
simpleButton { onClick, text } =
  R.button
    { children: [ R.text text ]
    , onClick: handler_ onClick
    }
