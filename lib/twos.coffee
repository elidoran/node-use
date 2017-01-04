module.exports = (fn) -> ->

  if arguments.length < 1 then return

  for i in [0...arguments.length]
    arg = arguments[i]

    # if it's an object then it's the options object for the plugin
    if typeof arg is 'object'

      # if we have a plugin then call it with this arg as the options.
      # then null out the plugin
      if plugin?
        result = fn.call this, plugin, arg
        if result?.error? then return result
        plugin = null

      # else there's no plugin for this object to be its options...error...
      else return fn.call this, arg

    # else it better be a string or function... let `fn` complain
    else
      # if we have one waiting for an options object, call it now
      if plugin?
        result = fn.call this, plugin
        if result?.error? then return result

      # then set this new one to wait for options object
      plugin = arg

  # was there one left waiting? send it
  if plugin? then return fn.call this, plugin

  return
