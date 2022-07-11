# Purescript Storybook Kickstarter

A way to get started with using [Storybook](https://storybook.js.org/) in a PureScript project with React.

This demo is build on top of [purescript-kickstarter](https://github.com/Zelenya7/purescript-kickstarter), check it out if you are interested in getting started with a new PureScript project.

## Why should you care about Storybook

“Stories are the creative conversion of life itself into a more powerful, clearer, more meaningful experience. They are the currency of human contact.” ― Robert McKee

Storybook allows you to build UI components in isolation, test(mock) them in hard-to-reach states, and use as a source of documentation.

Storybook is pretty much a fancy build tool. You can edit components and [stories](https://storybook.js.org/docs/react/get-started/whats-a-story), and then a toolchain does its magic and updates the browser in real time. You don't need to run and interact with your whole app, you could work directly on the specific components.

Note: A Story is an example of a component, it captures a specific rendered state. You could learn more about stories in [Storybook docs](https://storybook.js.org/docs/react/get-started/whats-a-story)

You can use is Storybook with any popular JavaScript framework. However in this tutorial we are going to focus on a PureScript project that uses React.

## Project setup

We are starting with a basic npm-React-PureScript project. (If you would like to follow along at home, you could either use one of your existing projects or use the [purescript-kickstarter](https://github.com/Zelenya7/purescript-kickstarter))

Because we are using PureScript, we can't use the [Storybook tools](https://storybook.js.org/docs/react/get-started/install) for JavaScript projects to configure Storybook and generate all the boilerplate. We have to copypaste the boilerplate ourselves, namely:

- Install the required dependencies.
- Setup the scripts to run and build Storybook.
- Add the Storybook configuration.
- Add some FFI and functions for creating Stories.

Install the dependency `@storybook/react`:

```
npm install --save @storybook/react
```

Add the scripts to your package manager (e.g. `package.json`):

```
"prestorybook": "spago build",
"storybook": "start-storybook -p 6006"
```

Storybook is configured via a folder called `.storybook`, which can contain different configuration files.

The main configuration file is `main.js`. It takes care of the Storybook server's behavior. Let's add it (`.storybook/main.js`) first:

```
module.exports = {
  addons: [],
  framework: '@storybook/react',
  staticDirs: ['../public'],
  stories: ['../output/Story.*/index.js'],
  webpackFinal: async (config) => {
    // Make whatever fine-grained changes you need
    // Return the altered config
    return config
  }
}
```

This is more or less a default configuration, tweaked for working with PureScript project. The configuration includes:

- `addons` - a list of enabled addons. We haven't enabled any addons for this project (Addons introduce new features and integrations, to learn more see the [Introduction to addons](https://storybook.js.org/docs/react/addons/introduction))
- `framework` - a framework specific configurations (for the build process). We are using `@storybook/react` for React
- `stories` - a list with locations of the story files (relative to `main.js`). We include PureScript modules in `Story` directory (as you will see later)
- `webpackFinal` - custom webpack configuration, we are just leaving it be

If you want to change the configuration, see the [Configure Storybook](https://storybook.js.org/docs/react/configure/overview)

Note: make sure to restart Storybook’s process, when you change the configuration

The other configuration file that we have to add is `.storybook/preview.js`. [It is used to](https://storybook.js.org/docs/react/configure/overview#configure-story-rendering) control the rendering of the stories as well as global decorators and parameters. We just want to import our CSS there:

```
import '../public/styles.css'
```

Last preparation step is adding FFI and basic APIs for creating stories. We are going to create a `Storybook.purs` in `src`, but it could go anywhere depending on your preferences. The content of the module:

```
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
```

There are two functions that we are going to use to create stories: `story` and `decorator`. As their names imply, one of them is used to create stories, and the other one is used to create [story decorators](https://storybook.js.org/docs/react/writing-stories/decorators#gatsby-focus-wrapper) (we'll cover them later). Let's see them in action!

## Creating a Story

Each story module must include:

- default export that describes the component
- named exports that describe the stories

It's recommended to define component’s stories in a story file and put it alongside the component file. However we are going to create a separate `Story` directory for stories of all the components (you could choose what is more convenient for you project).

Let's create some stories for the `ReactPlayer` component in `Story.ReactPlayer`. (We are going to omit the imports, see [the full code](https://github.com/Zelenya7/purescript-storybook-kickstarter/blob/main/src/Story/ReactPlayer.purs) for details). First thing that we need to include is the default export with the title:

```
default :: Story
default = story { title: "React Player" }
```

And then we can describe the stories, in other words we can mock the component with specific props:

```
rick :: Effect JSX
rick = pure $ element reactPlayer
  { className: "screen"
  , controls: true
  , light: true
  , url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
  }
```

We could also include another story with a broken link to know how it looks:

```
brokenLink :: Effect JSX
brokenLink = pure $ element reactPlayer
  { className: "screen"
  , controls: true
  , light: true
  , url: "broken-link"
  }
```

Let's see how our stories look by running the Storybook:

```
npm run storybook
```

The action should succeed, Storybook should open `http://localhost:6006/` and you should see the stories:

React Player looks good enough. Let's see what else we could do with stories.

### Using decorators

When writing stories, we could use [Decorators](https://storybook.js.org/docs/react/writing-stories/decorators) to wrap stories in extra mocking context. This could be helpful if your components:

- use theme providers
- depend on the parent's style
- require some side-loaded data

Let's take a `SimpleButton` as an example, it doesn't have much styling, and its width depends on the parent component. So in order to create a realistic story we have to mock this button inside a context. Luckily we don't have to deal with other components, we can use a decorator to mock it.

We create a `Story.SimpleButton` module and add a decorator (a gray box):

```
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
```

Then we add a simple story for the button:

```

clickMeStylized :: Effect JSX
clickMeStylized = pure $ simpleButton
  { text: "Click me"
  , onClick: pure unit
  }
```

Note: you could use the [actions](https://storybook.js.org/docs/react/essentials/actions) addon to make button event handlers more useful in your stories

And we shouldn't forget about a default story export, which adds decorators (the decorator is applied to all the stories in the module):

```
default :: Story
default = story
  { title: "Simple Button"
  , decorators: [ uglyBoxDecorator ]
  }
```

If we run the Storybook: `npm run storybook`, we should see a button in the context:

## What's next?

This is just a tip of the iceberg when it comes to the Storybook. If you’d like to learn more about Storybook, check out the official [documentation](https://storybook.js.org/docs/react/get-started/introduction) and [tutorials](https://storybook.js.org/tutorials/). You could discover [Parameters](https://storybook.js.org/docs/react/writing-stories/parameters), [Addons](https://storybook.js.org/docs/react/addons/introduction), and more.
