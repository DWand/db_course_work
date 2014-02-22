(function() {

var app = angular.module('dbm', [
  'ng', 
  'ngRoute',
  'db',
  'dbm-connection',
  'dbm-router'
]);

app.config(['$routeProvider', function($routeProvider) {
  location.hash = '';
  $routeProvider
    .when('/connection', {
      templateUrl: 'view/connection.htm',
      controller: 'connectionCtrl'
    })
    .when('/router', {
      templateUrl: 'view/router.htm',
      controller: 'routerCtrl'
    })
    .otherwise({redirectTo: '/connection'});
}]);

app.config(['dbProvider', function(dbProvider) {
  dbProvider.database('sp110_15_db_2013');
}]);

app.run(function(){
  Date.prototype.toISO8601String = function() {
    var d = this.getDate();
    var m = this.getMonth() + 1;
    var y = this.getFullYear();
    var H = this.getHours();
    var M = this.getMinutes();
    var S = this.getSeconds();
    
    d = (d < 10) ? '0' + d : d;
    m = (m < 10) ? '0' + m : m;
    H = (H < 10) ? '0' + H : H;
    M = (M < 10) ? '0' + M : M;
    S = (S < 10) ? '0' + S : S;
    
    return y + '-' + m + '-' + d + 'T' + H + ':' + M + ':' + S + '.000';
  };
});

app.controller('appCtrl', [
  '$scope', '$window', 'db',
  function($scope, $window, db) {
    
    $scope.logout = function() {
      db.disconnect().then(function() {
        location.hash = '';
      });
    };
    
    $scope.goBack = function() {
      $window.history.back();
    };
    
    $scope.print = function() {
      $window.print();
    };
  }
]);

})();
