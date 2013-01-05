$('document').ready ->
	$.get '/res/schema.yaml', (info)->
		schemas = jsyaml.load info
		window.models = {}
		for classname, schema of schemas
			models[classname] = genclass classname, schema.attrs, schema.links
			models[classname+'list'] = gencol classname, models[classname]
		window.main()
	window.lookup = (id, type)->
		return cache[id] if cache[id]
		obj = new models[type]
		obj.id = id
		cache[id] = obj
		api.query obj.id
		return obj