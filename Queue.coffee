class Queue
	constructor: ->
		@elements = []
		@length = 0

	enqueue: (element) ->
		@elements.push element

	remove: ->
		@elements.shift()
