assert = require 'assert'
client = require('../lib/tender').createClient()

describe 'Queues', ->
    
  it 'should get a list of queues', (done) ->
    client.getQueues {max: 20}, (err, data) ->
      assert.ifError err
      assert data.length
      assert data.length <= 20
      done()

  it 'should get a queue by name', (done) ->
    client.getQueues {max: 20, name: client.testData.queue}, (err, data) ->
      assert.ifError err
      assert data.length is 1
      done()