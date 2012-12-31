tenderQuery = require '../tender_query'

# API resource class for Queues

module.exports = class Queues

  constructor: (@client) ->

  # Retrieves an array of Tender queues.
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
  # pattern         - Filter by regexp pattern on queue name
  # max             - Return a maximum number of results
  #
  get: (options, callback) ->

    @options = options

    @options.uri = "#{@client.baseURI}/queues"
    @options.uri = "#{@options.uri}/#{options.id}" if @options.id

    tenderQuery @client, @options, (err, data) ->
      callback err, data


    