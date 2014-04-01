class HashTable
	constructor: (obj={}) ->
		@length = 0
		@items = {}
		for p in obj
			if obj.hasOwnProperty(p)
				@items[p] = obj[p]
				@length++

	setItem: (key,value) ->
		previous = undefined
		if @hasItem(key)
			previous = @items[key]
		else
			@length++
		@items[key] = value
		return previous

	getItem:(key) ->
		if @hasItem(key) then @items[key]  else undefined

	hasItem:(key) ->
		@items.hasOwnProperty(key)

	removeItem:(key) ->
		if @hasItem(key)
			previous = @items[key]
			@length--
			delete @items[key]
			return previous
		else
			return undefined

	keys: ->
		keys = []
		keys.push(k)  for k in @items when @hasItem(k)
		return keys

	values: ->
		values=[]
		values.push(@items[k])  for k in @items when @hasItem(k)

	each:(callback) ->
		callback(k,@items[k]) for k in @items when @hasItem(k)

	clear: ->
		@items = {}
		@length = 0