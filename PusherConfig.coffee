###
PusherConfig class as Singleton Class
writen as require.js module
###

define [
	'backbone'
	'pusher'
	'UIMessages'
],(Backbone,Pusher,UIMessages) ->

	class PusherModel extends Backbone.Model

	class PusherConfig

		instance = null

		@getInstance:(options) ->
			if not @instance?
				@instance = new PusherConfig(options)
			@instance

		constructor:() ->
			@notifications = Application.notifications
			@init()
			return @

		getPusher:() =>
			@pusher
		
		init: ->
			Pusher.channel_auth_endpoint = "/pusher/auth/"
			# Pusher.log = (message)  ->
			# 	if (window.console && window.console.log)
			# 		window.console.log(message)
			@pusher = new Pusher(Settings.PUSHER_API_KEY)
			@pusher.connection.bind 'connected', @onConnected
			@pusher.connection.bind 'disconnected',@onDisconnected

			@pusher.connection.bind 'failed', @onFailedConnection

		onConnected: =>
			channel_name = Settings.PUSHER_CHANNEL_NAME + Application.user.get('id')
			@pusher_channel = @pusher.subscribe(channel_name)

			@pusher_channel.bind 'pusher:subscription_succeeded',@onSubscribed
			@pusher_channel.bind 'pusher:subscription_error',@onSubscribeFailed

		onFailedConnection: ->
			alert UIMessages.PUSHER_FAIL_MESSAGE

		onSubscribeFailed: ->
			alert UIMessages.PUSHER_SUBSCRIPTION_FAIL

		onSubscribed: =>
			@pusher_channel.bind 'update', @onPusherUpdate
			@pusher_channel.bind 'create', @onPusherCreate
			@pusher_channel.bind 'destroy', @onPusherDestroy         

		onPusherCreate:(data) =>
			@notifications.push data
			@notifications.trigger 'pusher_add',data
			

		onPusherUpdate:(data) =>
			@notifications.trigger 'pusher_update',data
			false
		
		onPusherDestroy:(data) =>
			false

		destroy: =>
			channel_name = Settings.PUSHER_CHANNEL_NAME + Application.user.get('id')
			@pusher.unsubscribe(channel_name)
			@pusher.disconnect()

		onDisconnected: =>
			console.log "Pusher disconnected #{@pusher.connection.state}"


