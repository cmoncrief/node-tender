# Tender client for Node.js

A Node.JS client implementation for ENTP's [Tender API](https://help.tenderapp.com/kb/api).

## Installation

Install with npm:

    $ npm install tender

## Basic usage

The following will create a new API client and retrieve a list of all pending discussions.

    var tender = require('tender')

    var client = tender.createClient({
      token: 'your-api-token',
      subdomain: 'your-tender-subdomain'
    })

    client.getDiscussions({state: 'pending'}, function(err, data) {
      console.dir(data)
    })

## Authentication

Authentication via API token or username/password are both supported. When creating the client, pass either the token or the username and password in addition to your Tender subdomain.

##### API Token:

    var client = tender.createClient({
      token: 'your-api-token',
      subdomain: 'your-tender-subdomain'
    })

##### Username/password:

    var client = tender.createClient({
      username: 'someone@somewhere.com',
      password: 'password123',
      subdomain: 'your-tender-subdomain'
    })

## Discussions

### client.createDiscussion(options, callback)

Creates a discussion and returns the new object. Takes the following options:

* `category`        - Category name to post under. **(required)**
* `title`           - Discussion title. **(required)**
* `body`            - Body of initial comment. **(required)**
* `public`          - Public/private switch. Defaults to true.
* `skipSpam`        - Ignore spam checking. Defaults to true.
# `uniqueId`        - Unique Id of poster, for use with SSO. 
* `authorEmail`     - Email to post under. If not specified, uses the authenticated user.
* `authorName`      - Name to post under. If not specified, uses the authenticated user.
* `trusted`         - Skip spam checking if this is a new user. Defaults to true.
* `extras`          - Object hash containing additional attributes.

#### Example:

    client.createDiscussion({
      category: 'Problems',
      title: 'Example discussion',
      body: 'Help!'
    }, function(err, data) {
      console.dir(data)
    })

### client.getDiscussions(options, callback)

Retrieves an array of discussions, filtered by the options specified in the first argument:

* `name`            - Filter by the exact discussion title
* `pattern`         - Filter by regexp pattern on discussion title
* `category`        - Filter by category name
* `queue`           - Filter by queue name
* `state`           - Filter by discussion state
* `userId`          - Filter by user Id
* `userEmail`       - Filter by user email
* `max`             - The maximum number of results to return. Defaults to 1000.

##### Example:

The following will retrieve a maximum of 100 discussions in the 'Problems' category that have the text 'login' in the title and are in the 'Assigned' state.

    client.getDiscussions({
      state: 'assigned',
      category: 'problems',
      pattern: 'fvid',
      max: 100
    }, function(err, data) {
      console.dir(data.length)
    })

### client.showDiscussion(options, callback)

Retrieves a single discussion object with comments. The first argument currently supports a single option: 

* `id`              - The discussion Id to retrieve

##### Example:

    client.showDiscussion({id : '123456679'}, function(err, data) {
      console.dir(data)
    })

### client.replyDiscussion(options, callback)

Replies to a discussion with a new comment. Takes the following options in the first argument:

* `id`              - The discussion Id to reply to. **(required)**
* `body`            - The body text of the reply. **(required)**
* `internal`        - Toggle comment to internal only. Defaults to false.
* `skipSpam`        - Ignore spam checking. Defaults to true.
# `uniqueId`        - Unique Id of poster, for use with SSO. 
* `authorEmail`     - Email to post under. If not specified, uses the authenticated user.
* `authorName`      - Name to post under. If not specified, uses the authenticated user.
* `trusted`         - Skip spam checking if this is a new user. Defaults to true.

##### Example:

    client.replyDiscussion({
      id: '123456679',
      body: 'Example reply',
    }, function(err, data) {
      console.dir(data)
    })

### client.deleteDiscussion(options, callback)

Fully deletes a single discussion. The first argument currently supports single option:

* `id`              - The discussion Id to delete

##### Example:

    client.deleteDiscussion({id : '123456679'}, function(err, data) {
      console.log(data)
    })

## Categories

### client.getCategories(options, callback)

Retrieves an array of categories, filtered by the options specified in the first argument:

* `id`              - Filter by a specific category Id
* `name`            - Filter by the exact category name
* `pattern`         - Filter by regexp pattern on category name
* `max`             - The maximum number of results to return. Defaults to 1000.

## Queues

### client.getQueues(options, callback)

Retrieves an array of queues, filtered by the options specified in the first argument:

* `id`              - Filter by a specific queue Id
* `name`            - Filter by the exact queue name
* `pattern`         - Filter by regexp pattern on queue name
* `max`             - The maximum number of results to return. Defaults to 1000.

## Users

### client.getUsers(options, callback)

Retrieves an array of users, filtered by the options specified in the first argument:

* `id`              - Filter by a specific user Id
* `name`            - Filter by the exact user name
* `pattern`         - Filter by regexp pattern on user name
* `max`             - The maximum number of results to return. Defaults to 1000.

## Local configuration

Client configuration data can optionally be read from a local file if you'd like to keep your authentication data separated from your code. Place a file named `tender_config.json` in the root directory of your application to use it in place of runtime configuration. No special code is neccessary - the file will automatically be loaded if it exists. 

The configuration file should follow the following format. All fields are optional and will be overridden by runtime parameters if specified. The `testData` object is used by the automated tests and should be omitted unless you plan on running them. See below for detail.

    {
      "subdomain": "your-sub-domain",
      "username": "someone@somewhere.com",
      "password": "supersecret",
      "token": "your-api-token",
      "testData" : {
        "queue" : "Test queue",
        "category" : "Test category",
        "categoryId" : "12345"
        "user" : "Charles Moncrief",
        "userId" : "12345",
        "discussionId" : "12345",
        "pattern" : "xyz"
      }
    }
    
## Running the tests

To run the test suite, invoke the following commands in the repository:

    $ npm install
    $ npm test
    
Please note that the majority of the tests rely on a live Tender API account in order to execute. 
To set up the test data for your account, create a local configuration file as shown above and fill out
the `testData` object as follows:

* `queue` - The name of a queue in your account.
* `category` - The name of a category in your account.
* `categoryId` - The unique Id of a category in your account.
* `user` - The full name of a user belonging to your Tender account.
* `userId` - The id of a user belonging to your Tender account.
* `discussionId` - The id of any discussion belonging to your account
* `pattern` - A regexp pattern that will match the title of at least one Open discussion on your account.

A single discussion will be created under the `category` specified above, replied to, and deleted as part of the tests. All other tests perform read operations only.
