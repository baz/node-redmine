url = require 'url'
querystring = require 'querystring'
rest = require 'restler'

class Redmine
	constructor: ->
		@apiPath = null
		@username = null
		@password = null

	authenticate: (username, password, location, callback) ->
		@apiPath = location
		@username = username
		@password = password

		@_get 'projects', (error, response) ->
			callback error, if error then false else true

	projectURL: ->
		return @apiPath

	allProjects: (callback) ->
		@_get 'projects', null, callback

	projectTrackers: (projectID, callback) ->
		params =
			include: 'trackers'
		@_get 'projects/' + projectID, params, callback

	allUsers: (callback) ->
		@_get 'users', null, callback

	allIssues: (projectID, limit, callback) ->
		params =
			sort: 'updated_on:desc'
			limit: limit
			project_id: projectID
		@_get 'issues', params, callback

	_get: (resource, params, callback) ->
		if params then query = querystring.stringify(params) else query = ''
		request = rest.get(url.resolve(@apiPath, resource + '.json?' + query), {username: @username, password: @password})
		request.on 'success', (data) ->
			callback null, data
		request.on 'error', (data, response) ->
			error = 'Error with HTTP status code: ' + response.statusCode
			if response.statusCode == 401
				error = 'Bad credentials.  Please try entering your username and password again.'
			else if data.errors
				error = 'TODO, some errors were encountered'
			callback error, null


module.exports = new Redmine
