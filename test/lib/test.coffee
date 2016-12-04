assert = require 'assert'
corepath = require 'path'

use = require '../../lib'

tests = (use) ->

  ->

    it 'should return an error for unknown module', ->

      thing = {}
      thing.use = use
      result = thing.use 'unknown-module-name'
      assert.equal result?.error, 'Unable to require plugin with string: unknown-module-name'

    it 'should return an error for non-existent path', ->

      thing = {}
      thing.use = use
      result = thing.use '/does/not/exist'
      assert.equal result?.error, 'Unable to require plugin with string: /does/not/exist'

    it 'should return an error for a non-function', ->

      thing = {}
      thing.use = use
      result = thing.use [] # not a string or function
      assert.equal result?.error, 'plugin must be a function'

    it 'should alter thing', ->

      thing = {}
      thing.use = use
      thing.use -> @prop = 'test'
      assert.equal thing.prop, 'test'

    it 'should alter thing using default options', ->

      defaultOptions = prop:'test'
      receivedOptions = null
      thing = {}
      thing.use = use.withOptions defaultOptions
      thing.use (options) ->
        receivedOptions = options
        @[options.prop] = 'test'
      assert.deepEqual receivedOptions, defaultOptions, 'should receive the options'
      assert.equal thing.test, 'test'

    it 'should alter thing using plugin options', ->

      thing = {}
      thing.use = use
      thing.use ((options) -> @[options.prop] = 'test'), prop:'plugin'
      assert.equal thing.plugin, 'test'

    it 'should alter thing using plugin options overriding default options', ->

      thing = {}
      thing.use = use.withOptions prop:'test'
      thing.use ((options) -> @[options.prop] = 'test'), prop:'plugin'
      assert.equal thing.plugin, 'test'


describe 'test default use', tests use

describe 'test use.gen()', tests use.gen()

describe 'test enhancing itself', ->

  guse = use.gen()

  altered =
    combine: false
    load   : false
    use    : false
    withOptions: false

  it 'should alter the combine()', -> assert.equal altered.combine, true
  it 'should alter the load()', -> assert.equal altered.load, true
  it 'should alter the use()', -> assert.equal altered.use, true
  it 'should alter the withOptions()', -> assert.equal altered.withOptions, true

  guse.use ->
    scope = this
    oldCombine = scope.combine
    scope.combine = (defaultOptions, options) ->
      altered.combine = true
      oldCombine defaultOptions, options

  guse.use ->
    scope = this
    oldLoad = scope.load
    scope.load = (string) ->
      altered.load = true
      oldLoad string

  guse.use ->
    scope = this
    oldUse = scope.use
    scope.use = (that, scope, plugin, options) ->
      altered.use = true
      oldUse that, scope, plugin, options

  guse.use ->
    scope = this
    oldWithOptions = scope.withOptions
    scope.withOptions = (that, scope, defaultOptions) ->
      altered.withOptions = true
      oldWithOptions that, scope, defaultOptions

  thing = {}
  thing.use = guse.withOptions()
  thing.use corepath.resolve('test','helpers','plugin.coffee')

describe 'test use.gen with a specified object', ->

  object =
    some: 'thing'
    with: 'props'
    work: -> # even a function

  describe 'which has existing props', tests use.gen object


  describe 'which already has the usual scoped functions', ->

    object =
      combine: (d, o) -> d # only defaults, ignore plugin options
      load   : (s) -> # nada, never called
      use    : (that, scope, p, o) ->
        if typeof p isnt 'function' then return error:'must be a function'
        p.call that, o, that
      withOptions: (scope, d = {}) ->
        d.extra = 'enforced'
        (p, o) -> scope.use this, scope, p, scope.combine d, o

    it 'should refuse to load string', ->
      thing = {}
      thing.use = use.gen object
      result = thing.use 'some/string'
      assert.equal result?.error, 'must be a function'

    it 'should ignore plugin options and only use default options', ->
      thing = {}
      thing.use = use.gen(object).withOptions prop:'test'
      thing.use ((options) -> this?[options?.prop] = 'test'), prop:'plugin'

      assert.equal thing.plugin, undefined, 'plugin option should have been ignored'
      assert.equal thing.test, 'test', 'default option should have been used'

    it 'should have a default option `extra`', ->
      thing = {}
      thing.use = use.gen(object).withOptions()
      thing.use (options) -> @extra = options.extra

      assert.equal thing.extra, 'enforced', 'should use default option prop we set'
