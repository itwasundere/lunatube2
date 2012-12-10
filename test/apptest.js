// Generated by CoffeeScript 1.4.0
(function() {
  var fs, models, mongo, schemas, schemas_name, spark, utils, yaml;

  yaml = require('js-yaml');

  fs = require('fs');

  mongo = require('./lib/mongo');

  spark = require('./lib/spark');

  utils = require('./lib/utils');

  schemas_name = __dirname + '/res/schema.yaml';

  schemas = yaml.load(fs.readFileSync(schemas_name, 'utf8'));

  models = spark.spark(schemas);

  mongo.init(schemas);

  spark.store = mongo.store;

  spark.fetch = mongo.fetch;

  spark.query = mongo.query;

}).call(this);