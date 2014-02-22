(function() {

var tds = require('tedious'),
    Connection = tds.Connection,
    Request = tds.Request,
    Types = tds.TYPES;

var mod = angular.module('db', ['ng']);

mod.provider('db', [function() {
  var connection = undefined,
      config = {
        userName: undefined,
        password: undefined,
        server: undefined,
        options: {
          instanceName: undefined,
          database: undefined,
          rowCollectionOnRequestCompletion: true
        }
      };
      
  this.database = function(dbName) {
    if (dbName) {
      config.options.database = dbName;
      return this;
    } else {
      return config.options.database;
    }
  };
  
  this.$get = ['$q', function($q) {
  
    var onConnectionClose = function() {
      connection = undefined;
    };
  
    var db = {},
        pendingRequest = false,
        requestsQueue = [];
    
    var onRequestComplete = function() {
      if (requestsQueue.length) {
        var req = requestsQueue.shift();
        connection.execSql(req);
      } else {
        pendingRequest = false;
      }
    };
    
    db.Param = function(name, type, value) {
      this.name = name;
      this.type = type;
      this.value = value;
    };
    db.Types = Types;
    
    db.database = function(dbName) {
      if (dbName) {
        config.options.database = dbName;
        return db;
      } else {
        return config.options.database;
      }
    };
    
    db.connect = function(host, instance, login, password) {
      var deferred = $q.defer();
      
      config.userName = login;
      config.password = password;
      config.server = host;
      config.options.instanceName = instance;
      
      connection = new Connection(config);
      connection.on('connect', function(err) {
        if (!err) {
          connection.on('end', onConnectionClose);
          deferred.resolve();
        } else {
          connection = undefined;
          deferred.reject(err);
        }
      });
      
      return deferred.promise;
    };
    
    db.disconnect = function() {
      var deferred = $q.defer();
      
      if (connection) {
        connection.on('end', function() {
          deferred.resolve();
        });
        connection.close();
      } else {
        deferred.resolve();
      }
      
      return deferred.promise;
    };
    
    db.isConnected = function() {
      return connection !== undefined;
    };
    
    db.query = function(sql, params) {
      var deferred = $q.defer();
      
      if (connection) {
        var req = new Request(sql, function(err, count, rows) {
          onRequestComplete();
          if (err) {
            deferred.reject(err);
          } else {
            deferred.resolve(rows);
          }
        });
        if (params && params.length) {
          for (var i = 0, len = params.length; i < len; i++) {
            req.addParameter(params[i].name, params[i].type, params[i].value);
          }
        }
        if (!pendingRequest) {
          pendingRequest = true;
          connection.execSql(req);
        } else {
          requestsQueue.push(req);
        }
      } else {
        deferred.reject('Connection to DB not established.');
      }
      
      return deferred.promise;
    };
    
    return db;
  
  }];
  
}])

})();