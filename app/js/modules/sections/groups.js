(function() {

var mod = angular.module('dbm-groups', [
  'ng',
  'ngRoute',
  'db',
  'ui.bootstrap', 'ui.bootstrap.modal',
  'toaster',
  'ngRoute'
]);

mod.config(['$routeProvider', function($routeProvider){
  $routeProvider
    .when('/group/:groupId', {
      templateUrl: 'view/groups/group.htm',
      controller: 'groupCtrl'
    });
}]);

mod.controller('groupsCtrl', [
  '$scope', 'db', '$modal', 'toaster',
  function($scope, db, $modal, toaster) {

    $scope.groups = [];
    function fetchGroups() {
      db.query('SELECT * FROM TouristGroup').then(
        function(rows) {
          $scope.groups = rows;
        }, function(error) {
          toaster.pop('error', 'Помилка отримання даних про групи', error);
        }
      );
    }
    
    $scope.showGroup = function(group) {
      location.hash = '/group/' + group.id.value;
    };
    
    $scope.addGroup = function() {
      var modal = $modal.open({
        templateUrl: 'addGroupTpl',
        controller: [
          '$scope',
          function($scope) {
            $scope.newGroup = {};
            
            $scope.ok = function() {
              modal.close($scope.newGroup);
            };
            
            $scope.cancel = function() {
              modal.dismiss();
            };
          }
        ]
      });
      modal.result.then(
        function(newGroup) {
          db.query( 'EXEC AddGroup @name', [
            new db.Param('name', db.Types.NVarChar, newGroup.name)
          ]).then(
            function(rows) {
              fetchGroups();
              toaster.pop('success', 'Операція завершилась успішно', 'Нову групу створено');
            }, function(error) {
              toaster.pop('error', 'Помилка створення нової групи', error);
            }
          );
        }
      );
    };

    fetchGroups();
    
  }
]);

mod.controller('groupCtrl', [
  '$scope', 'db', '$modal', 'toaster', '$routeParams', '$window',
  function($scope, db, $modal, toaster, $routeParams, $window) {
    var groupId = $routeParams.groupId;
    
    $scope.group = {};
    $scope.tourists = [];
    
    function fetchGroup() {
      db.query('SELECT * FROM TouristGroup WHERE id = @id', [
        new db.Param('id', db.Types.Int, groupId)
      ]).then(
        function(rows) {
          if (rows.length === 0) {
            toaster.pop('error', 'Помилка отримання даних про групу', 'Даних не знайдено');
          } else if (rows.length > 1) {
            toaster.pop('error', 'Помилка отримання даних про групу', 'Знайдено більше 1 запису');
          } else {
            $scope.group = rows[0];
          }
        }, function(error) {
          toaster.pop('error', 'Помилка отримання даних про групу', error);
        }
      );
    }
    
    function fetchTourists() {
      db.query('SELECT * FROM GetTouristsByGroup(@id)', [
        new db.Param('id', db.Types.Int, groupId)
      ]).then(
        function(rows) {
          $scope.tourists = rows;
        }, function(error) {
          toaster.pop('error', 'Помилка отримання даних про туристів', error);
        }
      );
    }
    
    $scope.showTour = function(tour) {
      location.hash = '/tour/' + tour.id.value;
    };    
    
    $scope.saveGroup = function() {
      db.query('EXEC UpdateGroup @id, @label', [
        new db.Param('id', db.Types.Int, groupId),
        new db.Param('label', db.Types.NVarChar, $scope.group.label.value),
      ]).then(
        function(rows) {
          toaster.pop('success', 'Зміни збережено');
        }, function(error) {
          toaster.pop('error', 'Помилка збереження змін', error);
        }
      );
    };
    
    $scope.delGroup = function() {
      var modal = $modal.open({
        templateUrl: 'delGroupTpl',
        controller: [
          '$scope', 'group',
          function($scope, group) {
            $scope.group = group;
            
            $scope.ok = function() {
              modal.close();
            };
            
            $scope.cancel = function() {
              modal.dismiss();
            };
          }
        ],
        resolve: {
          group: function() { return $scope.group; }
        }
      });
      modal.result.then(function() {
        db.query('EXEC DeleteGroup @id', [
          new db.Param('id', db.Types.Int, groupId)
        ]).then(
          function(rows) {
            toaster.pop('success', 'Групу успішно видалено');
            $window.history.back();
          }, function(error) {
            toaster.pop('error', 'Помилка видалення групи', error);
          }
        );
      });
    };
    
    fetchGroup();
    fetchTourists();
  }
]);

})();
