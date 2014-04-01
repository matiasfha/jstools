
class BinaryTree
	constructor:(rootValue) ->
		@root =
			value:rootValue
			left:null
			right:null

		@length = 1

	add:(value) ->
		newNode =
			value: value
			left:null
			right:null
		node = @root
		loop
			if value >= node.value
				if node.right is null
					node.right = newNode
					break
				else
					node = node.right
			else
				if node.left is null
					node.left = newNode
					break
				else
					node = node.left
		@length++

	walk:(callback) ->
		@walkFromNode(callback,@root)

	walkFromNode:(callback,node) ->
		@walkFromNode(callback,node.left) unless node.left is null
		callback(node)
		@walkFromNode(callback,node.right) unless node.right is null

	toString: ->
		values = []
		@walk (node) -> values.push node.value
		values.join(', ')

	contains: (value) ->
		found = false
		current = @root
		while(not found and current is not null)
			if value < current.value
				current = current.left
			else if(value > current.value)
				current = current.right
			else
				found = true
		return found

	traverse: (callback) ->
		inOrder = (node) ->
			if node is not null
				if node.left is not null
					inOrder(node.left)
				callback.call(@,node)

				if node.right is not null
					inOrder(node.right)
		inOrder(@)

	size: ->
		@leng
