(function() {

var mod = angular.module('dbm-connection', ['ng', 'db', 'toaster']);

mod.controller('connectionCtrl', [
  '$scope', '$location', 'db', 'toaster',
  function($scope, $location, db, toaster) {
    
    $scope.host = 'SERVER1\\SQLEXPRESS';
    $scope.login = 'admin';
    $scope.password = 'password2014!';
    
    $scope.connect = function() {
      var host = $scope.host.split('\\');
      db.connect(
        host[0], host[1],
        $scope.login, $scope.password
      ).then(
        function() {
          $location.path('router');
        }, function(err) {
          toaster.pop('error', 'Сталася помилка', err);
        }
      );
    };
  
  }
]);

})();
