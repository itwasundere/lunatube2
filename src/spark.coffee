globals = window || module.exports

now = ()-> (new Date).getTime()

globals.store = (id, attrs, res)->
  if id
    res id
  else
    res now()
globals.fetch = (id, res)->
  res {}

models = {};
cache = {};
save = (inst)->
  store inst._id, inst._attrs, (id)->
    inst._id = id
    cache[id] = inst
    inst.emit 'saved'
load = (inst)->
  return if not inst._id
  fetch inst._id, (attrs)->
    inst._attrs = attrs
    cache[inst._id] = inst
    inst.emit 'ready'

globals.resolve = (id,type)->
  return null if not id
  return cache[id] if cache[id]
  return null if not type
  cache[id] = new models[type]({_id: id})

gen_class = (name, schema)->
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
    _links: schema.links
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
        this._attrs['_'+key] = val._id
    bind: (key, res)->
      this._events[key]=[] if not this._events[key]
      this._events[key].push res
    emit: (key, data)->
      return if not this._events[key]
      for res in this._events[key]
        res(data)
    save: ()->save(this) if save
    load: ()->load(this) if load

gen_list = (name, model)->
  class
    _type: name
    _model: model
    _models: []
    get: (idx)->
      resolve this._models[idx], this._type if this._models[idx]
    add: (model, idx)->
      idx ?= this._models.length
      this._models.splice idx, 0, model._id
    remove: (model)->
      idx = this._models.indexOf(model._id)
      this._models.splice(idx, 1) if idx > -1
    save: ()->save(this) if save
    load: ()->load(this) if load

globals.spark = (schemas)->
  for name, schema of schemas
    models[name] = gen_class name, schema
    models[name+'list'] = gen_list name, models[name]
  return models