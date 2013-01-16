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

  it 'should return an error if an invalid category is specfied', (done) ->
    discussion.category = "Invalid Category For Testing"
    client.createDiscussion discussion, (err, data) ->
      assert err
      if data?.id then discussionId = data.id
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

  after (done) ->
    client.deleteDiscussion {id: discussionId}, (err, data) ->
      assert.ifError err
      done()

describe 'Discussion delete', ->

  it 'should delete a discussion', (done) ->
    client.showDiscussion {id: discussionId}, (err, data) ->
      assert err
      done()


