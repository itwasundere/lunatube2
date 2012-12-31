fs = require 'fs'
stylus = require 'stylus'
express = require 'express'
yaml = require 'js-yaml'
read = fs.readFileSync

app = express()
app.use '/res', express.static process.cwd()+'/res'
app.use '/lib', express.static process.cwd()+'/lib'

app.get '/', (req, res)->
	res.render 'test.jade'

app.get '/r/:id', (req, res)->
	res.render 'room.jade'

app.get '/css/icons.css', (req, res)->
	sheet_name = process.cwd()+'/css/icons.css'
	sheet = stylus read sheet_name, 'utf8'
	sheet.render (err, css)->
		res.writeHead 200, {'Content-Type': 'text/css'}
		res.end css

app.get '/css/:color.css', (req, res)->
	themes_name = process.cwd()+'/res/colors.yaml'
	themes = yaml.load read themes_name, 'utf8'
	theme = themes[req.params.color] or {}
	sheet_name = process.cwd()+'/css/room.css'
	sheet = stylus read sheet_name, 'utf8'
	for key, value of theme
		sheet.define '_'+key, new stylus.nodes.Literal '#'+value
	sheet.render (err, css)->
		res.writeHead 200, {'Content-Type': 'text/css'}
		res.end css

app.listen 8080
