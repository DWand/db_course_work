(function() {

var mod = angular.module('dbm-hotels', [
  'ng',
  'ngRoute',
  'db',
  'ui.bootstrap', 'ui.bootstrap.modal', 'ui.bootstrap.dropdownToggle',
  'toaster',
  'ngRoute'
]);

mod.config(['$routeProvider', function($routeProvider) {
  $routeProvider
    .when('/hotel/:hotelId', {
      templateUrl: 'view/hotels/hotel.htm',
      controller: 'hotelCtrl'
    })
    .when('/room/:roomId', {
      templateUrl: 'view/hotels/room.htm',
      controller: 'roomCtrl'
    });
}]);

mod.controller('hotelsCtrl', [
  '$scope', 'db', '$modal', 'toaster',
  function($scope, db, $modal, toaster) {
  
    $scope.cities = [];
    $scope.hotels = [];
    
    function fetchCities() {
      db.query('SELECT * FROM City').then(
        function(rows) {
          $scope.cities = rows;
        }, function(error) {
          toaster.pop('error', 'Помилка отримання даних про міста', error);
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
    
    function fetchHotelsByCity(city) {
      db.query( 'SELECT * FROM GetHotelsFromCity(@city_id)', [
        new db.Param('city_id', db.Types.Int, city.id.value)
      ]).then(
        function(rows) {
          $scope.hotels = rows;
        }, function(error) {
          toaster.pop('error', 'Помилка отримання даних про готелі', error);
        }
      );
    }
    
    $scope.addCity = function() {
      var modal = $modal.open({
        templateUrl: 'addCityTpl',
        controller: [
          '$scope',
          function($scope) {
            $scope.newCity = {};
            
            $scope.ok = function() {
              modal.close($scope.newCity);
            };
            
            $scope.cancel = function() {
              modal.dismiss();
            };
          }
        ]
      });
      modal.result.then(
        function(newCity) {
          db.query( 'INSERT INTO City (name) VALUES (@name)', [
            new db.Param('name', db.Types.NVarChar, newCity.name)
          ]).then(
            function(rows) {
              fetchCities();
              toaster.pop('success', 'Операція завершилась успішно', 'Нове місто створено');
            }, function(error) {
              toaster.pop('error', 'Помилка створення нового міста', error);
            }
          );
        }
      );
    };
    
    $scope.editCity = function(city) {
      var modal = $modal.open({
        templateUrl: 'editCityTpl',
        controller: [
          '$scope', 'city',
          function($scope, city) {
            $scope.city = city;
            
            $scope.ok = function() {
              modal.close($scope.city);
            };
            
            $scope.cancel = function() {
              modal.dismiss();
            };
          }
        ],
        resolve : {
          city : function() { return city; }
        }
      });
      modal.result.then(
        function(city) {
          db.query('EXEC UpdateCity @id, @name', [
            new db.Param('id', db.Types.Int, city.id.value),
            new db.Param('name', db.Types.NVarChar, city.name.value)
          ]).then(
            function(rows) {
              fetchCities();
              fetchHotels();
              toaster.pop('success', 'Операція завершилась успішно', 'Інформація про місто збережена');
            }, function(error) {
              toaster.pop('error', 'Помилка збереження інформації про місто', error);
            }
          );
        }
      );
    };
    
    $scope.delCity = function(city) {
      var modal = $modal.open({
        templateUrl: 'delCityTpl',
        controller: [
          '$scope', 'city',
          function($scope, city) {
            $scope.city = city;
            
            $scope.ok = function() {
              modal.close();
            };
            
            $scope.cancel = function() {
              modal.dismiss();
            };
          }
        ],
        resolve : {
          city : function() { return city; }
        }
      });
      modal.result.then(
        function() {
          db.query('EXEC DeleteCity @id', [
            new db.Param('id', db.Types.Int, city.id.value)
          ]).then(
            function(rows) {
              fetchCities();
              fetchHotels();
              toaster.pop('success', 'Операція завершилась успішно', 'Інформація про місто видалена');
            }, function(error) {
              toaster.pop('error', 'Помилка видалення інформації про місто', error);
            }
          );
        }
      );
    };
    
    $scope.addHotel = function() {
      var modal = $modal.open({
        templateUrl: 'addHotelTpl',
        controller: [
          '$scope', 'cities',
          function($scope, cities) {
            $scope.cities = cities;
            $scope.newHotel = {};
            
            $scope.ok = function() {
              modal.close($scope.newHotel);
            };
            
            $scope.cancel = function() {
              modal.dismiss();
            };
          }
        ],
        resolve: {
          cities : function() { return $scope.cities; }
        }
      });
      modal.result.then(
        function(newHotel) {
          db.query( 'EXEC AddHotel @name, @city_id', [
            new db.Param('name', db.Types.NVarChar, newHotel.name),
            new db.Param('city_id', db.Types.Int, newHotel.city.id.value)
          ]).then(
            function(rows) {
              fetchHotels();
              toaster.pop('success', 'Операція завершилась успішно', 'Новий готель створено');
            }, function(error) {
              toaster.pop('error', 'Помилка створення нового готеля', error);
            }
          );
        }
      );
    };
    
    $scope.showHotel = function(hotel) {
      location.hash = '/hotel/' + hotel.id.value;
    };
    
    $scope.showAllHotels = function() {
      fetchHotels();
    };
    
    $scope.showCity = function(city) {
      fetchHotelsByCity(city);
    };
    
    fetchCities();
    fetchHotels();
  }
]);

mod.controller('hotelCtrl', [
  '$scope', 'db', '$modal', 'toaster', '$routeParams', 
  function($scope, db, $modal, toaster, $routeParams) {
    var hotelId = $routeParams.hotelId;
  
    $scope.hotel = {};
    $scope.rooms = [];
    
    $scope.cities = [];
    
    function fetchHotel() {
      db.query('SELECT * FROM HotelData WHERE id = @id', [
        new db.Param('id', db.Types.Int, hotelId)
      ]).then(
        function(rows) {
          if (rows.length === 0) {
            toaster.pop('error', 'Помилка отримання даних про готель', 'Даних не знайдено');
          } else if (rows.length > 1) {
            toaster.pop('error', 'Помилка отримання даних про готель', 'Знайдено більше 1 запису');
          } else {
            $scope.hotel = rows[0];
          }
        }, function(error) {
          toaster.pop('error', 'Помилка отримання даних про готель', error);
        }
      );
    }
    
    function fetchRooms() {
      db.query('SELECT * FROM GetRoomsOfHotel(@id)', [
        new db.Param('id', db.Types.Int, hotelId)
      ]).then(
        function(rows) {
          $scope.rooms = rows;
        }, function(error) {
          toaster.pop('error', 'Помилка отримання даних про номери готеля', error);
        }
      );
    }
    
    function fetchCities() {
      db.query('SELECT * FROM City').then(
        function(rows) {
          $scope.cities = rows;
        }, function(error) {
          toaster.pop('error', 'Помилка отримання даних про міста', error);
        }
      );
    }
    
    $scope.addRoom = function() {
      var modal = $modal.open({
        templateUrl: 'addRoomTpl',
        controller: [
          '$scope',
          function($scope) {
            $scope.newRoom = {};
            
            $scope.ok = function() {
              modal.close($scope.newRoom);
            };
            
            $scope.cancel = function() {
              modal.dismiss();
            };
          }
        ]
      });
      modal.result.then(
        function(newRoom) {
          db.query('EXEC AddRoom @name, @hotel_id', [
            new db.Param('name', db.Types.NVarChar, newRoom.name),
            new db.Param('hotel_id', db.Types.Int, hotelId),
          ]).then(
            function(rows) {
              fetchRooms();
              toaster.pop('success', 'Операція завершилась успішно', 'Новий номер створено');
            }, function(error) {
              toaster.pop('error', 'Помилка створення нового номера', error);
            }
          );
        }
      );
    };
    
    $scope.saveHotel = function() {
      db.query('EXEC UpdateHotel @id, @city_id, @name', [
        new db.Param('id', db.Types.Int, hotelId),
        new db.Param('city_id', db.Types.Int, $scope.hotel.city_id.value),
        new db.Param('name', db.Types.NVarChar, $scope.hotel.name.value),
      ]).then(
        function(rows) {
          toaster.pop('success', 'Зміни збережено');
        }, function(error) {
          toaster.pop('error', 'Помилка збереження змін', error);
        }
      );
    };
    
    $scope.delHotel = function() {
      var modal = $modal.open({
        templateUrl: 'delHotelTpl',
        controller: [
          '$scope', 'hotel',
          function($scope, hotel) {
            $scope.hotel = hotel;
            
            $scope.ok = function() {
              modal.close();
            };
            
            $scope.cancel = function() {
              modal.dismiss();
            };
          }
        ],
        resolve : {
          hotel : function() { return $scope.hotel; }
        }
      });
      modal.result.then(
        function() {
          db.query('EXEC DeleteHotel @id', [
            new db.Param('id', db.Types.Int, $scope.hotel.id.value)
          ]).then(
            function(rows) {
              toaster.pop('success', 'Операція завершилась успішно', 'Інформація про готель видалена');
            }, function(error) {
              toaster.pop('error', 'Помилка видалення інформації про готель', error);
            }
          );
        }
      );
    };
    
    $scope.showRoom = function(room) {
      location.hash = '/room/' + room.id.value;
    };
    
    fetchHotel();
    fetchRooms();
    fetchCities();
  }
]);

mod.controller('roomCtrl', [
  '$scope', 'db', '$modal', 'toaster', '$routeParams', '$window',
  function($scope, db, $modal, toaster, $routeParams, $window) {
    var roomId = $routeParams.roomId;
  
    $scope.room = {};
    
    function fetchRoom() {
      db.query('SELECT * FROM RoomData WHERE id = @id', [
        new db.Param('id', db.Types.Int, roomId)
      ]).then(
        function(rows) {
          if (rows.length === 0) {
            toaster.pop('error', 'Помилка отримання даних про номер', 'Даних не знайдено');
          } else if (rows.length > 1) {
            toaster.pop('error', 'Помилка отримання даних про номер', 'Знайдено більше 1 запису');
          } else {
            $scope.room = rows[0];
          }
        }, function(error) {
          toaster.pop('error', 'Помилка отримання даних про номер', error);
        }
      );
    }
    
    $scope.saveRoom = function() {
      db.query('EXEC UpdateRoom @id, @label', [
        new db.Param('id', db.Types.Int, roomId),
        new db.Param('label', db.Types.NVarChar, $scope.room.name.value),
      ]).then(
        function(rows) {
          toaster.pop('success', 'Зміни збережено');
        }, function(error) {
          toaster.pop('error', 'Помилка збереження змін', error);
        }
      );
    };
    
    $scope.delRoom = function() {
      var modal = $modal.open({
        templateUrl: 'delRoomTpl',
        controller: [
          '$scope', 'room',
          function($scope, room) {
            $scope.room = room;
            
            $scope.ok = function() {
              modal.close();
            };
            
            $scope.cancel = function() {
              modal.dismiss();
            };
          }
        ],
        resolve : {
          room : function() { return $scope.room; }
        }
      });
      modal.result.then(
        function() {
          db.query('EXEC DeleteRoom @id', [
            new db.Param('id', db.Types.Int, $scope.room.id.value)
          ]).then(
            function(rows) {
              $window.history.back();
              toaster.pop('success', 'Операція завершилась успішно', 'Інформація про номер видалена');
            }, function(error) {
              toaster.pop('error', 'Помилка видалення інформації про номер', error);
            }
          );
        }
      );
    };
    
    fetchRoom();
  }
]);

})();
