# tender
# Copyright (c) 2012 Charles Moncrief <cmoncrief@gmail.com>
# MIT Licensed

Client = require './tender/client'

# Main entry point which returns a new client initialized with
# the passed in options.
exports.createClient = (options) -> 
  new Client(options)