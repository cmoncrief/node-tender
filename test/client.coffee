assert = require 'assert'
tender = require('../lib/tender')

describe 'Client', ->

  it 'should load resource classes', ->
    client = tender.createClient()
    assert client.discussions
    assert client.categories
    assert client.queues
    assert client.users

  it 'should load configuration data from a file', ->
    client = tender.createClient()
    assert client.subdomain
    assert client.username or client.token

  it 'should override configuration data', ->
    client = tender.createClient {username: 'auto', password: 'auto', subdomain: 'auto', token: 'auto'}
    assert.equal client.subdomain, 'auto'
    assert.equal client.username, 'auto'
    assert.equal client.password, 'auto'
    assert.equal client.token, 'auto'