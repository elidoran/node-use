# @use/core
[![Build Status](https://travis-ci.org/elidoran/node-use.svg?branch=master)](https://travis-ci.org/elidoran/node-use)
[![Dependency Status](https://gemnasium.com/elidoran/node-use.png)](https://gemnasium.com/elidoran/node-use)
[![npm version](https://badge.fury.io/js/%40use%2Fcore.svg)](http://badge.fury.io/js/%40use%2Fcore)

Add use() function for easy plugin ability.

Allows default options and plugin specific options.

Accepts module name or path to `use()` and will `require()` it for you.

Can assign it to any name.

# Table of Contents

* [Install](#install)
* [Applying use](#usage-applying-use)
* [Example Plugin](#usage-example-plugin)
* [Example](#usage-example)
* [Specify Default Options](#usage-specify-default-options)
* [Specify Plugin Options](#usage-specify-plugin-options)
* [Enhance Itself](#usage-enhance-itself)
* [Generate Your Own to Enhance](#usage-generate-your-own-to-enhance)
* [Custom Generation](#usage-custom-generation)


## Install

```sh
npm install use --save
```


## Usage: Applying 'use'

The simplest way to use this module is to `require()` it and assign it to the `use` property on your object.

You may use any property name, like, 'load', 'add', 'plugin', or 'enhance'.

Use it by supplying something which can be given to `require()` to get a function, or, supply a function.

```javascript
// your thing can be anything we can set `use` on
var thing = getThing()
// get this module which is the `use()` function
  , use = require('@use/core')

// set it on your thing. can name it anything you want.
thing.use = use

var somePluginName = 'some-name'
  , pluginRequired = require('another-plugin')
  , pluginFunction = function() { }
  , someOptions = {}

// add those plugins to your `thing`:
//  Note: options are optional

// 1. provide a module name or file path for `require()`
thing.use(somePluginName, someOptions)

// 2. provide the module directly when you've already loaded it
thing.use(pluginRequired, { /* Or, some other options */ })

// 3. provide a function directly as a plugin
thing.use(pluginFunction /* Or, no options */)
```


## Usage: Example Plugin

```javascript
function plugin(options, thing) {
  // `this` is the `thing`, same as param #2.
  // so, these two lines do the same thing:
  this.blah = 'example'
  thing.blah = 'example'

  // `options` is the combined options provided to:
  //   1. `use.gen(baseOptions)`
  //   2. `thing.use = use.withOptions(defaultOptions)`
  //   3. `thing.use(fn, pluginOptions)`
  // #3 overrides #2, #2 overrides #1.
  // options may be null
}
```


## Usage: Example

```javascript
// example `thing` is a behaviorless object
var thing = {}

// add this module so plugins can be applied
thing.use = require('@use/core')

// add a function directly as a plugin.
// it adds a function to the `thing`
thing.use(function addProcess() {
  // `this` is the `thing`
  this.process = function process(string) {
    console.log('I am processing string:', string)
  }
})

// now `thing` has added ability.
// the below call will output to the console:
//   I am processing string: blah
thing.process('blah')

// add another function which will alter process()
thing.use(function wrapInput(options) {
  var realProcess = this.process
    , prefix = '['
    , suffix = ']'

  if (options) {
    if (options.prefix) prefix = options.prefix
    if (options.suffix) suffix = options.suffix
  }

  this.process = function wrappedProcess(string) {
    string = prefix + string + suffix
    return realProcess.call(this, string)
  }
})

// now `process()` wraps the string with brackets instead
// the below call will output to the console:
//   I am processing string: [bleh]
thing.process('bleh')
```


## Usage: Specify Default Options

```javascript
// as above, let's use a behaviorless object
var use = require('@use/core')
  , thing = {}

// instead of adding the default `use()` function, let's supply options.
thing.use = use.withOptions({
  // these will be used by `wrapInput`
  prefix: '(',
  suffix: ')'
})

// same as the functions made above
thing.use(addProcess)
thing.use(wrapInput)

thing.process('blarg')
// The `wrapInput` will receive the options we made
// and then use parenthesis instead of brackets.
// the above outputs this to the console:
//    I am processing string: (blarg)
```


## Usage: Specify Plugin Options

```javascript
// as above, let's use a behaviorless object
var use = require('@use/core')
  , thing = {}

// instead of adding the default `use()` function, let's supply options.
thing.use = use.withOptions({
  // these will be overridden by plugin specific options
  prefix: '(',
  suffix: ')'
})

// same as the functions made above
thing.use(addProcess)
// these plugin specific options will override default options
thing.use(wrapInput, {
  prefix: '\'',
  suffix: '\''
})

thing.process('bling')
// The `wrapInput` will receive options combined from the default
// options provided for the `use()` function
// and the plugin specific options provided to the `use()` call,
// So, it will use single quotes instead of brackets or parenthesis.
// the above outputs this to the console:
//    I am processing string: 'bling'
```


## Usage: Enhance Itself

It's possible to use plugins to enhance the `use` instance itself.

```javascript
var use = require('@use/core')

use.use(function (options, scope) {
  // `this` == scope

  // the second arg is normally the `thing` the `use()` function is on,
  // in this case, it is the object holding the internal functions.

  // the `scope` is an object containing the four functions used by `use`.
  // you may swap them out, set props onto the scope which can be used by them
  // whatever...

  // for example, to change the options combining to create a new object
  // via underscore library's extend() function:
  scope.combine = function(defaults, options) {
    return _.extend({}, options, defaults)
  }
  // changing `withOptions` and `use` is more complicated,
  // so look at the source to see the original implementations.
})
```


## Usage: Generate Your Own to Enhance

All of the above examples use the default `use` instance. So, if you use the [enhance it](#usage-enhanceitself) then everyone using the default instance will have those customizations.

To avoid that you can generate your own instance:

```javascript
var use = require('@use/core')

// make your own to customize
use = use.gen()
```


## Usage: Custom Generation

It's possible to supply an object to the `gen()` function to add properties to the internal `scope` or override the default internal functions.

The object you provide is used as the `scope` and if new functions aren't specified then the default ones are placed into it.

```javascript
var use = require('@use/core')
  , customScope = {
    // make a property available in the `scope` for internal functions
    some: 'value',
    // override the `combine` function
    combine: function (defaultOptions, options) {
      return _.extend({}, options, defaults)
    }
  }

use = use.gen(customScope)

// also, you can specify some "base options" which are available to all plugins,
// and, are below the "default options" of withOptions()
use = use.gen({}, {
  some: 'base options'
})

// these options would override "base options"
use = use.withOptions({ some: 'default options'})

thing = { use:use }

// these options would override both the "base options" and "default options"
thing.use('some plugin', { some: 'plugin options'})
```


## MIT License
