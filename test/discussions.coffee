assert = require 'assert'
client = require('../lib/tender').createClient()

describe 'Get discussions', ->
    
  it 'should get a list of discussions', (done) ->
    options = max: 20
    client.getDiscussions options, (err, data) ->
      assert.ifError err
      assert data.length
      assert data.length <= 20
      done()
  
  it 'should get discussions by state (open)', (done) ->
    options = max: 20, state: "open"
    client.getDiscussions options, (err, data) ->
      assert.ifError err
      assert data.length
      done()

  it 'should get discussions matching a title pattern', (done) ->
    options = max: 20, pattern: client.testData.pattern, state: "open"
    client.getDiscussions options, (err, data) ->
      assert.ifError err
      assert data.length
      done()

  it 'should get discussions created by a user', (done) ->
    options = max: 20, userId: client.testData.userId
    client.getDiscussions options, (err, data) ->
      assert.ifError err
      assert data.length
      done()

  it 'should get discussions in a queue', (done) ->
    options = max: 20, queue: client.testData.queue
    client.getDiscussions options, (err, data) ->
      assert.ifError err
      assert data.length
      done()

  it 'should get discussions in a category', (done) ->
    options = max: 20, category: client.testData.category
    client.getDiscussions options, (err, data) ->
      assert.ifError err
      assert data.length
      done()

  it 'should return an error on an invalid queue request', (done) ->
    options = max: 20, queue: 'thisdoesnotexist'
    client.getDiscussions options, (err, data) ->
      assert err
      done()

  it 'should return an error on an invalid category request', (done) ->
    options = max: 20, category: 'thisdoesnotexist'
    client.getDiscussions options, (err, data) ->
      assert err
      done()

describe 'Show discussion', ->

  it 'should show details for a single dicussion by id', (done) ->
    options = {id: client.testData.discussionId}
    client.showDiscussion options, (err, data) ->
      assert.ifError err
      assert !Array.isArray(data)
      assert.equal data.id, client.testData.discussionId
      done()

  it 'should error if show is called with no id', (done) ->
    client.showDiscussion {}, (err, data) ->
      assert err
      done()

  it 'should error if show is called with an invalid id', (done) ->
    client.showDiscussion {id: 'invalid'}, (err, data) ->
      assert err
      done()
