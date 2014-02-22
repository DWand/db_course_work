(function() {

var mod = angular.module('dbm-planes', [
  'ng',
  'ngRoute',
  'db',
  'ui.bootstrap', 'ui.bootstrap.modal',
  'toaster',
  'ngRoute'
]);

mod.config(['$routeProvider', function($routeProvider){
  $routeProvider
    .when('/plane/:planeId', {
      templateUrl: 'view/planes/plane.htm',
      controller: 'planeCtrl'
    })
    .when('/flight/:flightId', {
      templateUrl: 'view/planes/flight.htm',
      controller: 'flightCtrl'
    });
}]);

mod.controller('planesCtrl', [
  '$scope', 'db', '$modal', 'toaster',
  function($scope, db, $modal, toaster) {
    
    $scope.types = [];
    $scope.planes = [];
    
    function fetchTypes() {
      db.query('SELECT * FROM PlaneType').then(
        function(rows) {
          $scope.types = rows;
        }, function(error) {
          toaster.pop('error', 'Помилка отримання даних про типи літаків', error);
        }
      );
    }
    
    function fetchPlanes() {
      db.query('SELECT * FROM PlaneData').then(
        function(rows) {
          $scope.planes = rows;
        }, function(error) {
          toaster.pop('error', 'Помилка отримання даних про літаки', error);
        }
      );
    }
    
    function fetchPlanesByType(type) {
      db.query('SELECT * FROM GetPlanesOfType(@type_id)', [
        new db.Param('type_id', db.Types.Int, type.id.value)
      ]).then(
        function(rows) {
          $scope.planes = rows;
        }, function(error) {
          toaster.pop('error', 'Помилка отримання даних про літаки', error);
        }
      );
    }
    
    $scope.addPlane = function() {
        var modal = $modal.open({
        templateUrl: 'addPlaneTpl',
        controller: [
          '$scope', 'types',
          function($scope, types) {
            $scope.types = types;
            $scope.newPlane = {};
            
            $scope.ok = function() {
              modal.close($scope.newPlane);
            };
            
            $scope.cancel = function() {
              modal.dismiss();
            };
          }
        ],
        resolve: {
          types : function() { return $scope.types; }
        }
      });
      modal.result.then(
        function(newPlane) {
          db.query('EXEC AddPlane @name, @type_id', [
            new db.Param('name', db.Types.NVarChar, newPlane.name),
            new db.Param('type_id', db.Types.Int, newPlane.type.id.value)
          ]).then(
            function(rows) {
              fetchPlanes();
              toaster.pop('success', 'Операція завершилась успішно', 'Новий літак створено');
            }, function(error) {
              toaster.pop('error', 'Помилка створення нового літака', error);
            }
          );
        }
      );
    };
    
    $scope.showAllPlanes = function() {
      fetchPlanes();
    };
    
    $scope.showType = function(type) {
      fetchPlanesByType(type);
    };
    
    $scope.showPlane = function(plane) {
      location.hash = '/plane/' + plane.id.value;
    };
    
    fetchTypes();
    fetchPlanes();
  }
]);

mod.controller('planeCtrl', [
  '$scope', 'db', '$modal', 'toaster', '$routeParams', '$window',
  function($scope, db, $modal, toaster, $routeParams, $window) {
    var planeId = $routeParams.planeId;
    
    $scope.plane = {};
    $scope.types = [];
    
    function fetchPlane() {
      db.query('SELECT * FROM PlaneData WHERE id = @id', [
        new db.Param('id', db.Types.Int, planeId)
      ]).then(
        function(rows) {
          if (rows.length === 0) {
            toaster.pop('error', 'Помилка отримання даних про літак', 'Даних не знайдено');
          } else if (rows.length > 1) {
            toaster.pop('error', 'Помилка отримання даних про літак', 'Знайдено більше 1 запису');
          } else {
            $scope.plane = rows[0];
          }
        }, function(error) {
          toaster.pop('error', 'Помилка отримання даних про літаки', error);
        }
      );
    }
    
    function fetchSchedule() {
      db.query('SELECT * FROM GetScheduleForPlane(@id)', [
        new db.Param('id', db.Types.Int, planeId)
      ]).then(
        function(rows) {
            $scope.flights = rows;
        }, function(error) {
          toaster.pop('error', 'Помилка отримання даних про розклад польотів', error);
        }
      );
    }
    
    function fetchTypes() {
      db.query('SELECT * FROM PlaneType').then(
        function(rows) {
          $scope.types = rows;
        }, function(error) {
          toaster.pop('error', 'Помилка отримання даних про типи літаків', error);
        }
      );
    }
    
    $scope.addFlight = function() {
        var modal = $modal.open({
        templateUrl: 'addFlightTpl',
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
        ],
        resolve: {
          types : function() { return $scope.types; }
        }
      });
      modal.result.then(
        function(newSch) {
          db.query( 'EXEC AddPlaneSchedule @plane_id, @takeoff_date, @landing_date, @loading_cost, ' +
                    '@unloading_cost, @takeoff_cost, @landing_cost, @dispetcher_cost', [
            new db.Param('plane_id', db.Types.Int, planeId),
            new db.Param('takeoff_date', db.Types.NVarChar, newSch.takeoff.toISO8601String()),
            new db.Param('landing_date', db.Types.NVarChar, newSch.landing.toISO8601String()),
            new db.Param('loading_cost', db.Types.Real, parseFloat(newSch.cost_loading)),
            new db.Param('unloading_cost', db.Types.Real, parseFloat(newSch.cost_unloading)),
            new db.Param('takeoff_cost', db.Types.Real, parseFloat(newSch.cost_takeoff)),
            new db.Param('landing_cost', db.Types.Real, parseFloat(newSch.cost_landing)),
            new db.Param('dispetcher_cost', db.Types.Real, parseFloat(newSch.cost_dispetcher))
          ]).then(
            function(rows) {
              fetchSchedule();
              toaster.pop('success', 'Операція завершилась успішно', 'Новий рейс створено');
            }, function(error) {
              toaster.pop('error', 'Помилка створення нового рейса літака', error);
            }
          );
        }
      );
    };
    
    $scope.savePlane = function() {
      db.query('EXEC UpdatePlane @id, @name, @type_id', [
        new db.Param('id', db.Types.Int, planeId),
        new db.Param('name', db.Types.NVarChar, $scope.plane.name.value),
        new db.Param('type_id', db.Types.Int, $scope.plane.type_id.value)
      ]).then(
        function(rows) {
          toaster.pop('success', 'Зміни збережено');
        }, function(error) {
          toaster.pop('error', 'Помилка збереження змін', error);
        }
      );
    };
    
    $scope.delPlane = function() {
      var modal = $modal.open({
        templateUrl: 'delPlaneTpl',
        controller: [
          '$scope', 'plane',
          function($scope, plane) {
            $scope.plane = plane;
            
            $scope.ok = function() {
              modal.close();
            };
            
            $scope.cancel = function() {
              modal.dismiss();
            };
          }
        ],
        resolve: {
          plane: function() { return $scope.plane; }
        }
      });
      modal.result.then(function() {
        db.query('DELETE FROM Plane WHERE id = @id', [
          new db.Param('id', db.Types.Int, planeId)
        ]).then(
          function(rows) {
            toaster.pop('success', 'Літак успішно видалено');
            $window.history.back();
          }, function(error) {
            toaster.pop('error', 'Помилка видалення літака', error);
          }
        );
      });
    };
    
    $scope.showFight = function(flight) {
      location.hash = '/flight/' + flight.id.value;
    };
    
    fetchPlane();
    fetchSchedule();
    fetchTypes();
  }
]);

mod.controller('flightCtrl', [
  '$scope', 'db', '$modal', 'toaster', '$routeParams', '$window',
  function($scope, db, $modal, toaster, $routeParams, $window) {
    var flightId = $routeParams.flightId;
    
    $scope.flight = {};
    $scope.flightStat = {};
    $scope.groups = [];
    $scope.hotels = [];
    $scope.baggages = [];
    
    $scope.planes = [];
    
    function fetchFlight() {
      db.query('SELECT * FROM FlightScheduleData WHERE id = @id', [
        new db.Param('id', db.Types.Int, flightId)
      ]).then(
        function(rows) {
          if (rows.length === 0) {
            toaster.pop('error', 'Помилка отримання даних про рейс літака', 'Даних не знайдено');
          } else if (rows.length > 1) {
            toaster.pop('error', 'Помилка отримання даних про рейс літака', 'Знайдено більше 1 запису');
          } else {
            $scope.flight = rows[0];
            
            fetchFlightStat();
            fetchGroups();
            fetchHotels();
            fetchBaggage();
          }
        }, function(error) {
          toaster.pop('error', 'Помилка отримання даних про рейс літака', error);
        }
      );
    }
    
    function fetchFlightStat() {
      db.query('EXEC GetFlightStatistic @plane_id, @takeoff', [
        new db.Param('plane_id', db.Types.Int, $scope.flight.plane_id.value),
        new db.Param('takeoff', db.Types.NVarChar, new Date($scope.flight.takeoff_date.value).toISO8601String())
      ]).then(
        function(rows) {
          if (rows.length === 0) {
            toaster.pop('error', 'Помилка отримання статистики про рейс літака', 'Даних не знайдено');
          } else if (rows.length > 1) {
            toaster.pop('error', 'Помилка отримання статистики про рейс літака', 'Знайдено більше 1 запису');
          } else {
            $scope.flightStat = rows[0];
          }
        }, function(error) {
          toaster.pop('error', 'Помилка отримання статистики про рейс літака', error);
        }
      );
    }
    
    function fetchGroups() {
      db.query( 'SELECT gr.* ' +
                'FROM GetGroupsByFlight(@id) AS groupList ' +
                'INNER JOIN TouristGroup AS gr on gr.id = groupList.group_id', [
        new db.Param('id', db.Types.Int, $scope.flight.id.value)
      ]).then(
        function(rows) {
          $scope.groups = rows;
        }, function(error) {
          toaster.pop('error', 'Помилка отримання списку груп пасажирів', error);
        }
      );
    }
    
    function fetchHotels() {
      db.query( 'SELECT hd.* ' +
                'FROM GetHotelsByFlight(@id) AS hotelList ' +
                'INNER JOIN HotelData AS hd on hd.id = hotelList.hotel_id', [
        new db.Param('id', db.Types.Int, $scope.flight.id.value)
      ]).then(
        function(rows) {
          $scope.hotels = rows;
        }, function(error) {
          toaster.pop('error', 'Помилка отримання списку розселення пасажирів', error);
        }
      );
    }
    
    function fetchBaggage() {
      db.query( 'SELECT bagList.*, bt.name AS type ' +
                'FROM GetBaggageByFlight(@id) AS bagList ' +
                'INNER JOIN BaggageType AS bt on bt.id = bagList.type_id', [
        new db.Param('id', db.Types.Int, $scope.flight.id.value)
      ]).then(
        function(rows) {
          $scope.baggages = rows;
        }, function(error) {
          toaster.pop('error', 'Помилка отримання списку багажу пасажирів', error);
        }
      );
    }
    
    function fetchPlanes() {
      db.query('SELECT * FROM PlaneData').then(
        function(rows) {
          $scope.planes = rows;
        }, function(error) {
          toaster.pop('error', 'Помилка отримання даних про літаки', error);
        }
      );
    }
    $scope.saveFlight = function() {
      db.query('EXEC UpdateFlightSchedule @id, @plane_id, @takeoff_date, @landing_date, @loading_cost, @unloading_cost, @takeoff_cost, @landing_cost, @dispetcher_cost', [
        new db.Param('id', db.Types.Int, flightId),
        new db.Param('plane_id', db.Types.Int, $scope.flight.plane_id.value),
        new db.Param('takeoff_date', db.Types.NVarChar, new Date($scope.flight.takeoff_date.value).toISO8601String()),
        new db.Param('landing_date', db.Types.NVarChar, new Date($scope.flight.landing_date.value).toISO8601String()),
        new db.Param('loading_cost', db.Types.Real, parseFloat($scope.flight.loading_cost.value)),
        new db.Param('unloading_cost', db.Types.Real, parseFloat($scope.flight.unloading_cost.value)),
        new db.Param('takeoff_cost', db.Types.Real, parseFloat($scope.flight.takeoff_cost.value)),
        new db.Param('landing_cost', db.Types.Real, parseFloat($scope.flight.landing_cost.value)),
        new db.Param('dispetcher_cost', db.Types.Real, parseFloat($scope.flight.dispetcher_cost.value))
      ]).then(
        function(rows) {
          toaster.pop('success', 'Зміни збережено');
        }, function(error) {
          toaster.pop('error', 'Помилка збереження змін', error);
        }
      );
    };
    
    $scope.delFlight = function() {
      var modal = $modal.open({
        templateUrl: 'delFlightTpl',
        controller: [
          '$scope', 'flight',
          function($scope, flight) {
            $scope.flight = flight;
            
            $scope.ok = function() {
              modal.close();
            };
            
            $scope.cancel = function() {
              modal.dismiss();
            };
          }
        ],
        resolve: {
          flight: function() { return $scope.flight; }
        }
      });
      modal.result.then(function() {
        db.query('EXEC DeletePlaneSchedule @id', [
          new db.Param('id', db.Types.Int, flightId)
        ]).then(
          function(rows) {
            toaster.pop('success', 'Рейс успішно видалено');
            $window.history.back();
          }, function(error) {
            toaster.pop('error', 'Помилка видалення рейса', error);
          }
        );
      });
    };
    
    $scope.showGroup = function(group) {
      location.hash = '/group/' + group.id.value;
    };
    
    $scope.showHotel = function(hotel) {
      location.hash = '/hotel/' + hotel.id.value;
    };
    
    fetchFlight();
    fetchPlanes();
  }
]);

})();
