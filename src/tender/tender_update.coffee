request = require 'request'
async   = require 'async'
morph   = require 'morph'

# This class handles all POST requests to the Tender API

class TenderUpdate

  # Set defaults, run validation on the client and start the request.
  constructor: (@client, @options, @callback) ->

    @options.qs = @options.qs || {}

    unless @client.subdomain and typeof @client.subdomain is "string"
      return @callback new Error("No subdomain specified")

    if @client.token
      @options.qs.auth = @client.token
    else if @client.username or @client.password
      unless @client.username
        return @callback new Error("No username specified")

      unless @client.password
        return @callback new Error("No password specified")
    else
      return @callback new Error("No authentication specified")

    @run (err, data) => 
      @callback(err, data)

  # Main create/update flow. Initialize the argument, perform the update, then finalize the return
  # data and return the results in the callback.
  run: (callback) =>

    async.waterfall [
      @init,
      @update,
      @finalize
    ], (err, result) ->
      callback err, result

  # Initialize and validate the data to be posted.
  init: (callback) =>

    if @options.data then @options.data = morph.toSnake @options.data

    callback null

  # Base function that makes post to the Tender API and returns the raw
  # results via callback.
  update: (callback) =>

    options = 
      uri: @options.uri
      qs: @options.qs
      json: @options.data
      encoding: 'utf8'
      method: @options.method || "POST"
      headers:
        accept : "application/vnd.tender-v1+json"

    unless @client.token
      options.auth = "#{@client.username}:#{@client.password}"

    request options, (err, response, body) =>
      if err then console.log err
      if body is "The page you are looking for can\'t be found"
        return callback(new Error("Resource not found"))

      callback null, response, body

  # Perform final validation and mapping on the result object
  finalize: (response, body, callback) ->

    if body?.href?
      body.id = body.href.substring(body.href.lastIndexOf('/') + 1)

    callback null, body

tenderUpdate = (client, options, callback) ->
  new TenderUpdate(client, options, callback)

module.exports = tenderUpdate
