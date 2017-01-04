combine = (defaultOptions, options) ->
  if defaultOptions? and options? then options.__proto__ = defaultOptions

  return options ? defaultOptions

load = (string, options) -> # accepts both module names and paths
  try # NOTE: paths must be absolute because require() resolves from here.
    # allow overriding `require` via options and scope via use.use()
    theRequire = options?.require ? @require
    theRequire string
  catch error
    return error:'Unable to require plugin with string: '+string, reason:error

use = (that, scope, plugin, options) ->
  if typeof plugin is 'string'
    plugin = scope.load plugin, options
    if plugin.error? then return plugin # return the object with the error

  if typeof plugin isnt 'function' then return error:'plugin must be a function'

  plugin.call that, options, that

withOptions = (scope, defaultOptions) ->
  (plugin, options) ->
    scope.use this, scope, plugin, scope.combine defaultOptions, options

gen = (scope = {}, baseOptions) ->
  scope.require ?= require
  scope.load    ?= load
  scope.combine ?= combine
  scope.use     ?= use
  scope.withOptions ?= withOptions

  theUse     = (plugin, options) -> scope.use this, scope, plugin, scope.combine baseOptions, options
  theUse.use = (plugin, options) -> scope.use scope, scope, plugin, scope.combine baseOptions, options
  theUse.withOptions = (defaultOptions) -> scope.withOptions scope, scope.combine baseOptions, defaultOptions

  return theUse

module.exports = gen {}
module.exports.gen = gen
