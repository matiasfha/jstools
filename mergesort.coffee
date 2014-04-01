# [1, 8, 12, 5].mergeSort()
Array::mergeSort = ->

	# If the array has one element, we're done.
	return this if @length is 1

	# Split the array in half.
	halfwayMark = Math.floor(@length / 2)
	firstHalf = @slice(0, halfwayMark)
	secondHalf = @slice(halfwayMark)

	# Sort the halves.
	firstHalf = firstHalf.mergeSort()
	secondHalf = secondHalf.mergeSort()

	# Construct the result from that.
	result = []
	while firstHalf.length or secondHalf.length
		if firstHalf.length and secondHalf.length
			if firstHalf[0] <= secondHalf[0]
				result.push firstHalf.shift()
			else
				result.push secondHalf.shift()
		else if firstHalf.length
			result.push firstHalf.shift()
		else if secondHalf.length
			result.push secondHalf.shift()

	# All done!
	return result