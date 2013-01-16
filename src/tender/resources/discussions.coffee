async        = require 'async'
tenderQuery  = require '../tender_query'
tenderUpdate = require '../tender_update'

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

    @buildGetQueryString()

    @buildGetURI (err) =>
      
      if err then return callback(err)

      tenderQuery @client, @options, (err, data) ->
        callback err, data

  # Retrieve a single discussion object by Id.
  #
  # Parameters:
  #
  # options          - (see below)
  # callback         - Called with errors and results
  #
  # Available options:
  #
  # id               - The discussion id to return
  #
  show: (options, callback) ->

    @options = options
    
    unless @options.id 
      return callback new Error("No discussion Id specified")

    @options.uri = "#{@client.baseURI}/discussions/#{@options.id}"

    tenderQuery @client, @options, (err, data) ->

      if err then return callback(err)
      unless data.length then return callback(new Error("Discussion not found"))

      callback null, data[0]

  # Create a new discussion
  #
  # Parameters:
  #
  # options          - (see below)
  # callback         - Called with errors and results
  #
  # Available options:
  #
  # title            - The title of the new discussion
  # body             - The body text of the new discussion
  # category         - The category name to post under
  # authorEmail      - The email of the creator (defaults to current user)
  # authorName       - The name of the discussion creator (defaults to current user)
  # trusted          - Skip spam checking for this user (defaults to true)
  # skipSpam         - Skip comment level spam checking (defaults to true)
  # public           - Public or private discussion (defaults to true)
  # extras           - Additional data to tie to the discussion
  # uniqueId         - The unique Id of the creator (optional)
  #
  post: (options, callback) ->

    unless options.title then return callback new Error("No title specified")
    unless options.body then return callback new Error("No body specified")

    @options = {}
    @options.data = options

    @options.data.public ?= true
    @options.data.skipSpam ?= true
   
    @buildCreateURI (err) =>

      if err then return callback(err)

      tenderUpdate @client, @options, (err, data) ->
        if err then return callback(err)
        unless data then return callback(new Error("Error creating discussion"))
        callback null, data

  # Reply to an existing discussion with a new comment
  #
  # Parameters:
  #
  # options          - (see below)
  # callback         - Called with errors and results
  #
  # Available options:
  #
  # id               - The discussion id to reply to
  # body             - The body text of the new discussion
  # authorEmail      - The email of the creator (defaults to current user)
  # authorName       - The name of the discussion creator (defaults to current user)
  # trusted          - Skip spam checking for this user (defaults to true)
  # skipSpam         - Skip comment level spam checking (defaults to true)
  # internal         - Internal discussion flag (defaults to false)
  # uniqueId         - The unique Id of the creator (optional)
  #
  reply: (options, callback) ->

    unless options.id then return callback new Error("No discussion specified")
    unless options.body then return callback new Error("No body specified")

    @options = {}
    @options.data = options
    @options.uri = "https://api.tenderapp.com/#{@client.subdomain}/discussions/#{options.id}/comments"

    @options.data.public ?= true
    @options.data.skipSpam ?= true

    tenderUpdate @client, @options, (err, data) ->
      if err then return callback(err)
      unless data then return callback(new Error("Error commenting discussion"))
      callback null, data

  # Delete a single discussion object by Id.
  #
  # Parameters:
  #
  # options          - (see below)
  # callback         - Called with errors and results
  #
  # Available options:
  #
  # id               - The discussion id to delete
  #
  delete: (options, callback) ->

    unless options.id then return callback new Error("No discussion specified")

    @options = {}
    @options.uri = "https://api.tenderapp.com/#{@client.subdomain}/discussions/#{options.id}"
    @options.method = "DELETE"

    tenderUpdate @client, @options, (err, data) ->
      if err then return callback(err)
      unless data then return callback(new Error("Error deleting discussion"))
      callback null, data

  # Construct the URI for create discussion requests by fetching the Id of 
  # the category that has been specified.
  buildCreateURI: (callback) ->

    unless @options.data.category then return callback(new Error("No category specified"))

    @client.getCategories {name: @options.data.category}, (err, data) =>
      if err then return callback(err)
      unless data.length then return callback(new Error("Category not found"))

      @options.uri = "https://api.tenderapp.com/#{@client.subdomain}/categories/#{data[0].id}/discussions"
      callback null

  # Constructs the query string based on specified filter options
  buildGetQueryString: ->
    
    qs = {}
    if @options.userId then qs.user_id = @options.userId
    if @options.userEmail then qs.user_email = @options.userEmail
    if @options.sinceDiscussionId then qs.since = @options.sinceDiscussionId
    @options.qs = qs

  # Constructs the request URI based on specified filter options. This will use
  # the related resource APIs to resolve Ids for categories and queues if 
  # needed. This verison is only for GET requests.
  buildGetURI: (callback) ->

    uri = @client.baseURI

    postURI = ""

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

