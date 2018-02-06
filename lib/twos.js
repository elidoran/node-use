// smartly processes array of plugin/options and passes them on in pairs.
module.exports = function inTwos(fn) {

  // generate a function to return. the `this` is the thing: thing.use()
  return function() {

    var args, plugin, result

    // if no args are provided then we're done.
    if (arguments.length < 1) {
      return
    }

    // put the `arguments` in a real array
    args = []
    args.push.apply(args, arguments)

    // iterate args for plugin/options pairs, and, plugins w/out options.
    for (var i = 0, len = args.length, arg; i < len; i++) {

      arg = args[i]

      // if it's an object then it's the options object for the plugin
      if (typeof arg === 'object') {

        // if we have a plugin then call it with this arg as the options.
        // then null out the plugin
        if (plugin) {

          // provide the plugin and options to the inner function.
          // NOTE: provide `this` so it has the same context as our wrapper.
          result = fn.call(this, plugin, arg)

          // if there was an error returned then return that error.
          if (result && result.error) {
            return result
          }

          // we sent the plugin on so, null it.
          plugin = null

        } else {
          // there's no plugin for this object to be its options...error...
          return fn.call(this, arg)
        }

      } else { // it better be a string or function... let `fn` complain

        // if we have one waiting for an options object, call it now w/out options
        // because hitting the next plugin means there aren't options for the
        // waiting one.
        if (plugin) {

          result = fn.call(this, plugin)

          // if there was an error returned then return that error.
          if (result && result.error) {
            return result
          }
        }

        // then set this new one to wait for an options object.
        plugin = arg
      }

    } // end for-loop

    // if a plugin was waiting for an options then send it without them
    // because there are no more args.
    if (plugin) {
      return fn.call(this, plugin)
    }

  } // end closure

} // end inTwos exported function
