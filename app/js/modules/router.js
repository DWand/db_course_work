(function() {

var mod = angular.module('dbm-router', [
  'ng', 
  'ngRoute',
  'db',
  'dbm-clients',
  'dbm-groups',
  'dbm-agencies',
  'dbm-hotels',
  'dbm-planes',
  'dbm-reports'
]);

mod.config(['$routeProvider', function($routeProvider) {
  $routeProvider
    .when('/clients', {
      templateUrl: 'view/clients/index.htm',
      controller: 'clientsCtrl'
    })
    .when('/groups', {
      templateUrl: 'view/groups/index.htm',
      controller: 'groupsCtrl'
    })
    .when('/agencies', {
      templateUrl: 'view/agencies/index.htm',
      controller: 'agenciesCtrl'
    })
    .when('/hotels', {
      templateUrl: 'view/hotels/index.htm',
      controller: 'hotelsCtrl'
    })
    .when('/planes', {
      templateUrl: 'view/planes/index.htm',
      controller: 'planesCtrl'
    })
    .when('/reports', {
      templateUrl: 'view/reports.htm',
      controller: 'reportsCtrl'
    });
}]);

mod.controller('routerCtrl', [
  '$scope', 'db',
  function($scope, db) {
  
    $scope.logout = function() {
      db.disconnect().then(function() {
        location.hash = '';
      });
    };
  
  }
]);

})();
