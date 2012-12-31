async = require 'async'
tenderQuery = require '../tender_query'

states = ['new', 'open', 'assigned', 'resolved', 'pending', 'deleted']

module.exports = class Discussions

  constructor: (@client) ->

  # Retrieves an array of Tender discussions.
  #
  # Parameters:
  #
  # options         - Filtering options (see below)
  # callback        - Called with errors and results
  #
  # Available options:
  #
  # id              - Filter by the specified Id
  # name            - Filter by the exact discussion title
  # pattern         - Filter by regexp pattern on discussion title
  # category        - Filter by category name
  # queue           - Filter by queue name
  # state           - Filter by discussion state
  # userId          - Filter by user Id
  # userEmail       - Filter by user email
  # max             - Return a maximum number of results
  #
  get: (options, callback) ->

    @options = options

    @buildQueryString()

    @buildURI (err) =>
      
      if err then return callback(err)

      tenderQuery @client, @options, (err, data) ->
        callback err, data

  # Constructs the query string based on specified filter options
  buildQueryString: ->
    
    qs = {}
    if @options.userId then qs.user_id = @options.userId
    if @options.userEmail then qs.user_email = @options.userEmail
    if @options.sinceDiscussionId then qs.since = @options.sinceDiscussionId
    @options.qs = qs

  # Constructs the request URI based on specified filter options. This will use
  # the related resource APIs to resolve Ids for categories and queues if 
  # needed.
  buildURI: (callback) ->

    uri = @client.baseURI

    postURI = ""
    postURI = "#{@options.id}" if @options.id

    if @options.state and @options.state not in states
      return callback new Error('Invalid discussion state')
    else if @options.state
      postURI = "#{@options.state}" if @options.state

    if @options.queue
      @client.getQueues {pattern: @options.queue}, (err, data) =>

        if err then return callback(err)
        unless data.length then return callback(new Error("Queue not found"))
        
        @options.uri = "#{uri}/queues/#{data[0].id}/discussions/#{postURI}"
        callback null
    
    else if @options.category
      @client.getCategories {name: @options.category}, (err, data) =>

        if err then return callback(err)
        unless data.length then return callback(new Error("Category not found"))

        @options.uri = "#{uri}/categories/#{data[0].id}/discussions/#{postURI}"
        callback null

    else
      @options.uri = "#{uri}/discussions/#{postURI}"
      callback null