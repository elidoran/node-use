assert = require 'assert'

twos = require '../../lib/twos'

describe 'test inTwos', ->

  string = 'string'
  object = {'object':true}
  fn     = ->

  it 'should handle one string', ->

    input = [ string ]

    answer = [
      [string, undefined]
    ]

    pairs = []
    innerFn = (a,b) -> pairs.push [a,b]
    twos(innerFn).apply null, input

    assert.deepEqual pairs, answer

  it 'should handle one function', ->

    input = [ fn ]

    answer = [
      [fn, undefined]
    ]

    pairs = []
    innerFn = (a,b) -> pairs.push [a,b]
    twos(innerFn).apply null, input

    assert.deepEqual pairs, answer

  it 'should handle one string and one object', ->

    input = [ string, object ]

    answer = [
      [string, object]
    ]

    pairs = []
    innerFn = (a,b) -> pairs.push [a,b]
    twos(innerFn).apply null, input

    assert.deepEqual pairs, answer

  it 'should handle one function and one object', ->

    input = [ fn, object ]

    answer = [
      [fn, object]
    ]

    pairs = []
    innerFn = (a,b) -> pairs.push [a,b]
    twos(innerFn).apply null, input

    assert.deepEqual pairs, answer

  it 'should handle one function and one string', ->

    input = [ fn, string ]

    answer = [
      [fn, undefined]
      [string, undefined]
    ]

    pairs = []
    innerFn = (a,b) -> pairs.push [a,b]
    twos(innerFn).apply null, input

    assert.deepEqual pairs, answer

  it 'should handle one function with object and one string', ->

    input = [ fn, object, string ]

    answer = [
      [fn, object]
      [string, undefined]
    ]

    pairs = []
    innerFn = (a,b) -> pairs.push [a,b]
    twos(innerFn).apply null, input

    assert.deepEqual pairs, answer

  it 'should handle one function and one string with object', ->

    input = [ fn, string, object ]

    answer = [
      [fn, undefined]
      [string, object]
    ]

    pairs = []
    innerFn = (a,b) -> pairs.push [a,b]
    twos(innerFn).apply null, input

    assert.deepEqual pairs, answer

  it 'should handle one function and one string, both with objects', ->

    input = [ fn, object, string, object ]

    answer = [
      [fn, object]
      [string, object]
    ]

    pairs = []
    innerFn = (a,b) -> pairs.push [a,b]
    twos(innerFn).apply null, input

    assert.deepEqual pairs, answer


  it 'should call in pairs of string/function and objects', ->

    input = [
      string, object
      fn, object
      string, object
    ]

    answer = [
      [string, object]
      [fn, object]
      [string, object]
    ]

    pairs = []
    innerFn = (a,b) -> pairs.push [a,b]
    twos(innerFn).apply null, input

    assert.deepEqual pairs, answer

  it 'should call with all strings one at a time', ->

    input = [ string, string, string, string ]

    answer = [
      [string, undefined]
      [string, undefined]
      [string, undefined]
      [string, undefined]
    ]

    pairs = []
    innerFn = (a,b) -> pairs.push [a,b]
    twos(innerFn).apply null, input

    assert.deepEqual pairs, answer
