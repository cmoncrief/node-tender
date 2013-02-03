assert = require 'assert'
client = require('../lib/tender').createClient()

discussionId = {}
discussion = {}

createTestDiscussion = ->
    title: "Test #{new Date().getTime()}"
    category: client.testData.category
    body: "Testing 1-2-3"
    extras: {test: 'test'}

# The creation, reply and delete tests are structured to insure that only a 
# single discussion is created for testing purposes. This should cut down
# on spam and extraneous test discussions in the event of failures and also
# helps prevent potential rate limiting issues during testing.

describe 'Discussion creation and replying', ->

  before (done) ->
    discussion = createTestDiscussion()
    client.createDiscussion discussion, (err, data) ->
      assert.ifError err
      assert data and data.id
      assert.equal data.comments[0].body, discussion.body
      assert.equal data.title, discussion.title
      assert.equal data.extras.test, 'test'
      discussionId = data.id
      done()

  beforeEach ->
    discussion = createTestDiscussion()

  it 'should create a discussion', ->
    assert discussionId

  it 'should return an error if no title is specfied', (done) ->
    delete discussion.title
    client.createDiscussion discussion, (err, data) ->
      assert err
      if data?.id then discussionId = data.id
      done()

  it 'should return an error if no body is specfied', (done) ->
    delete discussion.body
    client.createDiscussion discussion, (err, data) ->
      assert err
      if data?.id then discussionId = data.id
      done()

  it 'should return an error if no category is specfied', (done) ->
    delete discussion.category
    client.createDiscussion discussion, (err, data) ->
      assert err
      if data?.id then discussionId = data.id
      done()

  it 'should return an error if an invalid category is specified', (done) ->
    discussion.category = "Invalid Category For Testing"
    client.createDiscussion discussion, (err, data) ->
      assert err
      if data?.id then discussionId = data.id
      done()

  it 'should return an error for an invalid action', (done) ->
    client.actionDiscussion {id: discussionId, action: 'transmogrify'}, (err, data) ->
      assert err
      done()

  it 'should return an error for an invalid discussion', (done) ->
    client.actionDiscussion {id: '-1', action: 'resolve'}, (err, data) ->
      assert err
      done()

  it 'should reply to a discussion', (done) ->
    body = "API Test #{new Date().getTime()}"
    client.replyDiscussion {id: discussionId, body: body}, (err, data) ->
      assert.ifError err
      assert data and data.id
      newComment = i for i in data.comments when i.body is body
      assert newComment
      done()

  it 'should reply to a discussion with an internal comment', (done) ->
    body = "API Test #{new Date().getTime()}"
    client.replyDiscussion {id: discussionId, body: body, internal: true}, (err, data) ->
      assert.ifError err
      assert data and data.id
      newComment = i for i in data.comments when i.body is body and i.internal
      assert newComment
      done()

  it 'should toggle the discussion to public', (done) ->
    client.toggleDiscussion {id: discussionId}, (err, data) ->
      assert.ifError err
      assert data and data.id
      assert data.public
      done()

  it 'should resolve the discussion', (done) ->
    client.resolveDiscussion {id: discussionId}, (err, data) ->
      assert.ifError err
      assert data and data.id
      assert.equal data.state, 'resolved'
      done()

  it 'should unresolve the discussion', (done) ->
    client.reopenDiscussion {id: discussionId}, (err, data) ->
      assert.ifError err
      assert data and data.id
      assert.equal data.state, 'open'
      done()

  it 'should return an error if no queue is specified for queueing', (done) ->
    options = id: discussionId
    client.queueDiscussion options, (err, data) ->
      assert err
      done()

  it 'should queue the discussion', (done) ->
    options = id: discussionId, action: 'queue', queue: client.testData.queue
    client.queueDiscussion options, (err, data) ->
      assert.ifError err
      assert data.result
      done()

  it 'should unqueue the discussion', (done) ->
    options = id: discussionId, queue: client.testData.queue
    client.unqueueDiscussion options, (err, data) ->
      assert.ifError err
      assert data.result
      done()

  it 'should acknowledge the discussion', (done) ->
    client.acknowledgeDiscussion {id: discussionId}, (err, data) ->
      assert.ifError err
      assert data and data.id
      assert !data.unread
      done()

  it 'should return an error if no category is specified for categorize', (done) ->
    options = id: discussionId
    client.categorizeDiscussion options, (err, data) ->
      assert err
      done()

  it 'should change the discussion category', (done) ->
    options = id: discussionId, category: client.testData.category
    client.categorizeDiscussion options, (err, data) ->
      assert.ifError err
      assert data.result
      done()

  after (done) ->
    client.deleteDiscussion {id: discussionId}, (err, data) ->
      assert.ifError err
      assert data.result
      done()

describe 'Discussion delete', ->

  it 'should delete a discussion', (done) ->
    client.showDiscussion {id: discussionId}, (err, data) ->
      assert err
      done()


