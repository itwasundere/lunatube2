$.get '/static/schema.yaml', (data)->
	schemas = jsyaml.load data
	window.models = spark schemas
