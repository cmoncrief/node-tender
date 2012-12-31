tenderQuery = require '../tender_query'

# API resource class for Users

module.exports = class Users

  constructor: (@client) ->

  # Retrieves an array of Tender users.
  #
  # Parameters:
  #
  # options         - Filtering options (see below)
  # callback        - Called with errors and results
  #
  # Available options:
  #
  # id              - Filter by the specified Id
  # name            - Filter by the exact name
  # pattern         - Filter by regexp pattern on user name
  # max             - Return a maximum number of results
  #
  get: (options, callback) ->

    @options = options

    @options.uri = "#{@client.baseURI}/users"
    @options.uri = "#{@options.uri}/#{options.userId}" if @options.userId

    tenderQuery @client, @options, (err, data) ->
      callback err, data


    