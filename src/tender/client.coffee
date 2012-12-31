fs          = require 'fs'
path        = require 'path'
resources   = require './resources'

# The main client wrapper class. This handles setting up configuration
# and provides the public API to each individual resource.

module.exports = class Client 

  constructor: (@options) ->
    @discussions = new resources.discussions(this)
    @queues = new resources.queues(this)
    @categories = new resources.categories(this)
    @users = new resources.users(this)

    @loadConfig()
  
  # Sets client configuration options. Defaults are held in a local file and
  # overridden by runtime options.
  loadConfig: ->

    config = {}
    configPath = path.join process.cwd(), 'tender_config.json'

    if fs.existsSync configPath
      config = JSON.parse fs.readFileSync(configPath)

    @subdomain = @options?.subdomain || config.subdomain
    @token = @options?.token || config.token
    @username = @options?.username || config.username
    @password = @options?.password || config.password
    @testData = config.testData

    @baseURI = "https://api.tenderapp.com/#{@subdomain}"

  # GET Discussions
  getDiscussions: (options, callback) ->
    @discussions.get options, callback

  # GET Queues
  getQueues: (options, callback) ->
    @queues.get options, callback

  # GET Categories
  getCategories: (options, callback) ->
    @categories.get options, callback

  # Users
  getUsers: (options, callback) ->
    @users.get options, callback
