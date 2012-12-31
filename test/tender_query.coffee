assert = require 'assert'
tender = require('../lib/tender')

describe 'Tender request', ->

  it 'should return a local error if no authentication is used', (done) ->
    client = tender.createClient()
    client.username = ''
    client.password = ''
    client.token = ''
    client.getDiscussions {max : 1}, (error, results) ->
      assert error
      assert.equal error.message.indexOf('(Tender)'), -1
      done()

  it 'should return a local error if username is not specified', (done) ->
    client = tender.createClient()
    client.username = ''
    client.token = ''
    client.getDiscussions {max : 1}, (error, results) ->
      assert error
      assert.equal error.message.indexOf('(Tender)'), -1
      done()

  it 'should return a local error if password is not specified', (done) ->
    client = tender.createClient()
    client.password = ''
    client.token = ''
    client.getDiscussions {max : 1}, (error, results) ->
      assert error
      assert.equal error.message.indexOf('(Tender)'), -1
      done()

  it 'should return a local error if subdomain is not specified', (done) ->
    client = tender.createClient()
    client.subdomain = ''
    client.getDiscussions {max : 1}, (error, results) ->
      assert error
      assert.equal error.message.indexOf('(Tender)'), -1
      done()

  it 'should return a remote error if invalid authentication is used', (done) ->
    client = tender.createClient {username: 'test', password: 'test', subdomain: 'test'}
    client.getDiscussions {max : 1}, (error, results) ->
      assert error
      assert.notEqual error.message.indexOf('(Tender)'), -1
      done()
