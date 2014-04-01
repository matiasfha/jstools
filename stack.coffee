class Stack
	constructor: ->
		@elements = []
		@length = 0

	push:(element) ->
		@elements.push element

	pop: ->
		@elements.pop()

