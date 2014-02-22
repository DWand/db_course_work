(function() {

var mod = angular.module('dbm-reports', [
  'ng',
  'ngRoute',
  'db',
  'toaster'
]);

mod.config(['$routeProvider', function($routeProvider) {
  $routeProvider
    .when('/report/touristsGeneral', {
      templateUrl: 'view/reports/touristsGeneral.htm',
      controller: 'touristsGeneralCtrl'
    })
    .when('/report/touristsByCategory', {
      templateUrl: 'view/reports/touristsByCategory.htm',
      controller: 'touristsCategoryCtrl'
    })
    .when('/report/hotelResidence', {
      templateUrl: 'view/reports/hotelResidence.htm',
      controller: 'hotelResidenceCtrl'
    })
    .when('/report/hotelResidenceByCategory', {
      templateUrl: 'view/reports/hotelResidenceByCategory.htm',
      controller: 'hotelResidenceByCategoryCtrl'
    })
    .when('/report/bestExcursions', {
      templateUrl: 'view/reports/bestExcursions.htm',
      controller: 'bestExcursionsCtrl'
    })
    .when('/report/factor', {
      templateUrl: 'view/reports/factor.htm',
      controller: 'factorCtrl'
    })
    .when('/report/moneyByGroup', {
      templateUrl: 'view/reports/moneyByGroup.htm',
      controller: 'moneyByGroupCtrl'
    })
    .when('/report/moneyByGroupAndCategory', {
      templateUrl: 'view/reports/moneyByGroupAndCategory.htm',
      controller: 'moneyByGroupAndCategoryCtrl'
    })
    .when('/report/totalByPeriod', {
      templateUrl: 'view/reports/totalByPeriod.htm',
      controller: 'totalByPeriodCtrl'
    })
    .when('/report/amountByPeriodAndGroup', {
      templateUrl: 'view/reports/amountByPeriodAndGroup.htm',
      controller: 'amountByPeriodAndGroupCtrl'
    });
}]);


mod.controller('reportsCtrl', [
  '$scope', 'db',
  function($scope, db) {
  
  
  
  }
]);

function dateToString(date) {
  var d = date.getDate();
  var m = date.getMonth();
  var y = date.getFullYear();
  d = (d < 10) ? '0' + d : d;
  m = (m < 10) ? '0' + m : m;
  return d + '.' + m + '.' + y;
}

mod.controller('touristsGeneralCtrl', [
  '$scope', 'db', '$window', 'toaster',
  function($scope, db, $window, toaster) {
  
    function getTouristDataFromRow(row) {
      var data = {
        id: row[0].value,
        paid: row[1].value,
        humanId : row[2].value,
        name: row[3].value,
        surname: row[4].value,
        patronymic: row[5].value,
        sexId: row[6].value,
        sex: row[7].value,
        birthday: row[8].value,
        passport: row[9].value,
        groupId: row[10].value,
        group: row[11].value,
        category_id: row[12].value,
        category: row[13].value,
        dateIn: row[14].value,
        dateOut: row[15].value
      };
      data.birthdayStr = dateToString(data.birthday);
      data.dateInStr = dateToString(data.dateIn);
      data.dateOutStr = dateToString(data.dateOut);
      return data;
    }
  
    $scope.showTourist = function(id) {
      location.hash = '#/tourist/' + id
    };
    
    $scope.tourists = [];
    db.query('EXECUTE GetTouristsList').then(
      function(rows) {
        $scope.tourists = [];
        angular.forEach(rows,function(row) {
          $scope.tourists.push(getTouristDataFromRow(row));
        });
      }, function(err) {
        toaster.pop('error', 'Помилка отримання списка туристів', err);
      }
    );
  
  }
]);

mod.controller('touristsCategoryCtrl', [
  '$scope', 'db', '$window', 'toaster',
  function($scope, db, $window, toaster) {
  
    function getTouristDataFromRow(row) {
      var data = {
        id: row[0].value,
        paid: row[1].value,
        humanId : row[2].value,
        name: row[3].value,
        surname: row[4].value,
        patronymic: row[5].value,
        sexId: row[6].value,
        sex: row[7].value,
        birthday: row[8].value,
        passport: row[9].value,
        groupId: row[10].value,
        group: row[11].value,
        categoryId: row[12].value,
        category: row[13].value,
        dateIn: row[14].value,
        dateOut: row[15].value
      };
      data.birthdayStr = dateToString(data.birthday);
      data.dateInStr = dateToString(data.dateIn);
      data.dateOutStr = dateToString(data.dateOut);
      return data;
    }
  
    $scope.showTourist = function(id) {
      location.hash = '#/tourist/' + id
    };
    
    $scope.categoryName = '';
    
    $scope.tourists = [];
    $scope.showCategory = function(category) {
      db.query('EXECUTE GetTouristsListByCategory @category_id=@id', [
        new db.Param('id', db.Types.Int, category[0])
      ]).then(
        function(rows) {
          $scope.categoryName = category[1];
          $scope.tourists = [];
          angular.forEach(rows,function(row) {
            $scope.tourists.push(getTouristDataFromRow(row));
          });
        }, function(err) {
          toaster.pop('error', 'Помилка отримання списка туристів', err);
        }
      );
    };
    
    $scope.categories = [];
    db.query('SELECT * FROM TouristCategory').then(
      function(rows) {
        $scope.categories = [];
        angular.forEach(rows,function(row) {
          $scope.categories.push([row[0].value, row[1].value]);
        });
      }, function(err) {
        toaster.pop('error', 'Помилка отримання списка категорій', err);
      }
    );
  
  }
]);

mod.controller('hotelResidenceCtrl', [
  '$scope', 'db', '$window', 'toaster',
  function($scope, db, $window, toaster) {
  
    function getResidenceDataFromRow(row) {
      var data = {
        id: row[0].value,
        name: row[1].value,
        surname: row[2].value,
        patronymic: row[3].value,
        category: row[4].value,
        group: row[5].value,
        dateIn: row[6].value,
        dateOut: row[7].value,
        room: row[8].value
      };
      data.dateInStr = dateToString(data.dateIn);
      data.dateOutStr = dateToString(data.dateOut);
      return data;
    }

    $scope.showTourist = function(id) {
      location.hash = '#/tourist/' + id
    };
    
    $scope.hotelName = '';
    
    $scope.tourists = [];
    $scope.showHotel = function(hotel) {
      db.query( 'SELECT info.id, info.name, info.surname, info.patronymic, info.category, info."group", res.move_in, res.move_out, Room.label ' + 
                'FROM dbo.GetResidenceForHotel(@id) AS res ' +
                'INNER JOIN TouristInfo AS info ON info.id = res.tourist_id ' +
                'INNER JOIN Room ON Room.id = res.room_id', [
        new db.Param('id', db.Types.Int, hotel[0])
      ]).then(
        function(rows) {
          $scope.hotelName = hotel[1];
          $scope.tourists = [];
          angular.forEach(rows,function(row) {
            $scope.tourists.push(getResidenceDataFromRow(row));
          });
        }, function(err) {
          toaster.pop('error', 'Помилка отримання списка туристів', err);
        }
      );
    };
    
    $scope.hotels = [];
    db.query('SELECT * FROM Hotel').then(
      function(rows) {
        $scope.hotels = [];
        angular.forEach(rows,function(row) {
          $scope.hotels.push([row[0].value, row[1].value]);
        });
      }, function(err) {
        toaster.pop('error', 'Помилка отримання списка готелів', err);
      }
    );
    
  }
]);

mod.controller('hotelResidenceByCategoryCtrl', [
  '$scope', 'db', '$window', 'toaster',
  function($scope, db, $window, toaster) {
  
    function getResidenceDataFromRow(row) {
      var data = {
        id: row[0].value,
        name: row[1].value,
        surname: row[2].value,
        patronymic: row[3].value,
        category: row[4].value,
        group: row[5].value,
        dateIn: row[6].value,
        dateOut: row[7].value,
        room: row[8].value
      };
      data.dateInStr = dateToString(data.dateIn);
      data.dateOutStr = dateToString(data.dateOut);
      return data;
    }

    $scope.showTourist = function(id) {
      location.hash = '#/tourist/' + id
    };
    
    $scope.tourists = [];
    function showTourists(hotelId, categoryId) {
      db.query( 'SELECT info.id, info.name, info.surname, info.patronymic, info.category, info."group", res.move_in, res.move_out, Room.label ' + 
                'FROM dbo.GetResidenceForHotelByCategory(@hotel_id, @category_id) AS res ' +
                'INNER JOIN TouristInfo AS info ON info.id = res.tourist_id ' +
                'INNER JOIN Room ON Room.id = res.room_id', [
        new db.Param('hotel_id', db.Types.Int, hotelId),
        new db.Param('category_id', db.Types.Int, categoryId)
      ]).then(
        function(rows) {
          $scope.tourists = [];
          angular.forEach(rows,function(row) {
            $scope.tourists.push(getResidenceDataFromRow(row));
          });
        }, function(err) {
          toaster.pop('error', 'Помилка отримання списка туристів', err);
        }
      );
    }
    
    var hotelId = undefined;
    var categoryId = undefined;
    
    $scope.hotelName = '';
    $scope.categoryName = '';
    
    $scope.showHotel = function(hotel) {
      $scope.hotelName = hotel[1];
      hotelId = hotel[0];
      if (hotelId !== undefined && categoryId !== undefined) {
        showTourists(hotelId, categoryId);
      }
    };

    $scope.showCategory = function(category) {
      $scope.categoryName = category[1];
      categoryId = category[0];
      if (hotelId !== undefined && categoryId !== undefined) {
        showTourists(hotelId, categoryId);
      }
    };
    
    $scope.hotels = [];
    db.query('SELECT * FROM Hotel').then(
      function(rows) {
        $scope.hotels = [];
        angular.forEach(rows,function(row) {
          $scope.hotels.push([row[0].value, row[1].value]);
        });
      }, function(err) {
        toaster.pop('error', 'Помилка отримання списка готелів', err);
      }
    );
    
    $scope.categories = [];
    db.query('SELECT * FROM TouristCategory').then(
      function(rows) {
        $scope.categories = [];
        angular.forEach(rows,function(row) {
          $scope.categories.push([row[0].value, row[1].value]);
        });
      }, function(err) {
        toaster.pop('error', 'Помилка отримання списка категорій', err);
      }
    );
    
  }
]);

mod.controller('bestExcursionsCtrl', [
  '$scope', 'db', '$window', 'toaster',
  function($scope, db, $window, toaster) {
  
    function getExcursionDataFromRow(row) {
      var data = {
        id: row[0].value,
        name: row[1].value,
        description: row[2].value,
        agencyId: row[3].value,
        agencyName: row[4].value,
        visits: row[5].value
      };
      return data;
    }
    
    function getAgencyDataFromRow(row) {
      var data = {
        id: row[0].value,
        name: row[1].value,
        visits: row[2].value
      };
      return data;
    }
  
    $scope.excursions = [];
    db.query( 'SELECT excursion.id, excursion.name, excursion.description, agency.id, agency.name, excursion.visits ' + 
              'FROM MostPopularExcursions AS excursion ' +
              'INNER JOIN ExcursionAgency AS agency ON agency.id = excursion.agency_id').then(
      function(rows) {
        $scope.excursions = [];
        angular.forEach(rows, function(row) {
          $scope.excursions.push(getExcursionDataFromRow(row));
        });
      }, function(err) {
        toaster.pop('error', 'Помилка отримання списка найпопулярніших екскурсій', err);
      }
    );
    
    $scope.agencies = [];
    db.query( 'SELECT agency.id, agency.name, best.excursions_visits ' +
              'FROM TheBestExcursionAgencies AS best ' +
              'INNER JOIN ExcursionAgency AS agency on agency.id = best.agency_id').then(
      function(rows) {
        $scope.agencies = [];
        angular.forEach(rows, function(row) {
          $scope.agencies.push(getAgencyDataFromRow(row));
        });
      }, function(err) {
        toaster.pop('error', 'Помилка отримання списка найкращих екскурсійних агенств', err);
      }
    );
    
  }
]);

mod.controller('factorCtrl', [
  '$scope', 'db', '$window', 'toaster',
  function($scope, db, $window, toaster) {
  
    $scope.factor = undefined;
    
    function fetchFactor() {
      db.query('select dbo.GetRatioBetweenRestAndShop() AS factor').then(
        function(rows) {
          $scope.factor = rows[0].factor;
        }, function(error) {
          toaster.pop('error', 'Помилка отримання відношення видів туристів', error);
        }
      )
    }
    
    fetchFactor();
  }
]);

mod.controller('moneyByGroupCtrl', [
  '$scope', 'db', '$window', 'toaster',
  function($scope, db, $window, toaster) {
  
    $scope.groups = [];
    $scope.groupName = '';
    $scope.report = {};
    
    function fetchGroups() {
      db.query('SELECT * FROM TouristGroup').then(
        function(rows) {
          $scope.groups = rows;
        }, function(error) {
          toaster.pop('error', 'Помилка отримання груп туристів', error);
        }
      )
    }
    
    $scope.showGroup = function(group) {
      $scope.groupName = group.label.value;
      
      db.query('EXEC FinancialReportByGroup @group_id', [
        new db.Param('group_id', db.Types.Int, group.id.value)
      ]).then(
        function(rows) {
          $scope.report = rows[0];
        }, function(error) {
          toaster.pop('error', 'Помилка отримання звіту', error);
        }
      )
    };
    
    fetchGroups();
  }
]);


mod.controller('moneyByGroupAndCategoryCtrl', [
  '$scope', 'db', '$window', 'toaster',
  function($scope, db, $window, toaster) {
  
    $scope.groups = [];
    $scope.categories = [];
    $scope.group = undefined;
    $scope.category = undefined;
    $scope.report = {};
    
    function fetchCategories() {
      db.query('SELECT * FROM TouristCategory').then(
        function(rows) {
          $scope.categories = rows;
        }, function(error) {
          toaster.pop('error', 'Помилка отримання категорій туристів', error);
        }
      )
    }
    
    function fetchGroups() {
      db.query('SELECT * FROM TouristGroup').then(
        function(rows) {
          $scope.groups = rows;
        }, function(error) {
          toaster.pop('error', 'Помилка отримання груп туристів', error);
        }
      )
    }
    
    function fetchReport() {
      if ($scope.category && $scope.group) {
        db.query('EXEC FinancialReportByGroupAndCategory @group_id, @category_id', [
          new db.Param('group_id', db.Types.Int, $scope.group.id.value),
          new db.Param('category_id', db.Types.Int, $scope.category.id.value)
        ]).then(
          function(rows) {
            $scope.report = rows[0];
          }, function(error) {
            toaster.pop('error', 'Помилка отримання звіту', error);
          }
        );
      }
    }
    
    $scope.showCategory = function(category) {
      $scope.category = category;
      fetchReport();
    };
    
    $scope.showGroup = function(group) {
      $scope.group = group;
      fetchReport();
    };
    
    fetchCategories();
    fetchGroups();
  }
]);



mod.controller('totalByPeriodCtrl', [
  '$scope', 'db', '$window', 'toaster',
  function($scope, db, $window, toaster) {
    
    $scope.touristsAmount = 0;
    $scope.excursionVisits = 0;
    $scope.factor = 0;
    $scope.hotels = [];
    $scope.baggage = {};
    $scope.separateBaggageStats = [];
    $scope.debetCredit = {};
    $scope.rentability = 0;
    
    function fetchTouristsAmount() {
      db.query('SELECT dbo.GetTouristsAmountForPeriod(@start, @end) AS amount',[
        new db.Param('start', db.Types.NVarChar, $scope.begin),
        new db.Param('end', db.Types.NVarChar, $scope.end)
      ]).then(
        function(rows) {
          $scope.touristsAmount = rows[0].amount;
        }, function(error) {
          toaster.pop('error', 'Помилка отримання кількості туристів', error);
        }
      );
    }
    
    function fetchExcursionVisits() {
      db.query('SELECT dbo.GetTouristsAmountWhoWhentToExcursionsByPeriod(@start, @end) AS amount',[
        new db.Param('start', db.Types.NVarChar, $scope.begin),
        new db.Param('end', db.Types.NVarChar, $scope.end)
      ]).then(
        function(rows) {
          $scope.excursionVisits = rows[0].amount;
        }, function(error) {
          toaster.pop('error', 'Помилка отримання кількості туристів', error);
        }
      );
    }
    
    function fetchHotels() {
      db.query('SELECT * FROM GetHotelForResidenceByPeriodWithOccupiedRoomsAmount(@start, @end)',[
        new db.Param('start', db.Types.NVarChar, $scope.begin),
        new db.Param('end', db.Types.NVarChar, $scope.end)
      ]).then(
        function(rows) {
          $scope.hotels = rows;
        }, function(error) {
          toaster.pop('error', 'Помилка отримання статистики готелів', error);
        }
      );
    }
    
    function fetchBaggage() {
      db.query('EXEC GetStorageStatistics @start, @end',[
        new db.Param('start', db.Types.NVarChar, $scope.begin),
        new db.Param('end', db.Types.NVarChar, $scope.end)
      ]).then(
        function(rows) {
          $scope.baggage = rows[0];
        }, function(error) {
          toaster.pop('error', 'Помилка отримання статистики складу', error);
        }
      );
    }
    
    function fetchSeparateBaggageStats() {
      db.query('EXEC GetBaggageTypeStatistics @start, @end',[
        new db.Param('start', db.Types.NVarChar, $scope.begin),
        new db.Param('end', db.Types.NVarChar, $scope.end)
      ]).then(
        function(rows) {
          $scope.separateBaggageStats = rows;
        }, function(error) {
          toaster.pop('error', 'Помилка отримання статистики по видам багажу', error);
        }
      );
    }
    
    function fetchDebetCredit() {
      db.query('SELECT dbo.DebetCreditByPeriodIncome(@start, @end) AS income',[
        new db.Param('start', db.Types.NVarChar, $scope.begin),
        new db.Param('end', db.Types.NVarChar, $scope.end)
      ]).then(
        function(rows) {
          $scope.debetCredit.income = rows[0].income;
        }, function(error) {
          toaster.pop('error', 'Помилка отримання кількості доходів', error);
        }
      );
      
      db.query('SELECT dbo.DebetCreditByPeriodPlanes(@start, @end) AS planes',[
        new db.Param('start', db.Types.NVarChar, $scope.begin),
        new db.Param('end', db.Types.NVarChar, $scope.end)
      ]).then(
        function(rows) {
          $scope.debetCredit.planes = rows[0].planes;
        }, function(error) {
          toaster.pop('error', 'Помилка отримання видатків на літаки', error);
        }
      );
      
      db.query('SELECT dbo.DebetCreditByPeriodHotels(@start, @end) AS hotels',[
        new db.Param('start', db.Types.NVarChar, $scope.begin),
        new db.Param('end', db.Types.NVarChar, $scope.end)
      ]).then(
        function(rows) {
          $scope.debetCredit.hotels = rows[0].hotels;
        }, function(error) {
          toaster.pop('error', 'Помилка отримання видатків на готелі', error);
        }
      );
      
      db.query('SELECT dbo.DebetCreditByPeriodExcursions(@start, @end) AS exc',[
        new db.Param('start', db.Types.NVarChar, $scope.begin),
        new db.Param('end', db.Types.NVarChar, $scope.end)
      ]).then(
        function(rows) {
          $scope.debetCredit.excursions = rows[0].exc;
        }, function(error) {
          toaster.pop('error', 'Помилка отримання видатків на екскурсії', error);
        }
      );
      
      db.query('SELECT dbo.DebetCreditByPeriodVisas(@start, @end) AS visas',[
        new db.Param('start', db.Types.NVarChar, $scope.begin),
        new db.Param('end', db.Types.NVarChar, $scope.end)
      ]).then(
        function(rows) {
          $scope.debetCredit.visas = rows[0].visas;
        }, function(error) {
          toaster.pop('error', 'Помилка отримання видатків на оформлення віз', error);
        }
      );
      
      db.query('SELECT dbo.DebetCreditByPeriodSpendings(@start, @end) AS spendings',[
        new db.Param('start', db.Types.NVarChar, $scope.begin),
        new db.Param('end', db.Types.NVarChar, $scope.end)
      ]).then(
        function(rows) {
          $scope.debetCredit.spendings = rows[0].spendings;
        }, function(error) {
          toaster.pop('error', 'Помилка отримання видатків представництва', error);
        }
      );
    }
    
    function fetchRentability() {
      db.query('SELECT dbo.RentabilityByPeriod(@start, @end) AS amount',[
        new db.Param('start', db.Types.NVarChar, $scope.begin),
        new db.Param('end', db.Types.NVarChar, $scope.end)
      ]).then(
        function(rows) {
          $scope.rentability = rows[0].amount;
        }, function(error) {
          toaster.pop('error', 'Помилка отримання рентабельності', error);
        }
      );
    }
    
    function fetchFactor() {
      db.query('SELECT dbo.GetRatioBetweenRestAndShopByPeriod(@start, @end) AS amount',[
        new db.Param('start', db.Types.NVarChar, $scope.begin),
        new db.Param('end', db.Types.NVarChar, $scope.end)
      ]).then(
        function(rows) {
          $scope.factor = rows[0].amount;
        }, function(error) {
          toaster.pop('error', 'Помилка отримання відношення туристів', error);
        }
      );
    }
    
    $scope.begin;
    $scope.end;
    $scope.generate = function() {
      
      fetchTouristsAmount();
      fetchHotels();
      fetchExcursionVisits();
      fetchBaggage();
      fetchSeparateBaggageStats();
      fetchDebetCredit();
      fetchRentability();
      fetchFactor();
      
    };
    
  }
]);

mod.controller('amountByPeriodAndGroupCtrl', [
  '$scope', 'db', '$window', 'toaster',
  function($scope, db, $window, toaster) {
    
    $scope.begin;
    $scope.end;
    $scope.categories = [];
    $scope.category = {};
    $scope.amount = 0;
    
    function fetchCategories() {
      db.query('SELECT * FROM TouristCategory').then(
        function(rows) {
          $scope.categories = rows;
        }, function(error) {
          toaster.pop('error', 'Помилка отримання категорій туристів', error);
        }
      )
    }
    
    $scope.generate = function() {
      db.query('SELECT dbo.GetTouristsAmountForPeriodByCategory(@start, @end, @cat_id) AS amount',[
        new db.Param('start', db.Types.NVarChar, $scope.begin),
        new db.Param('end', db.Types.NVarChar, $scope.end),
        new db.Param('cat_id', db.Types.Int, $scope.category.id.value)
      ]).then(
        function(rows) {
          $scope.amount = rows[0].amount;
        }, function(error) {
          toaster.pop('error', 'Помилка отримання кількості туристів', error);
        }
      );
    };
    
    $scope.showCategory = function(category) {
      $scope.category = category;
    };
    
    fetchCategories();
    
  }
]);

})();
