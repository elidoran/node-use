# export the `use()` function
module.exports = (fn) ->

  -> # generate a function to return. the `this` is the thing: thing.use()

    if arguments.length < 1 then return

    # convert `arguments` to a real array
    args = []
    args.push.apply args, arguments

    # iterate args for plugin/options pairs, and, plugins w/out options.
    for arg in args

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
        # if we have one waiting for an options object, call it now w/out options
        if plugin?
          result = fn.call this, plugin
          if result?.error? then return result

        # then set this new one to wait for options object
        plugin = arg

    # was there one left waiting? send it
    if plugin? then return fn.call this, plugin

    return
