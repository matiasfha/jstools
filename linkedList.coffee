class LinkedList
	constructor: ->
		@length = 0
		@head   = null

	add: (data) ->
		node =
			data:data
			next:null
		if @head is null
			@head = node
		else
			current = @head
			current = current.next while(current.next)
			current.next = node
		@length++

	item:(index) ->
		if index > -1 and  index < @length
			current = @head
			i = 0
			current = current.next while(i++ < index)
			return current.data
		else
			return null
	find:(value) ->
		current = @head
		current = current.next while(current is not null and current.data is not value)
		return current

	remove: (index) ->
		if index > -1 and index < @length
			current = @head
			i = 0
			if index == 0
				@head = current.next
			else
				while(i++ < index)
					previous = current
					current = current.next
				previous.next = current.next
			@length--
			return current.data
		else
			return null

	size: ->
		return @length

	toArray: ->
		i = 0
		values = []
		current = @head
		while(i++ < @length)
			values.push(current.data)
			current = current.next
		return values
