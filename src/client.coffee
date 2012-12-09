requirejs([
	'vender/jquery',
	'vender/socket.io',
	'vender/js-yaml.min',
	'spark',
	'utils'
], ()->
	$.get '/static/schema.yaml', (data)->
		schemas = jsyaml.load data
		window.models = spark schemas
		requirejs([
			'player'
		], ()->
			requirejs(['main'])
		)
)
