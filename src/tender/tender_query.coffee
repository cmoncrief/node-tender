request = require 'request'
async   = require 'async'

# This class handles all GET requests to the Tender API and has support
# for basic filtering options that are common to all resources.

class TenderQuery

  # Set defaults, run validation on the client and start the request.
  constructor: (@client, @options, @callback) ->

    @options.max = @options.max || 1000
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

  # Main request flow. This works by blocking until the first page is complete,
  # whose results are then parsed to determine how many additional pages there
  # are to pull down. All successive pages are then requested in parallel,
  # and the final combined results are then filtered and returned via the
  # callback function.
  run: (callback) ->

    async.waterfall [
      @getFirstPage,
      @getAdditionalPages
    ], @finalize

    (err, result) =>
      callback err, result

  # Get the first page of results and calculate how many additional pages remain.
  getFirstPage: (callback) =>

    @query (err, response, body) =>

      if err then return callback(err)
      pages = 0

      try
        data = JSON.parse body
      catch error
        return callback new Error("(Tender) #{body}")

      total = if data.total? then Math.min(@options.max, data.total) else @options.max

      if data.per_page? and total > data.per_page
        pages = Math.ceil((total - data.per_page) / data.per_page)

      for key, value of data
        if Array.isArray(value) then @arrayKey = key

      callback null, pages, data

  # Get all remaining pages after the first one and add their data to the results.
  getAdditionalPages: (pages, data, callback) =>

    unless pages then return callback(null, data)

    queue = async.queue @getSinglePage, 5
    queue.drain = () => callback null, data

    while pages
      queue.push pages--, (error, qData) =>
        data[@arrayKey] = data[@arrayKey].concat qData[@arrayKey]

  # Queue worker method called for each additional page after the first one.
  getSinglePage: (page, callback) =>

    @options.qs.page = (page + 1)
    @query (err, response, body) ->
      if err then return callback(err)
      
      try
        data = JSON.parse body
      catch error
        return callback new Error("(Tender) #{body}")

      callback null, data

  # Base function that makes requests to the Tender API and returns the raw
  # results via callback.
  query: (callback) =>

    options = 
      uri: @options.uri
      qs: @options.qs
      encoding: 'utf8'
      headers:
        accept : "application/vnd.tender-v1+json"

    unless @client.token
      options.auth = "#{@client.username}:#{@client.password}"

    request options, (err, response, body) =>
      if err then console.log err
      callback err, response, body

  # Normalize the results by mapping even single results to an array. Also
  # parses an Id for each result if available, since one is not returned
  # by many operations by default.
  finalize: (err, result) =>

    if err then return @callback(err)

    if result[@arrayKey]? and !@options.id
      output = result[@arrayKey]
    else
      output = [result]

    if output[0]?["href"]
      for i in output
        index = i.href.lastIndexOf '/'
        i.id = i.href.substring(index + 1)


    output = @filter output 

    @callback err, output

  # Filters the final results by the common options. Resource specific filtering
  # options are handled in the individual classes.
  filter: (data) ->
    
    unless data.length then return data

    if @options.name or @options.pattern
      data = (i for i in data when @matchName(i))

    if @options.id and data[0].id
      data = (i for i in data when i.id is @options.id)

    if data.length > @options.max
      data = data.slice(0, @options.max)

    return data

  # Returns true if the name of the item matches the filtering options
  matchName: (item) ->

    name = item.name || item.title
    unless name then return false

    if @options.pattern
      re = new RegExp "#{@options.pattern}", "gi"
      matches = name.match(re)
      if matches then return true
    else
      if name.toLowerCase() is @options.name.toLowerCase()
        return true

    return false

tenderQuery = (client, options, callback) ->
  new TenderQuery(client, options, callback)

module.exports = tenderQuery
