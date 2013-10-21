Object.toType = (toType = (global) ->
	(obj) ->
		return "global"  if obj is global
		({}).toString.call(obj).match(/\s([a-z|A-Z]+)/)[1].toLowerCase()
)(this)