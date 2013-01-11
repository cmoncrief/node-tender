async       = require 'async'
tenderQuery = require '../tender_query'

# API resource class for Categories

module.exports = class Categories

  constructor: (@client) ->

  # Retrieves an array of Tender categories.
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
  # pattern         - Filter by regexp pattern on category name
  # max             - Return a maximum number of results
  #
  get: (options, callback) ->

    @options = options

    @options.uri = "#{@client.baseURI}/categories"
    @options.uri = "#{@options.uri}/#{options.id}" if @options.id

    tenderQuery @client, @options, (err, data) ->
      unless data then return callback(new Error("Category not found"))
      callback err, data


    