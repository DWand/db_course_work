(function() {

var mod = angular.module('dbm-agencies', [
  'ng',
  'ngRoute',
  'db',
  'ui.bootstrap', 'ui.bootstrap.modal', 'ui.bootstrap.datetimepicker',
  'toaster',
  'ngRoute'
]);

mod.config(['$routeProvider', function($routeProvider){
  $routeProvider
    .when('/agency/:agencyId', {
      templateUrl: 'view/agencies/agency.htm',
      controller: 'agencyCtrl'
    })
    .when('/excursion/:excursionId', {
      templateUrl: 'view/agencies/excursion.htm',
      controller: 'excursionCtrl'
    });
}]);

mod.controller('agenciesCtrl', [
  '$scope', 'db', '$modal', 'toaster',
  function($scope, db, $modal, toaster) {

    $scope.agencies = [];
    function fetchAgencies() {
      db.query('SELECT * FROM ExcursionAgency').then(
        function(rows) {
          $scope.agencies = rows;
        }, function(error) {
          toaster.pop('error', 'Помилка отримання даних про агенства', error);
        }
      );
    }
    
    $scope.addAgency = function() {
      var modal = $modal.open({
        templateUrl: 'addAgencyTpl',
        controller: [
          '$scope',
          function($scope) {
            $scope.newAgency = {};
            
            $scope.ok = function() {
              modal.close($scope.newAgency);
            };
            
            $scope.cancel = function() {
              modal.dismiss();
            };
          }
        ]
      });
      modal.result.then(
        function(newAgency) {
          db.query( 'EXEC AddAgency @name', [
            new db.Param('name', db.Types.NVarChar, newAgency.name)
          ]).then(
            function(rows) {
              fetchAgencies();
              toaster.pop('success', 'Операція завершилась успішно', 'Нове агенство створено');
            }, function(error) {
              toaster.pop('error', 'Помилка створення нового агенства', error);
            }
          );
        }
      );
    };
    
    $scope.showAgency = function(agency) {
      location.hash = '/agency/' + agency.id.value;
    };
    
    fetchAgencies();
  }
]);

mod.controller('agencyCtrl', [
  '$scope', 'db', '$modal', 'toaster', '$routeParams', '$window',
  function($scope, db, $modal, toaster, $routeParams, $window) {
    var agencyId = $routeParams.agencyId;
    
    $scope.agency = {};
    $scope.excursions = [];
    
    function fetchAgency() {
      db.query('SELECT * FROM ExcursionAgency WHERE id = @id', [
        new db.Param('id', db.Types.Int, agencyId)
      ]).then(
        function(rows) {
          if (rows.length === 0) {
            toaster.pop('error', 'Помилка отримання даних про агенство', 'Даних не знайдено');
          } else if (rows.length > 1) {
            toaster.pop('error', 'Помилка отримання даних про агенство', 'Знайдено більше 1 запису');
          } else {
            $scope.agency = rows[0];
          }
        }, function(error) {
          toaster.pop('error', 'Помилка отримання даних про агенства', error);
        }
      );
    }
    
    function fetchExcursions() {
      db.query('SELECT * FROM GetExcursionsByAgency(@id)', [
        new db.Param('id', db.Types.Int, agencyId)
      ]).then(
        function(rows) {
          $scope.excursions = rows;
        }, function(error) {
          toaster.pop('error', 'Помилка отримання даних про екскурсії', error);
        }
      );
    }
    
    $scope.saveAgency = function() {
      db.query('EXEC UpdateAgency @id, @name', [
        new db.Param('id', db.Types.Int, agencyId),
        new db.Param('name', db.Types.NVarChar, $scope.agency.name.value)
      ]).then(
        function(rows) {
          toaster.pop('success', 'Зміни збережено');
        }, function(error) {
          toaster.pop('error', 'Помилка збереження змін', error);
        }
      );
    };
    
    $scope.delAgency = function() {
      var modal = $modal.open({
        templateUrl: 'delAgencyTpl',
        controller: [
          '$scope', 'agency',
          function($scope, agency) {
            $scope.agency = agency;
            
            $scope.ok = function() {
              modal.close();
            };
            
            $scope.cancel = function() {
              modal.dismiss();
            };
          }
        ],
        resolve: {
          agency: function() { return $scope.agency; }
        }
      });
      modal.result.then(function() {
        db.query('EXEC DeleteAgency @id', [
          new db.Param('id', db.Types.Int, agencyId)
        ]).then(
          function(rows) {
            toaster.pop('success', 'Агенство успішно видалено');
            $window.history.back();
          }, function(error) {
            toaster.pop('error', 'Помилка видалення агенства', error);
          }
        );
      });
    };
    
    $scope.addExcursion = function() {
      var modal = $modal.open({
        templateUrl: 'addExcursionTpl',
        controller: [
          '$scope',
          function($scope) {
            $scope.newExc = {};
            
            $scope.ok = function() {
              modal.close($scope.newExc);
            };
            
            $scope.cancel = function() {
              modal.dismiss();
            };
          }
        ]
      });
      modal.result.then(
        function(newExc) {
          db.query('EXEC AddExcursion @name, @description, @agency_id', [
            new db.Param('name', db.Types.NVarChar, newExc.name),
            new db.Param('description', db.Types.NVarChar, newExc.description),
            new db.Param('agency_id', db.Types.Int, agencyId)
          ]).then(
            function(rows) {
              fetchExcursions();
              toaster.pop('success', 'Операція завершилась успішно', 'Нова екскурсія створена');
            }, function(error) {
              toaster.pop('error', 'Помилка створення нової екскурсії', error);
            }
          );
        }
      );
    };
    
    $scope.showExcursion = function(ecx) {
      location.hash = '/excursion/' + ecx.id.value;
    };
    
    fetchAgency();
    fetchExcursions();
  }
]);

mod.controller('excursionCtrl', [
  '$scope', 'db', '$modal', 'toaster', '$routeParams', '$window',
  function($scope, db, $modal, toaster, $routeParams, $window) {
    var excId = $routeParams.excursionId;
    
    $scope.exc = {};
    $scope.schedule = [];
    
    $scope.agencies = [];
    
    function fetchAgencies() {
      db.query('SELECT * FROM ExcursionAgency').then(
        function(rows) {
          $scope.agencies = rows;
        }, function(error) {
          toaster.pop('error', 'Помилка отримання даних про агенства', error);
        }
      );
    }
    
    function fetchExcursion() {
      db.query('SELECT * FROM ExcursionData WHERE id = @id', [
        new db.Param('id', db.Types.Int, excId)
      ]).then(
        function(rows) {
          if (rows.length === 0) {
            toaster.pop('error', 'Помилка отримання даних про екскурсію', 'Даних не знайдено');
          } else if (rows.length > 1) {
            toaster.pop('error', 'Помилка отримання даних про екскурсію', 'Знайдено більше 1 запису');
          } else {
            $scope.exc = rows[0];
          }
        }, function(error) {
          toaster.pop('error', 'Помилка отримання даних про екскурсію', error);
        }
      );
    }
    
    function fetchSchedule() {
      db.query('SELECT * FROM GetScheduleForExcursion(@id)', [
        new db.Param('id', db.Types.Int, excId)
      ]).then(
        function(rows) {
            $scope.schedule = rows;
        }, function(error) {
          toaster.pop('error', 'Помилка отримання даних про розклад екскурсії', error);
        }
      );
    }
    
    $scope.saveExc = function() {
      db.query('EXEC UpdateExcursion @id, @agency_id, @name, @description', [
        new db.Param('id', db.Types.Int, excId),
        new db.Param('agency_id', db.Types.Int, $scope.exc.agency_id.value),
        new db.Param('name', db.Types.NVarChar, $scope.exc.name.value),
        new db.Param('description', db.Types.NVarChar, $scope.exc.description.value)
      ]).then(
        function(rows) {
          toaster.pop('success', 'Зміни збережено');
        }, function(error) {
          toaster.pop('error', 'Помилка збереження змін', error);
        }
      );
    };
    
    $scope.delExc = function() {
      var modal = $modal.open({
        templateUrl: 'delExcTpl',
        controller: [
          '$scope', 'exc',
          function($scope, exc) {
            $scope.exc = exc;
            
            $scope.ok = function() {
              modal.close();
            };
            
            $scope.cancel = function() {
              modal.dismiss();
            };
          }
        ],
        resolve: {
          exc: function() { return $scope.exc; }
        }
      });
      modal.result.then(function() {
        db.query('EXEC DeleteExcursion @id', [
          new db.Param('id', db.Types.Int, excId)
        ]).then(
          function(rows) {
            toaster.pop('success', 'Екскурсію успішно видалено');
            $window.history.back();
          }, function(error) {
            toaster.pop('error', 'Помилка видалення екскурсії', error);
          }
        );
      });
    };
    
    $scope.addSchedule = function() {
      var modal = $modal.open({
        templateUrl: 'addExcursionScheduleTpl',
        controller: [
          '$scope',
          function($scope) {
            $scope.newSch = {};
            
            $scope.ok = function() {
              modal.close($scope.newSch);
            };
            
            $scope.cancel = function() {
              modal.dismiss();
            };
          }
        ]
      });
      modal.result.then(
        function(newSch) {
          db.query('EXEC AddExcursionSchedule @id, @date, @cost', [
            new db.Param('id', db.Types.Int, excId),
            new db.Param('date', db.Types.NVarChar, newSch.date.toISO8601String()),
            new db.Param('cost', db.Types.Real, parseFloat(newSch.cost))
          ]).then(
            function(rows) {
              fetchSchedule();
              toaster.pop('success', 'Операція завершилась успішно', 'Новий запис в розкладі екскурсій створений');
            }, function(error) {
              toaster.pop('error', 'Помилка створення нового запису в розкладі екскурсій', error);
            }
          );
        }
      );
    };
    
    fetchExcursion();
    fetchSchedule();
    fetchAgencies();
  }
]);

})();
