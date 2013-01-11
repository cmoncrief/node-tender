assert = require 'assert'
client = require('../lib/tender').createClient()

describe 'Categories', ->
    
  it 'should get a list of categories', (done) ->
    client.getCategories {max: 20}, (err, data) ->
      assert.ifError err
      assert data.length
      assert data.length <= 20
      done()

  it 'should get a category by name', (done) ->
    client.getCategories {max: 20, name: client.testData.category}, (err, data) ->
      assert.ifError err
      assert data.length is 1
      done()

  it 'should get a category by id', (done) ->
    client.getCategories {id: client.testData.categoryId}, (err, data) ->
      assert.ifError err
      assert data
      done()
