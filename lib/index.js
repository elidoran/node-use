'use strict'

var inTwos = require('./twos')

// export an instance of @use/core with empty defaults.
module.exports = gen({})

// also export the instance generator function so they can build their
// own instance with defaults.
module.exports.gen = gen

// helper function combines hierarchy of options objects.
// creates a new object to hold the combined values.
// this function will be in the `scope` and can be overridden.
function combine(defaultOptions, options) {
  return Object.assign({}, defaultOptions, options)
}

// accepts both module names and paths.
// local paths need their scripts `require()` function in order to resolve them.
function load(string, options) {

  var theRequire = (options && options.require) || require

  try {
    return theRequire(string)
  } catch (error) {
    return {
      error: 'Unable to require plugin with string: ' + string,
      reason: error
    }
  }
}

// the main `use()` function loads the plugin and calls it.
function use(that, scope, plugin, options) {

  // if it's a string then it's either a package name or a script path.
  if (typeof plugin === 'string') {

    // use our scope's load() (so it can be overridden)
    plugin = scope.load(plugin, options)

    if (plugin.error != null) {
      return plugin
    }
  }

  // otherwise, it should be a function, if not, return an error.
  if (typeof plugin !== 'function') {
    return {
      error: 'plugin must be a function'
    }
  }

  // it is a function so call it and return the result (may be an error).
  return plugin.call(that, options, that)
}

// create a closure to hold the provided `scope` and `defaultOptions`.
function withOptions(scope, defaultOptions) {
  return function(plugin, options) {
    return scope.use(this, scope, plugin, scope.combine(defaultOptions, options))
  }
}

// creates a @use/core instance with provided scope and baseOptions.
function gen(providedScope, baseOptions) {

  // holds the created instance.
  var theUse

  // NOTE:
  //  using their object instead of grabbing each property individually for
  //  an object we create here because I want to allow them to put anything
  //  into the `scope` object they provide so it'll be available to them.

  // if no scope is provided then create one.
  var scope = providedScope || {}

  // ensure we have the usuals available in the scope.
  scope.require = scope.require || require
  scope.load    = scope.load    || load
  scope.combine = scope.combine || combine
  scope.use     = scope.use     || use
  scope.inTwos  = scope.inTwos  || inTwos
  scope.withOptions = scope.withOptions || withOptions

  // lastly, wrap this in the "inTwos" helper which smartly handles arrays of
  // plugins and options and passes them in as pairs, or as a single plugin
  // without options.
  // NOTE: the first arg is `this` which is the object we're attached to.
  theUse = scope.inTwos(function(plugin, options) {
    return scope.use(this, scope, plugin, scope.combine(baseOptions, options))
  })

  //
  // NOTE: the first arg is `scope`, not `this` as it is above because this
  // use() affects the @use/core instance: thing.use.use(...)
  theUse.use = scope.inTwos(function(plugin, options) {
    return scope.use(scope, scope, plugin, scope.combine(baseOptions, options))
  })

  // allow creating a new instance with new `defaultOptions`.
  theUse.withOptions = function(defaultOptions) {
    return scope.withOptions(scope, scope.combine(baseOptions, defaultOptions))
  }

  return theUse
}
