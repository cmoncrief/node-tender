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

  getDiscussions: (options, callback) ->
    @discussions.get options, callback

  showDiscussion: (options, callback) ->
    @discussions.show options, callback

  createDiscussion: (options, callback) ->
    @discussions.post options, callback

  replyDiscussion: (options, callback) ->
    @discussions.reply options, callback

  actionDiscussion: (options, callback) ->
    @discussions.action options, callback

  toggleDiscussion: (options, callback) ->
    @discussions.action {action: 'toggle', id: options.id}, callback

  resolveDiscussion: (options, callback) ->
    @discussions.action {action: 'resolve', id: options.id}, callback

  reopenDiscussion: (options, callback) ->
    @discussions.action {action: 'unresolve', id: options.id}, callback

  acknowledgeDiscussion: (options, callback) ->
    @discussions.action {action: 'acknowledge', id: options.id}, callback

  restoreDiscussion: (options, callback) ->
    @discussions.action {action: 'restore', id: options.id}, callback

  categorizeDiscussion: (options, callback) ->
    @discussions.action {action: 'changeCategory', id: options.id, category: options.category}, callback

  queueDiscussion: (options, callback) ->
    @discussions.action {action: 'queue', id: options.id, queue: options.queue}, callback

  unqueueDiscussion: (options, callback) ->
    @discussions.action {action: 'unqueue', id: options.id, queue: options.queue}, callback

  deleteDiscussion: (options, callback) ->
    @discussions.delete options, callback

  getQueues: (options, callback) ->
    @queues.get options, callback

  getCategories: (options, callback) ->
    @categories.get options, callback

  getUsers: (options, callback) ->
    @users.get options, callback
