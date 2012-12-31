assert = require 'assert'
client = require('../lib/tender').createClient()

describe 'Users', ->
    
  it 'should get a list of users', (done) ->
    client.getUsers {max: 20}, (err, data) ->
      assert.ifError err
      assert data.length
      assert data.length <= 20
      done()

  it 'should get a user by name', (done) ->
    client.getUsers {max: 20, name: client.testData.user}, (err, data) ->
      assert.ifError err
      assert.equal data.length, 1
      done()