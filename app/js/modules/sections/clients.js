(function() {

var mod = angular.module('dbm-clients', [
  'ng',
  'ngRoute',
  'db',
  'ui.bootstrap', 'ui.bootstrap.modal', 'ui.bootstrap.buttons', 'ui.bootstrap.datepicker',
  'toaster',
  'ngRoute'
]);

mod.config(['$routeProvider', function($routeProvider){
  $routeProvider
    .when('/client/:clientId', {
      templateUrl: 'view/clients/client.htm',
      controller: 'clientCtrl'
    })
    .when('/tour/:tourId', {
      templateUrl: 'view/clients/tour.htm',
      controller: 'tourCtrl'
    })
    .when('/tour/residence/:residenceId', {
      templateUrl: 'view/clients/residence.htm',
      controller: 'residenceCtrl'
    })
    .when('/tour/flight/:flightId', {
      templateUrl: 'view/clients/flight.htm',
      controller: 'touristFlightCtrl'
    });
}]);

mod.controller('clientsCtrl', [
  '$scope', 'db', '$modal', 'toaster',
  function($scope, db, $modal, toaster) {

    $scope.clients = [];
    
    function fetchClients() {
      db.query('select * from ClientData').then(
        function(rows) {
          $scope.clients = rows;
        }, function(error) {
          toaster.pop('error', 'Помилка отримання даних про клієнтів', error);
        }
      );
    }
    
    $scope.showClient = function(client) {
      location.hash = '/client/' + client.id.value;
    };
    
    $scope.addClient = function() {
      var modal = $modal.open({
        templateUrl: 'addClientTpl',
        controller: [
          '$scope',
          function($scope) {
            $scope.newClient = {};
            
            $scope.ok = function() {
              modal.close($scope.newClient);
            };
            
            $scope.cancel = function() {
              modal.dismiss();
            };
          }
        ]
      });
      modal.result.then(
        function(newClient) {
          db.query( 'EXEC AddClient @name, @surname, @patronymic, @passport, @sex_id, @birthday', [
            new db.Param('name', db.Types.NVarChar, newClient.name),
            new db.Param('surname', db.Types.NVarChar, newClient.surname),
            new db.Param('patronymic', db.Types.NVarChar, newClient.patronymic),
            new db.Param('passport', db.Types.NVarChar, newClient.passport),
            new db.Param('sex_id', db.Types.TinyInt, parseInt(newClient.sex)),
            new db.Param('birthday', db.Types.NVarChar, newClient.birthday)
          ]).then(
            function(rows) {
              fetchClients();
              toaster.pop('success', 'Операція завершилась успішно', 'Нового клієнта створено');
            }, function(error) {
              toaster.pop('error', 'Помилка створення нового клієнта', error);
            }
          );
        }
      );
    };
    
    fetchClients();
  }
]);

mod.controller('clientCtrl', [
  '$scope', 'db', '$modal', 'toaster', '$routeParams', '$window', '$q',
  function($scope, db, $modal, toaster, $routeParams, $window, $q) {
    var clientId = $routeParams.clientId;
    
    $scope.client = {};
    $scope.countryVisits = 0;
    $scope.tours = [];
    
    function fetchClient() {
      db.query('SELECT * FROM ClientData WHERE id = @id', [
        new db.Param('id', db.Types.Int, clientId)
      ]).then(
        function(rows) {
          if (rows.length === 0) {
            toaster.pop('error', 'Помилка отримання даних про клієнта', 'Даних не знайдено');
          } else if (rows.length > 1) {
            toaster.pop('error', 'Помилка отримання даних про клієнта', 'Знайдено більше 1 запису');
          } else {
            $scope.client = rows[0];
          }
        }, function(error) {
          toaster.pop('error', 'Помилка отримання даних про клієнта', error);
        }
      );
    }
    
    function fetchVisits() {
      db.query('SELECT dbo.GetCountryVisitsAmountForHuman(@id) AS visits', [
        new db.Param('id', db.Types.Int, clientId)
      ]).then(
        function(rows) {
          if (rows.length !== 1) {
            toaster.pop('error', 'Помилка отримання даних про кількість візитів до країни', 'Не вірна кількість результів');
          } else {
            $scope.countryVisits = rows[0].visits.value;
          }
        }, function(error) {
          toaster.pop('error', 'Помилка отримання даних про кількість візитів до країни', error);
        }
      );
    }
    
    function fetchTours() {
      db.query('SELECT * FROM TouristInfo WHERE human_id = @id', [
        new db.Param('id', db.Types.Int, clientId)
      ]).then(
        function(rows) {
          $scope.tours = rows;
        }, function(error) {
          toaster.pop('error', 'Помилка отримання даних про тури', error);
        }
      );
    }
    
    $scope.saveClient = function() {
      db.query('EXEC UpdateClient @id, @name, @surname, @patronymic, @passport, @sex_id, @birthday', [
        new db.Param('id', db.Types.Int, clientId),
        new db.Param('name', db.Types.NVarChar, $scope.client.name.value),
        new db.Param('surname', db.Types.NVarChar, $scope.client.surname.value),
        new db.Param('patronymic', db.Types.NVarChar, $scope.client.patronymic.value),
        new db.Param('passport', db.Types.NVarChar, $scope.client.passport.value),
        new db.Param('sex_id', db.Types.TinyInt, $scope.client.sex_id.value),
        new db.Param('birthday', db.Types.NVarChar, new Date($scope.client.birthday.value).toISO8601String())
      ]).then(
        function(rows) {
          toaster.pop('success', 'Зміни збережено');
        }, function(error) {
          toaster.pop('error', 'Помилка збереження змін', error);
        }
      );
    };
    
    $scope.delClient = function() {
      var modal = $modal.open({
        templateUrl: 'delClientTpl',
        controller: [
          '$scope', 'client',
          function($scope, client) {
            $scope.client = client;
            
            $scope.ok = function() {
              modal.close();
            };
            
            $scope.cancel = function() {
              modal.dismiss();
            };
          }
        ],
        resolve: {
          client: function() { return $scope.client; }
        }
      });
      modal.result.then(function() {
        db.query('DELETE FROM Human WHERE id = @id', [
          new db.Param('id', db.Types.Int, clientId)
        ]).then(
          function(rows) {
            toaster.pop('success', 'Клієнта успішно видалено');
            $window.history.back();
          }, function(error) {
            toaster.pop('error', 'Помилка видалення клієнта', error);
          }
        );
      });
    };
    
    $scope.addTour = function() {
      var modal = $modal.open({
        templateUrl: 'addTourForClientTpl',
        controller: [
          '$scope', 'groups', 'categories',
          function($scope, groups, categories) {
            $scope.groups = groups;
            $scope.categories = categories;
            $scope.newTour = {};
            
            $scope.ok = function() {
              modal.close($scope.newTour);
            };
            
            $scope.cancel = function() {
              modal.dismiss();
            };
          }
        ],
        resolve: {
          groups : function() { 
            var deferred = $q.defer();
            
            db.query('SELECT * FROM TouristGroup').then(
              function(rows) { 
                deferred.resolve(rows);
              }, function(error) {
                toaster.pop('error', 'Помилка отримання даних про групи', error);
                deferred.reject(error);
              }
            );
             
            return deferred.promise;
          },
          categories : function() { 
            var deferred = $q.defer();
            
            db.query('SELECT * FROM TouristCategory').then(
              function(rows) { 
                deferred.resolve(rows);
              }, function(error) {
                toaster.pop('error', 'Помилка отримання даних про категорії', error);
                deferred.reject(error);
              }
            );
             
            return deferred.promise;
          }
        }
      });
      modal.result.then(
        function(newTour) {
          db.query('EXEC AddTourForClient @client_id, @group_id, @category_id, @cost', [
            new db.Param('client_id', db.Types.Int, clientId),
            new db.Param('group_id', db.Types.Int, newTour.group.id.value),
            new db.Param('category_id', db.Types.Int, newTour.category.id.value),
            new db.Param('cost', db.Types.Int, parseInt(newTour.cost)),
          ]).then(
            function(rows) {
              fetchTours();
              toaster.pop('success', 'Операція завершилась успішно', 'Новий тур створено');
            }, function(error) {
              toaster.pop('error', 'Помилка створення нового туру', error);
            }
          );
        }
      );
    };
    
    $scope.showTour = function(tour) {
      location.hash = '/tour/' + tour.id.value;
    };
    
    fetchClient();
    fetchVisits();
    fetchTours();
  }
]);


mod.controller('tourCtrl', [
  '$scope', 'db', '$modal', 'toaster', '$routeParams', '$window', '$q',
  function($scope, db, $modal, toaster, $routeParams, $window, $q) {
    var tourId = $routeParams.tourId;
    
    $scope.tourist = {};
    $scope.hotels = [];
    $scope.flights = [];

    $scope.groups = [];
    $scope.categories = [];
    
    $scope.touristList = [];
    $scope.parents = [];
    $scope.children = [];
    
    function fetchGroups() { 
      db.query('SELECT * FROM TouristGroup').then(
        function(rows) { 
          $scope.groups = rows;
        }, function(error) {
          toaster.pop('error', 'Помилка отримання даних про групи', error);
        }
      );
    }
    
    function fetchCategories() { 
      db.query('SELECT * FROM TouristCategory').then(
        function(rows) { 
          $scope.categories = rows;
        }, function(error) {
          toaster.pop('error', 'Помилка отримання даних про категорії', error);
        }
      );
    }
    
    function fetchPossibleFamilyMembers() {
      db.query('SELECT * FROM TouristInfo').then(
        function(rows) { 
          $scope.touristList = rows;
        }, function(error) {
          toaster.pop('error', 'Помилка отримання даних про туристів', error);
        }
      );
    }
    
    function fetchTourist() {
      db.query('SELECT * FROM TouristInfo WHERE id = @id', [
        new db.Param('id', db.Types.Int, tourId)
      ]).then(
        function(rows) {
          if (rows.length === 0) {
            toaster.pop('error', 'Помилка отримання даних про тур', 'Даних не знайдено');
          } else if (rows.length > 1) {
            toaster.pop('error', 'Помилка отримання даних про тур', 'Знайдено більше 1 запису');
          } else {
            $scope.tourist = rows[0];
            
            fetchHotels();
            fetchExcursions();
            fetchFlights();
          }
        }, function(error) {
          toaster.pop('error', 'Помилка отримання даних про тур', error);
        }
      );
    }
    
    function fetchHotels() {
      db.query('SELECT * FROM GetHotelsResidenceListForHuman(@human_id) WHERE tourist_id = @tourist_id', [
        new db.Param('human_id', db.Types.Int, $scope.tourist.human_id.value),
        new db.Param('tourist_id', db.Types.Int, tourId)
      ]).then(
        function(rows){
          console.log(rows);
          $scope.hotels = rows;
        }, function(error){
          toaster.pop('error', 'Помилка отримання списку готелів', error);
        }
      );
    }
    
    function fetchExcursions() {
      db.query('SELECT * FROM GetExcursionListForHuman(@human_id) WHERE tourist_id = @tourist_id', [
        new db.Param('human_id', db.Types.Int, $scope.tourist.human_id.value),
        new db.Param('tourist_id', db.Types.Int, tourId)
      ]).then(
        function(rows){
          $scope.excursions = rows;
        }, function(error){
          toaster.pop('error', 'Помилка отримання списку екскурсій', error);
        }
      );
    }
    
    function fetchFlights() {
      db.query( 'SELECT * FROM GetFlightsByTourist(@tourist_id) ' +
                'ORDER BY takeoff_date ASC', [
        new db.Param('tourist_id', db.Types.Int, tourId)
      ]).then(
        function(rows){
          $scope.flights = rows;
        }, function(error){
          toaster.pop('error', 'Помилка отримання списку перельотів', error);
        }
      );
    }
    
    function fetchParents() {
      db.query( 'SELECT * FROM GetParents(@tourist_id)', [
        new db.Param('tourist_id', db.Types.Int, tourId)
      ]).then(
        function(rows){
          $scope.parents = rows;
        }, function(error){
          toaster.pop('error', 'Помилка отримання списку батьків', error);
        }
      );
    }
    
    function fetchChildren() {
      db.query( 'SELECT * FROM GetChildren(@tourist_id)', [
        new db.Param('tourist_id', db.Types.Int, tourId)
      ]).then(
        function(rows){
          $scope.children = rows;
        }, function(error){
          toaster.pop('error', 'Помилка отримання списку дітей', error);
        }
      );
    }
    
    $scope.saveTour = function() {
      db.query('EXEC UpdateTourist @id, @group_id, @category_id, @paid', [
        new db.Param('id', db.Types.Int, tourId),
        new db.Param('group_id', db.Types.Int, $scope.tourist.group_id.value),
        new db.Param('category_id', db.Types.Int, $scope.tourist.category_id.value),
        new db.Param('paid', db.Types.Real, parseFloat($scope.tourist.paid.value))
      ]).then(
        function(rows) {
          toaster.pop('success', 'Зміни збережено');
        }, function(error) {
          toaster.pop('error', 'Помилка збереження змін', error);
        }
      );
    };
    
    $scope.delTour = function() {
      var modal = $modal.open({
        templateUrl: 'delTourTpl',
        controller: [
          '$scope',
          function($scope) {
            $scope.ok = function() {
              modal.close();
            };
            
            $scope.cancel = function() {
              modal.dismiss();
            };
          }
        ]
      });
      modal.result.then(function() {
        db.query('EXEC DeleteTour @tour_id', [
          new db.Param('tour_id', db.Types.Int, tourId)
        ]).then(
          function(rows) {
            toaster.pop('success', 'Тур успішно видалено', rows);
            $window.history.back();
          }, function(error) {
            toaster.pop('error', 'Помилка видалення тура', error);
          }
        );
      });
    };
    
    $scope.showTourist = function(tourist) {
      location.hash = '/tour/' + tourist.id.value;
    };
    
    $scope.addParent = function() {
      var modal = $modal.open({
        templateUrl: 'addFamilyMemberTpl',
        controller: [
          '$scope', 'touristList',
          function($scope, touristList) {
            $scope.touristList = touristList;
            $scope.member = {};
            
            $scope.ok = function() {
              modal.close($scope.member);
            };
            
            $scope.cancel = function() {
              modal.dismiss();
            };
          }
        ],
        resolve: {
          touristList : function() { return $scope.touristList; }
        }
      });
      modal.result.then(
        function(member) {
          db.query('EXEC AddParent @tourist_id, @parent_id', [
            new db.Param('tourist_id', db.Types.Int, tourId),
            new db.Param('parent_id', db.Types.Int, member.human.id.value),
          ]).then(
            function(rows) {
              fetchParents();
              toaster.pop('success', 'Операція завершилась успішно', 'Батьків додано');
            }, function(error) {
              toaster.pop('error', 'Помилка додавання батьків', error);
            }
          );
        }
      );
    };
    
    $scope.removeParent = function(parent) {
      db.query('EXEC RemoveParent @tourist_id, @parent_id', [
        new db.Param('tourist_id', db.Types.Int, tourId),
        new db.Param('parent_id', db.Types.Int, parent.id.value),
      ]).then(
        function(rows) {
          fetchParents();
          toaster.pop('success', 'Операція завершилась успішно', 'Батьків видалено');
        }, function(error) {
          toaster.pop('error', 'Помилка видалення батьків', error);
        }
      );
    };
    
    $scope.addChild = function() {
      var modal = $modal.open({
        templateUrl: 'addFamilyMemberTpl',
        controller: [
          '$scope', 'touristList',
          function($scope, touristList) {
            $scope.touristList = touristList;
            $scope.member = {};
            
            $scope.ok = function() {
              modal.close($scope.member);
            };
            
            $scope.cancel = function() {
              modal.dismiss();
            };
          }
        ],
        resolve: {
          touristList : function() { return $scope.touristList; }
        }
      });
      modal.result.then(
        function(member) {
          db.query('EXEC AddChild @tourist_id, @child_id', [
            new db.Param('tourist_id', db.Types.Int, tourId),
            new db.Param('child_id', db.Types.Int, member.human.id.value),
          ]).then(
            function(rows) {
              fetchChildren();
              toaster.pop('success', 'Операція завершилась успішно', 'Дитину додано');
            }, function(error) {
              toaster.pop('error', 'Помилка додавання дитини', error);
            }
          );
        }
      );
    };
    
    $scope.removeChild = function(child) {
      db.query('EXEC RemoveChild @tourist_id, @child_id', [
        new db.Param('tourist_id', db.Types.Int, tourId),
        new db.Param('child_id', db.Types.Int, child.id.value),
      ]).then(
        function(rows) {
          fetchChildren();
          toaster.pop('success', 'Операція завершилась успішно', 'Дитину видалено');
        }, function(error) {
          toaster.pop('error', 'Помилка видалення дитини', error);
        }
      );
    };
    
    
    $scope.addResidence = function() {
      var modal = $modal.open({
        templateUrl: 'addResidenceTpl',
        controller: [
          '$scope', 'hotelList', 'roomList',
          function($scope, hotelList, roomList) {
            $scope.hotelList = hotelList;
            $scope.roomList = roomList;
            $scope.newRes = {};
            
            $scope.ok = function() {
              modal.close($scope.newRes);
            };
            
            $scope.cancel = function() {
              modal.dismiss();
            };
          }
        ],
        resolve: {
          hotelList : function() { 
            var deferred = $q.defer();
            
            db.query('SELECT * FROM HotelData').then(
              function(rows) { 
                deferred.resolve(rows);
              }, function(error) {
                toaster.pop('error', 'Помилка отримання даних про готелі', error);
                deferred.reject(error);
              }
            );
             
            return deferred.promise;
          },
          roomList : function() { 
            var deferred = $q.defer();
            
            db.query('SELECT * FROM RoomData').then(
              function(rows) { 
                deferred.resolve(rows);
              }, function(error) {
                toaster.pop('error', 'Помилка отримання даних про номери готелів', error);
                deferred.reject(error);
              }
            );
             
            return deferred.promise;
          }
        }
      });
      modal.result.then(
        function(newRes) {
          db.query('EXEC AddResidence @tourist_id, @room_id, @move_in, @move_out, @cost', [
            new db.Param('tourist_id', db.Types.Int, tourId),
            new db.Param('room_id', db.Types.Int, newRes.room.id.value),
            new db.Param('move_in', db.Types.NVarChar, new Date(newRes.move_in).toISO8601String()),
            new db.Param('move_out', db.Types.NVarChar, new Date(newRes.move_out).toISO8601String()),
            new db.Param('cost', db.Types.Real, parseFloat(newRes.cost))
          ]).then(
            function(rows) {
              fetchHotels();
              toaster.pop('success', 'Операція завершилась успішно', 'Нове місце проживання створено');
            }, function(error) {
              toaster.pop('error', 'Помилка створення нового місця проживання', error);
            }
          );
        }
      );
    };
    
    $scope.showResidence = function(res) {
      location.hash = '/tour/residence/' + res.residence_id.value;
    };
    
    $scope.addExcursion = function() {
      var modal = $modal.open({
        templateUrl: 'addExcursionVisitTpl',
        controller: [
          '$scope', 'agencyList', 'excursionList',
          function($scope, agencyList, excursionList) {
            $scope.agencyList = agencyList;
            $scope.excursionList = excursionList;
            $scope.newExc = {};
            
            $scope.ok = function() {
              modal.close($scope.newExc);
            };
            
            $scope.cancel = function() {
              modal.dismiss();
            };
          }
        ],
        resolve: {
          agencyList : function() { 
            var deferred = $q.defer();
            
            db.query('SELECT * FROM ExcursionAgency').then(
              function(rows) { 
                deferred.resolve(rows);
              }, function(error) {
                toaster.pop('error', 'Помилка отримання даних про екскурсійні агенства', error);
                deferred.reject(error);
              }
            );
             
            return deferred.promise;
          },
          excursionList : function() { 
            var deferred = $q.defer();
            
            db.query('SELECT * FROM ExcursionScheduleData').then(
              function(rows) { 
                deferred.resolve(rows);
              }, function(error) {
                toaster.pop('error', 'Помилка отримання даних про розклад екскурсій', error);
                deferred.reject(error);
              }
            );
             
            return deferred.promise;
          }
        }
      });
      modal.result.then(
        function(newExc) {
          db.query('EXEC AddExcursionVisit @tourist_id, @excursion_id', [
            new db.Param('tourist_id', db.Types.Int, tourId),
            new db.Param('excursion_id', db.Types.Int, newExc.excursion.id.value),
          ]).then(
            function(rows) {
              fetchExcursions();
              toaster.pop('success', 'Операція завершилась успішно', 'Нове відвідування екскурсії створено');
            }, function(error) {
              toaster.pop('error', 'Помилка створення нового відвідуваня екскурсії проживання', error);
            }
          );
        }
      );
    };
    
    $scope.delExcursion = function(excursion) {
      db.query('EXEC DeleteExcursionVisit @id', [
        new db.Param('id', db.Types.Int, excursion.visit_id.value)
      ]).then(
        function(rows) {
          fetchExcursions();
          toaster.pop('success', 'Операція завершилась успішно', 'Екскурсію видалено');
        }, function(error) {
          toaster.pop('error', 'Помилка видалення екскурсії', error);
        }
      );
    };
    
    $scope.addFlight = function() {
      var modal = $modal.open({
        templateUrl: 'addFlightForTourTpl',
        controller: [
          '$scope', 'flightList',
          function($scope, flightList) {
            $scope.flightList = flightList;
            $scope.newFlight = {};
            
            $scope.ok = function() {
              modal.close($scope.newFlight);
            };
            
            $scope.cancel = function() {
              modal.dismiss();
            };
          }
        ],
        resolve: {
          flightList : function() { 
            var deferred = $q.defer();
            
            db.query('SELECT * FROM FlightScheduleData').then(
              function(rows) { 
                deferred.resolve(rows);
              }, function(error) {
                toaster.pop('error', 'Помилка отримання даних про рейси', error);
                deferred.reject(error);
              }
            );
             
            return deferred.promise;
          }
        }
      });
      modal.result.then(
        function(newFlight) {
          db.query('EXEC AddFlightForTourist @tourist_id, @flight_id', [
            new db.Param('tourist_id', db.Types.Int, tourId),
            new db.Param('flight_id', db.Types.Int, newFlight.flight.id.value),
          ]).then(
            function(rows) {
              fetchFlights();
              toaster.pop('success', 'Операція завершилась успішно', 'Новий переліт створено');
            }, function(error) {
              toaster.pop('error', 'Помилка створення нового перельоту', error);
            }
          );
        }
      );
    }
    
    $scope.showFlight = function(flight) {
      location.hash = '/tour/flight/' + flight.flight_id.value;
    };
    
    fetchTourist();
    
    fetchGroups();
    fetchCategories();
    
    fetchParents();
    fetchChildren();
    fetchPossibleFamilyMembers();
  }
]);

mod.controller('residenceCtrl', [
  '$scope', 'db', '$modal', 'toaster', '$routeParams', '$window', '$q',
  function($scope, db, $modal, toaster, $routeParams, $window, $q) {
    var residenceId = $routeParams.residenceId;

    $scope.tourist = {};
    $scope.hotel = {};
    
    $scope.hotels = {};
    $scope.rooms = {};
    
    function fetchTourist() {
      db.query('SELECT * FROM GetTouristByResidence(@id)', [
        new db.Param('id', db.Types.Int, residenceId)
      ]).then(
        function(rows) {
          if (rows.length === 0) {
            toaster.pop('error', 'Помилка отримання даних про тур', 'Даних не знайдено');
          } else if (rows.length > 1) {
            toaster.pop('error', 'Помилка отримання даних про тур', 'Знайдено більше 1 запису');
          } else {
            $scope.tourist = rows[0];
          }
        }, function(error) {
          toaster.pop('error', 'Помилка отримання даних про тур', error);
        }
      );
    }    

    function fetchResidence() {
      db.query('SELECT * FROM ResidenceData WHERE residence_id = @id', [
        new db.Param('id', db.Types.Int, residenceId)
      ]).then(
        function(rows) {
          if (rows.length === 0) {
            toaster.pop('error', 'Помилка отримання даних про проживання', 'Даних не знайдено');
          } else if (rows.length > 1) {
            toaster.pop('error', 'Помилка отримання даних про проживання', 'Знайдено більше 1 запису');
          } else {
            $scope.hotel = rows[0];
          }
        }, function(error) {
          toaster.pop('error', 'Помилка отримання даних про проживання', error);
        }
      );
    }
    
    function fetchHotels() {
      db.query('SELECT * FROM HotelData').then(
        function(rows) {
          $scope.hotels = rows;
        }, function(error) {
          toaster.pop('error', 'Помилка отримання даних про готелі', error);
        }
      );
    }
    
    function fetchRooms() {
      db.query('SELECT * FROM RoomData').then(
        function(rows) { 
          $scope.rooms = rows;
        }, function(error) {
          toaster.pop('error', 'Помилка отримання даних про номери готелів', error);
        }
      );
    }
    
    $scope.saveResidence = function() {
      db.query('EXEC UpdateResidence @id, @room_id, @move_in, @move_out, @cost', [
        new db.Param('id', db.Types.Int, residenceId),
        new db.Param('room_id', db.Types.Int, $scope.hotel.room_id.value),
        new db.Param('move_in', db.Types.NVarChar, new Date($scope.hotel.move_in.value).toISO8601String()),
        new db.Param('move_out', db.Types.NVarChar, new Date($scope.hotel.move_out.value).toISO8601String()),
        new db.Param('cost', db.Types.Real, parseFloat($scope.hotel.cost.value))
      ]).then(
        function(rows) {
          toaster.pop('success', 'Зміни збережено');
        }, function(error) {
          toaster.pop('error', 'Помилка збереження змін', error);
        }
      );
    };
    
    $scope.delResidence = function() {
      var modal = $modal.open({
        templateUrl: 'delResidenceTpl',
        controller: [
          '$scope',
          function($scope) {
            $scope.ok = function() {
              modal.close();
            };
            
            $scope.cancel = function() {
              modal.dismiss();
            };
          }
        ]
      });
      modal.result.then(function() {
        db.query('EXEC DeleteResidence @id', [
          new db.Param('id', db.Types.Int, residenceId)
        ]).then(
          function(rows) {
            toaster.pop('success', 'Проживання успішно видалено');
            $window.history.back();
          }, function(error) {
            toaster.pop('error', 'Помилка видалення проживання', error);
          }
        );
      });
    };
    
    fetchTourist();
    fetchResidence();
    fetchHotels();
    fetchRooms();
  }
]);

mod.controller('touristFlightCtrl', [
  '$scope', 'db', '$modal', 'toaster', '$routeParams', '$window', '$q',
  function($scope, db, $modal, toaster, $routeParams, $window, $q) {
    var flightId = $routeParams.flightId;

    $scope.tourist = {};
    $scope.flight = {};
    $scope.baggage = [];
    
    function fetchTourist() {
      db.query('SELECT * FROM GetTouristByFlight(@id)', [
        new db.Param('id', db.Types.Int, flightId)
      ]).then(
        function(rows) {
          if (rows.length === 0) {
            toaster.pop('error', 'Помилка отримання даних про тур', 'Даних не знайдено');
          } else if (rows.length > 1) {
            toaster.pop('error', 'Помилка отримання даних про тур', 'Знайдено більше 1 запису');
          } else {
            $scope.tourist = rows[0];
            
            fetchFlight();
            fetchBaggage();
          }
        }, function(error) {
          toaster.pop('error', 'Помилка отримання даних про тур', error);
        }
      );
    }
    
    function fetchFlight() {
      db.query( 'SELECT * FROM GetFlightDetails(@id)', [
        new db.Param('id', db.Types.Int, flightId)
      ]).then(
        function(rows) {
          if (rows.length === 0) {
            toaster.pop('error', 'Помилка отримання даних про рейс', 'Даних не знайдено');
          } else if (rows.length > 1) {
            toaster.pop('error', 'Помилка отримання даних про рейс', 'Знайдено більше 1 запису');
          } else {
            $scope.flight = rows[0];
          }
        }, function(error) {
          toaster.pop('error', 'Помилка отримання даних про рейс', error);
        }
      );
    }
    
    function fetchBaggage() {
      db.query( 'SELECT bagList.*, sch.name AS baggage_plane, bt.name as type ' + 
                'FROM GetBaggageListForHuman(@human_id) AS bagList ' +
                'INNER JOIN FlightScheduleData AS sch ON sch.id = bagList.baggage_flight_id ' +
                'INNER JOIN BaggageType AS bt ON bt.id = bagList.type_id ' +
                'WHERE bagList.tourist_flight_id = @flight_id', [
        new db.Param('human_id', db.Types.Int, $scope.tourist.human_id.value),
        new db.Param('flight_id', db.Types.Int, flightId),
      ]).then(
        function(rows) {
          $scope.baggage = rows;
        }, function(error) {
          toaster.pop('error', 'Помилка отримання даних про багаж', error);
        }
      );
    }
    
    $scope.addBaggage = function() {
      var modal = $modal.open({
        templateUrl: 'addBaggageTpl',
        controller: [
          '$scope', 'flightList', 'typeList',
          function($scope, flightList, typeList) {
            $scope.flightList = flightList;
            $scope.typeList = typeList;
            $scope.bag = {};
            
            $scope.ok = function() {
              modal.close($scope.bag);
            };
            
            $scope.cancel = function() {
              modal.dismiss();
            };
          }
        ],
        resolve: {
          flightList : function() { 
            var deferred = $q.defer();
            
            db.query('SELECT * FROM FlightScheduleData').then(
              function(rows) { 
                deferred.resolve(rows);
              }, function(error) {
                toaster.pop('error', 'Помилка отримання даних про рейси', error);
                deferred.reject(error);
              }
            );
             
            return deferred.promise;
          },
          typeList : function() {
            var deferred = $q.defer();
            
            db.query('SELECT * FROM BaggageType').then(
              function(rows) { 
                deferred.resolve(rows);
              }, function(error) {
                toaster.pop('error', 'Помилка отримання даних про типи багажу', error);
                deferred.reject(error);
              }
            );
             
            return deferred.promise;
          }
        }
      });
      modal.result.then(
        function(bag) {
          db.query( 'EXEC AddBaggage @tourist_id, @type_id, @weight, @self_cost, @space_amount, @packing_cost, ' +
                    '@insurance_cost, @keep_cost, @date_storage_in, @date_storage_out, @flight_id', [
            new db.Param('tourist_id', db.Types.Int, flightId),
            new db.Param('type_id', db.Types.Int, bag.type.id.value),
            new db.Param('weight', db.Types.Float, parseFloat(bag.weight)),
            new db.Param('self_cost', db.Types.Real, parseFloat(bag.cost)),
            new db.Param('space_amount', db.Types.Float, parseFloat(bag.space_amount)),
            new db.Param('packing_cost', db.Types.Real, parseFloat(bag.packing)),
            new db.Param('insurance_cost', db.Types.Real, parseFloat(bag.insurance)),
            new db.Param('keep_cost', db.Types.Real, parseFloat(bag.keep)),
            new db.Param('date_storage_in', db.Types.NVarChar, new Date(bag.store_in).toISO8601String()),
            new db.Param('date_storage_out', db.Types.NVarChar, new Date(bag.store_out).toISO8601String()),
            new db.Param('flight_id', db.Types.Int, bag.flight.id.value)
          ]).then(
            function(rows) {
              fetchBaggage();
              toaster.pop('success', 'Операція завершилась успішно', 'Новий багаж створено');
            }, function(error) {
              toaster.pop('error', 'Помилка створення нового багажу', error);
            }
          );
        }
      );
    };
    
    $scope.removeBaggage = function(baggage) {
      db.query( 'EXEC DeleteBaggage @baggage_id', [
        new db.Param('baggage_id', db.Types.Int, baggage.id.value)
      ]).then(
        function(rows) {
          fetchBaggage();
          toaster.pop('success', 'Операція завершилась успішно', 'Багаж видалено');
        }, function(error) {
          toaster.pop('error', 'Помилка видалення багажу', error);
        }
      );
    };
    
    $scope.delFlight = function() {
      var modal = $modal.open({
        templateUrl: 'delTouristFlightTpl',
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
        db.query('EXEC DeleteTouristFlight @id', [
          new db.Param('id', db.Types.Int, flightId)
        ]).then(
          function(rows) {
            toaster.pop('success', 'Переліт успішно видалено');
            $window.history.back();
          }, function(error) {
            toaster.pop('error', 'Помилка видалення перельоту', error);
          }
        );
      });
    };
    
    fetchTourist();
  }
]);


})();
