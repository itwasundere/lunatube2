if (typeof window != "undefined")
  globals = window || module.exports
else globals = module.exports

now = ()-> (new Date).getTime()
contains = (needle, haystack)->
  for el in haystack
    return true if `needle == el`

globals.store = (inst, res)->
  if id
    res id
  else
    res now()
globals.fetch = (inst, res)->
  res {}
globals.query = (type, query, res)->
  res []

models = {};
cache = {};
globals.sparkcache = cache
save = (inst)->
  globals.store inst, (id)->
    inst._id = id
    cache[id] = inst
    inst.emit 'saved'
load = (inst)->
  return if not inst._id
  globals.fetch inst, (attrs)->
    if inst._attrs
      inst._attrs = attrs
    else
      inst._models = attrs
    cache[inst._id] = inst
    inst._ready = true
    inst.emit 'ready'
query = (inst,query)->
  type = inst._modeltype
  globals.query type, query, (models)->
    inst._models = models
    inst._ready = true
    inst.emit 'ready'

globals.resolve = (id,type)->
  return null if not id
  return cache[id] if cache[id]
  return null if not type
  cache[id] = new models[type]({_id: id})

globals.gen_class = (name, schema)->
  schema = {} if not schema
  attrs = {}
  for link of schema.links
    attrs['_'+link] = null
  for attr of schema.attrs
    attrs[attr] = null
  class
    constructor: (@_construction)->
      for k,v of _construction
        this._attrs[k]=v if k of this._attrs
      if _construction and _construction._id
        this._id = _construction._id
        this.load()
    _links: schema.links or {}
    _attrs: attrs
    _events: {}
    _type: name
    get: (key)->
      return this._attrs[key] if key of this._attrs
      return resolve(this._attrs['_'+key],this._links[key]) if '_'+key of this._attrs
    set: (key, val)->
      if key of this._attrs
        this._attrs[key] = val
      else if '_'+key of this._attrs
        console.warn this._type+' setting unsaved '+val._type if not val._id
        this._attrs['_'+key] = val._id
    bind: (key, res)->
      this._events[key]=[] if not this._events[key]
      this._events[key].push res
      res() if key == 'ready' and this._ready
    emit: (key, data)->
      return if not this._events[key]
      for res in this._events[key]
        res(data)
    save: ->save(this) if save
    load: ->load(this) if load

globals.gen_list = (name, model)->
  class
    _type: name+'list'
    _modeltype: name
    _model: model
    _models: []
    _events: {}
    constructor: (@_construction)->
      if _construction and _construction._id
        this._id = _construction._id
        this.load()
    get: (id)->
      return globals.resolve id,this._modeltype if contains(id,this._models)
      return null
    at: (idx)->
      globals.resolve this._models[idx], this._modeltype if this._models[idx]
    add: (model, idx)->
      console.warn this._type+' adding unsaved '+this._modeltype if not model._id
      idx ?= this._models.length
      this._models.splice idx, 0, model._id
    remove: (model)->
      idx = this._models.indexOf(model._id)
      this._models.splice(idx, 1) if idx > -1
    bind: (key, res)->
      this._events[key]=[] if not this._events[key]
      this._events[key].push res
      res() if key == 'ready' and this._ready
    emit: (key, data)->
      return if not this._events[key]
      for res in this._events[key]
        res(data)
    save: (res)->save(this) if save
    load: (res)->load(this) if load
    all: ->query(this,{})
    query: (filter)->query(this,filter)

globals.spark = (schemas)->
  for name, schema of schemas
    classname = name
    models[name] = globals.gen_class name, schema
    models[name+'list'] = globals.gen_list name, models[name]
  return models
