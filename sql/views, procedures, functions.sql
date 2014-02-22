USE "sp110_15_db_2013";




-- Дати прибуття і відбуття туриста з країни
-- DROP VIEW "TouristInCountryDates"
CREATE VIEW "TouristInCountryDates"
AS
SELECT
  "Tourist"."id" AS "tourist_id",
  MIN("Schedule"."landing_date") AS "date_in",
  MAX("Schedule"."takeoff_date") AS "date_out"
FROM "Tourist"
INNER JOIN "Flight" ON "Flight"."tourist_id" = "Tourist"."id"
INNER JOIN "PlaneSchedule" AS "Schedule" ON "Schedule"."id" = "Flight"."flight_id"
GROUP BY "Tourist"."id";

GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON "TouristInCountryDates" TO "Admin" WITH GRANT OPTION;
-- GRANT SELECT ON "TouristInCountryDates" TO "ExcursionManager";

-- SELECT * FROM "TouristInCountryDates";




-- Кількість відвідувань екскурсій
-- DROP VIEW "ExcursionVisits"
CREATE VIEW "ExcursionVisits"
AS
SELECT 
  "Excursion"."id" AS "excursion_id",
  COUNT("Visit"."id") AS "visits"
FROM "Excursion"
INNER JOIN "ExcursionSchedule" AS "Schedule" ON "Schedule"."excursion_id" = "Excursion"."id"
INNER JOIN "ExcursionVisit" AS "Visit" ON "Visit"."excursion_id" = "Schedule"."id"
GROUP BY "Excursion"."id";

GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON "ExcursionVisits" TO "Admin" WITH GRANT OPTION;
-- GRANT SELECT ON "ExcursionVisits" TO "ExcursionManager";

-- SELECT * FROM "ExcursionVisits";




-- DROP VIEW "TouristInfo"
CREATE VIEW "TouristInfo"
AS
SELECT 
  "Tourist"."id" AS "id",
  "Tourist"."paid_for_tour" AS "paid",
  "Human"."id" AS "human_id",
  "Human"."name" AS "name",
  "Human"."surname" AS "surname",
  "Human"."patronymic" AS "patronymic",
  "Sex"."id" AS "sex_id",
  "Sex"."name" AS "sex",
  "Human"."birthday" AS "birthday",
  "Human"."passport" AS "passport",
  "Group"."id" AS "group_id",
  "Group"."label" AS "group",
  "Cat"."id" AS "category_id",
  "Cat"."name" AS "category",
  "Dates"."date_in" AS "date_in",
  "Dates"."date_out" AS "date_out"
FROM "Tourist"
INNER JOIN "Human" ON "Human"."id" = "Tourist"."human_id"
INNER JOIN "Sex" ON "Sex"."id" = "Human"."sex_id"
INNER JOIN "TouristGroup" AS "Group" ON "Group"."id" = "Tourist"."group_id"
INNER JOIN "TouristCategory" AS "Cat" ON "Cat"."id" = "Tourist"."category_id"
LEFT JOIN "TouristInCountryDates" AS "Dates" ON "Dates"."tourist_id" = "Tourist"."id";

GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON "TouristInfo" TO "Admin" WITH GRANT OPTION;




-- 1
-- Список туристів для митниці
-- в цілому
-- DROP PROCEDURE GetTouristsList
CREATE PROCEDURE "GetTouristsList"
AS
SELECT *
FROM "TouristInfo";

GRANT EXECUTE ON "GetTouristsList" TO "Admin" WITH GRANT OPTION;
-- GRANT EXECUTE ON "GetTouristsList" TO "ExcursionManager";

-- EXECUTE "GetTouristsList";




-- 1
-- Список туристів для митниці
-- по зазначеній категорії
-- DROP PROCEDURE "GetTouristsListByCategory"
CREATE PROCEDURE "GetTouristsListByCategory"
  @category_id INT
AS
SELECT *
FROM "TouristInfo"
WHERE "category_id" = @category_id;

GRANT EXECUTE ON "GetTouristsListByCategory" TO "Admin" WITH GRANT OPTION;
-- GRANT EXECUTE ON "GetTouristsListByCategory" TO "ExcursionManager";

-- EXECUTE "GetTouristsListByCategory" 1




-- 2
-- Список для розселення по зазначених готелях
-- в цілому
-- DROP FUNCTION "GetResidenceForHotel"
CREATE FUNCTION "GetResidenceForHotel" (
  @hotel_id INT
) RETURNS TABLE
AS
RETURN SELECT
  "Tourist"."id" AS "tourist_id",
  "Room"."id" AS "room_id",
  "Hotel"."id" AS "hotel_id",
  "Residence"."move_in" AS "move_in",
  "Residence"."move_out" AS "move_out"
FROM "Tourist"
INNER JOIN "Residence" ON "Residence"."tourist_id" = "Tourist"."id"
INNER JOIN "Room" ON "Room"."id" = "Residence"."room_id"
INNER JOIN "Hotel" ON "Hotel"."id" = "Room"."hotel_id"
WHERE "Hotel"."id" = @hotel_id;

GRANT SELECT, REFERENCES ON "GetResidenceForHotel" TO "Admin" WITH GRANT OPTION;

-- SELECT * FROM "GetResidenceForHotel"(1);




-- 2
-- Список для розселення по зазначених готелях
-- по зазначеній категорії
-- DROP FUNCTION "GetResidenceForHotelByCategory"
CREATE FUNCTION "GetResidenceForHotelByCategory" (
  @hotel_id INT,
  @category_id INT
) RETURNS TABLE
AS
RETURN SELECT
  "Tourist"."id" AS "tourist_id",
  "Room"."id" AS "room_id",
  "Hotel"."id" AS "hotel_id",
  "Residence"."move_in" AS "move_in",
  "Residence"."move_out" AS "move_out"
FROM "Tourist"
INNER JOIN "Residence" ON "Residence"."tourist_id" = "Tourist"."id"
INNER JOIN "Room" ON "Room"."id" = "Residence"."room_id"
INNER JOIN "Hotel" ON "Hotel"."id" = "Room"."hotel_id"
WHERE "Hotel"."id" = @hotel_id AND "Tourist"."category_id" = @category_id;

GRANT SELECT, REFERENCES ON "GetResidenceForHotelByCategory" TO "Admin" WITH GRANT OPTION;

-- SELECT * FROM "GetResidenceForHotelByCategory"(1, 1);




-- 3
-- Кількість туристів, що побували в країні
-- за певний період
-- в цілому
-- DROP FUNCTION "GetTouristsAmountForPeriod"
CREATE FUNCTION "GetTouristsAmountForPeriod" (
  @start_date DATETIME,
  @end_date DATETIME
) RETURNS INT
AS
BEGIN
  DECLARE @amount INT;
  
  SELECT @amount = COUNT(1)
  FROM "TouristInCountryDates" AS "Dates"
  WHERE
    "Dates"."date_in" BETWEEN @start_date AND @end_date
    OR "Dates"."date_out" BETWEEN @start_date AND @end_date;

  RETURN @amount;
END;

GRANT EXECUTE, REFERENCES ON "GetTouristsAmountForPeriod" TO "Admin" WITH GRANT OPTION;
-- GRANT EXECUTE ON "GetTouristsAmountForPeriod" TO "ExcursionManager";

-- SELECT "dbo"."GetTouristsAmountForPeriod"('2013-09-01T00:00:00', '2013-09-25T00:00:00');




-- 3
-- Кількість туристів, що побували в країні
-- за певний період
-- по певній категорії
-- DROP FUNCTION "GetTouristsAmountForPeriodByCategory"
CREATE FUNCTION "GetTouristsAmountForPeriodByCategory" (
  @start_date DATETIME,
  @end_date DATETIME,
  @category_id INT
) RETURNS INT
AS
BEGIN
  DECLARE @amount INT;
  
  SELECT @amount = COUNT(1)
  FROM "TouristInCountryDates" AS "Dates"
  INNER JOIN "Tourist" ON "Tourist"."id" = "Dates"."tourist_id"
  WHERE
    (
      "Dates"."date_in" BETWEEN @start_date AND @end_date
      OR "Dates"."date_out" BETWEEN @start_date AND @end_date
    )
    AND "Tourist"."category_id" = @category_id;

  RETURN @amount;
END;

GRANT EXECUTE, REFERENCES ON "GetTouristsAmountForPeriodByCategory" TO "Admin" WITH GRANT OPTION;
-- GRANT EXECUTE ON "GetTouristsAmountForPeriodByCategory" TO "ExcursionManager";

-- SELECT "dbo"."GetTouristsAmountForPeriodByCategory"('2013-09-01T00:00:00', '2013-09-25T00:00:00', 2);




-- 4
-- Скільки разів турист був у країні
-- DROP FUNCTION "GetCountryVisitsAmountForHuman"
CREATE FUNCTION "GetCountryVisitsAmountForHuman" (
  @human_id INT
) RETURNS INT
AS
BEGIN
  DECLARE @amount INT;
  
  SELECT 
	@amount = COUNT(1)
  FROM "Tourist"
  WHERE "Tourist"."human_id" = @human_id;
  
  RETURN @amount;
END;

GRANT EXECUTE, REFERENCES ON "GetCountryVisitsAmountForHuman" TO "Admin" WITH GRANT OPTION;
-- GRANT EXECUTE ON "GetCountryVisitsAmountForHuman" TO "ExcursionManager";

-- SELECT "dbo"."GetCountryVisitsAmountForHuman"(1);




-- 4
-- Дати прильоту і відльоту туриста
-- DROP PROCEDURE "GetFlightsDatesListForHuman"
CREATE FUNCTION "GetFlightsDatesListForHuman" (
  @human_id INT
) RETURNS TABLE
AS
RETURN SELECT *
FROM "TouristInCountryDates" AS "Dates"
INNER JOIN "Tourist" ON "Tourist"."id" = "Dates"."tourist_id"
WHERE "Tourist"."human_id" = @human_id;

GRANT SELECT, REFERENCES ON "GetFlightsDatesListForHuman" TO "Admin" WITH GRANT OPTION;
-- GRANT EXECUTE ON "GetFlightsDatesListForHuman" TO "ExcursionManager";

-- SELECT * FROM "GetFlightsDatesListForHuman"(10);




-- 4
-- В яких готелях зупинявся турист
-- DROP FUNCTION "GetHotelsResidenceListForHuman"
CREATE FUNCTION "GetHotelsResidenceListForHuman" (
  @human_id INT
) RETURNS TABLE
AS
RETURN SELECT
  "Tourist"."id" AS "tourist_id",
  "Hotel"."id" AS "hotel_id",
  "Hotel"."name" AS "hotel_name",
  "Room"."id" AS "room_id",
  "Room"."label" AS "room_label",
  "Residence"."id" AS "residence_id",
  "Residence"."move_in" AS "move_in",
  "Residence"."move_out" AS "move_out",
  "Residence"."cost" AS "cost"
FROM "Hotel"
INNER JOIN "Room" ON "Room"."hotel_id" = "Hotel"."id"
INNER JOIN "Residence" ON "Residence"."room_id" = "Room"."id"
INNER JOIN "Tourist" ON "Tourist"."id" = "Residence"."tourist_id"
WHERE "Tourist"."human_id" = @human_id;

GRANT SELECT, REFERENCES ON "GetHotelsResidenceListForHuman" TO "Admin" WITH GRANT OPTION;

-- SELECT * FROM "GetHotelsResidenceListForHuman"(2);




-- 4
-- Які екскурсії і в яких агентствах замовляв турист
-- DROP FUNCTION "GetExcursionListForHuman"
CREATE FUNCTION "GetExcursionListForHuman" (
  @human_id INT
) RETURNS TABLE
AS 
RETURN SELECT 
  "Tourist"."id" AS "tourist_id",
  "Excursion"."id" AS "excursion_id",
  "Excursion"."name" AS "excursion_name",
  "Agency"."id" AS "agency_id",
  "Agency"."name" AS "agency_name",
  "Schedule"."id" AS "schedule_id",
  "Visit"."id" AS "visit_id",
  "Schedule"."date" AS "date",
  "Schedule"."cost" AS "cost"
FROM "Excursion"
INNER JOIN "ExcursionAgency" AS "Agency" ON "Agency"."id" = "Excursion"."agency_id"
INNER JOIN "ExcursionSchedule" AS "Schedule" ON "Schedule"."excursion_id" = "Excursion"."id"
INNER JOIN "ExcursionVisit" AS "Visit" ON "Visit"."excursion_id" = "Schedule"."id"
INNER JOIN "Tourist" ON "Tourist"."id" = "Visit"."tourist_id"
WHERE "Tourist"."human_id" = @human_id;

GRANT SELECT, REFERENCES ON "GetExcursionListForHuman" TO "Admin" WITH GRANT OPTION;
-- GRANT EXECUTE ON "GetExcursionListForHuman" TO "ExcursionManager";

-- SELECT * FROM "GetExcursionListForHuman"(4);




-- 4
-- Який багаж турист здавав
-- DROP FUNCTION "GetBaggageListForHuman"
CREATE FUNCTION "GetBaggageListForHuman" (
  @human_id INT
) RETURNS TABLE
AS
RETURN
SELECT
  "Baggage".*,
  "BT"."flight_id" AS "baggage_flight_id"
FROM "Baggage"
INNER JOIN "Flight" ON "Flight"."id" = "Baggage"."tourist_flight_id"
INNER JOIN "Tourist" ON "Tourist"."id" = "Flight"."tourist_id"
INNER JOIN "BaggageTransportation" AS "BT" ON "BT".baggage_id = "Baggage"."id"
WHERE "Tourist"."human_id" = @human_id;

GRANT SELECT, REFERENCES ON "GetBaggageListForHuman" TO "Admin" WITH GRANT OPTION;

-- SELECT * FROM "GetBaggageListForHuman"(1);




-- 5
-- Список готелів, у яких робиться розселення туристів, 
-- із зазначенням кількості зайнятих номерів
-- за певний період
-- DROP FUNCTION "GetHotelForResidenceByPeriodWithOccupiedRoomsAmount"
CREATE FUNCTION "GetHotelForResidenceByPeriodWithOccupiedRoomsAmount" (
  @start_date DATETIME,
  @end_date DATETIME
) RETURNS TABLE
AS
RETURN
SELECT 
  "Hotel"."id" AS "hotel_id",
  "Hotel"."name" AS "hotel_name",
  COUNT("Residence"."id") AS "occupied_rooms"
FROM "Hotel"
INNER JOIN "Room" ON "Room"."hotel_id" = "Hotel"."id"
INNER JOIN "Residence" ON "Residence"."room_id" = "Room"."id"
WHERE
  "Residence"."move_in" BETWEEN @start_date AND @end_date
GROUP BY "Hotel"."id", "Hotel"."name";

GRANT SELECT, REFERENCES ON "GetHotelForResidenceByPeriodWithOccupiedRoomsAmount" TO "Admin" WITH GRANT OPTION;

-- SELECT * FROM "GetHotelForResidenceByPeriodWithOccupiedRoomsAmount"('2013-09-01T00:00:00.000', '2013-09-21T00:00:00.000');




-- 6
-- Загальна кількість туристів, що замовили екскурсії
-- за певний період
-- DROP FUNCTION "GetTouristsAmountWhoWhentToExcursionsByPeriod"
CREATE FUNCTION "GetTouristsAmountWhoWhentToExcursionsByPeriod" (
  @start_date DATETIME,
  @end_date DATETIME
) RETURNS INT
AS
BEGIN
  DECLARE @amount INT;
  
  SELECT @amount = COUNT(DISTINCT "Visit"."tourist_id")
  FROM "ExcursionVisit" AS "Visit"
  INNER JOIN "ExcursionSchedule" As "Schedule" ON "Schedule"."id" = "Visit"."excursion_id"
  WHERE 
    "Schedule"."date" BETWEEN @start_date AND @end_date;
  
  RETURN @amount;
END;

GRANT EXECUTE, REFERENCES ON "GetTouristsAmountWhoWhentToExcursionsByPeriod" TO "Admin" WITH GRANT OPTION;
-- GRANT EXECUTE ON "GetTouristsAmountWhoWhentToExcursionsByPeriod" TO "ExcursionManager";

-- SELECT "dbo"."GetTouristsAmountWhoWhentToExcursionsByPeriod" ('2013-09-01T00:00:00.000', '2013-09-21T00:00:00.000');




-- 7
-- Вибрати найпопулярніші екскурсії
-- DROP VIEW "MostPopularExcursions"
CREATE VIEW "MostPopularExcursions"
AS
SELECT TOP 10 
  "Excursion".*,
  "Visits"."visits"
FROM "Excursion"
INNER JOIN "ExcursionVisits" AS "Visits" ON "Visits"."excursion_id" = "Excursion"."id"
ORDER BY "Visits"."visits" DESC;

GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON "MostPopularExcursions" TO "Admin" WITH GRANT OPTION;
GRANT SELECT ON "MostPopularExcursions" TO "ExcursionManager";

-- SELECT * FROM "MostPopularExcursions";




-- 7
-- Вибрати найякісніші екскурсійні агентства
-- DROP VIEW "TheBestExcursionAgencies"
CREATE VIEW "TheBestExcursionAgencies"
AS
SELECT TOP 10
  "Agency"."id" AS "agency_id",
  SUM("Visits"."visits") AS "excursions_visits"
FROM "ExcursionAgency" AS "Agency"
INNER JOIN "Excursion" ON "Excursion"."agency_id" = "Agency"."id"
INNER JOIN "ExcursionVisits" AS "Visits" ON "Visits"."excursion_id" = "Excursion"."id"
GROUP BY "Agency"."id"
ORDER BY "excursions_visits" DESC;

GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON "TheBestExcursionAgencies" TO "Admin" WITH GRANT OPTION;
GRANT SELECT ON "TheBestExcursionAgencies" TO "ExcursionManager";

-- SELECT * FROM "TheBestExcursionAgencies";




-- 8
-- Завантаження зазначеного рейсу літака на певну дату:
-- кількість місць, вага багажу, об'ємна вага
-- DROP PROCEDURE "GetFlightStatistic"
CREATE PROCEDURE "GetFlightStatistic"
  @plane_id INT,
  @takeoff DATETIME
AS
BEGIN
  DECLARE @res TABLE (
    "people_amount" INT,
    "baggage_weight" FLOAT,
    "volume_weight" FLOAT
  );
  DECLARE @amount INT;
  DECLARE @baggage_weight FLOAT;
  DECLARE @volume_weight FLOAT;
  
  SELECT 
    @amount = COUNT(1)
  FROM "PlaneSchedule" AS "Schedule"
  INNER JOIN "Flight" ON "Flight"."flight_id" = "Schedule"."id"
  WHERE
    "Schedule"."plane_id" =@plane_id
    AND CAST("Schedule"."takeoff_date" AS DATE) = CAST(@takeoff AS DATE);
  
  SELECT 
    @baggage_weight = SUM("Baggage"."weight"),
    @volume_weight = SUM("Baggage"."space_amount")
  FROM "PlaneSchedule" AS "Schedule"
  INNER JOIN "BaggageTransportation" AS "BaggageTr" ON "BaggageTr"."flight_id" = "Schedule"."id"
  INNER JOIN "Baggage" ON "Baggage"."id" = "BaggageTr"."baggage_id"
  WHERE
    "Schedule"."plane_id" = @plane_id
    AND CAST("Schedule"."takeoff_date" AS DATE) = CAST(@takeoff AS DATE);

  IF (@baggage_weight IS NULL) SET @baggage_weight = 0.0;
  IF (@volume_weight IS NULL) SET @volume_weight = 0.0;
  
  INSERT INTO @res (
    "people_amount", "baggage_weight", "volume_weight"
  ) VALUES (
    @amount, @baggage_weight, @volume_weight
  );
  
  SELECT * FROM @res;
END;

GRANT EXECUTE ON "GetFlightStatistic" TO "Admin" WITH GRANT OPTION;

-- EXECUTE "GetFlightStatistic" @plane_id = 1, @takeoff = '2013-09-01T09:00:00';




-- 9
-- Вантажообіг складу:
-- кількість місць та вага вантажу, зданого за певний період,
-- кількість літаків, що вивозили цей вантаж,
-- скільки з них вантажних, а скільки вантажопасажирських
-- DROP PROCEDURE "GetStorageStatistics"
CREATE PROCEDURE "GetStorageStatistics"
  @start_date DATETIME,
  @end_date DATETIME
AS
BEGIN
  DECLARE @res TABLE (
    "volume" FLOAT,
    "weight" FLOAT,
    "planes" INT,
    "cargo_planes" INT,
    "regular_planes" INT
  );
  DECLARE @volume FLOAT;
  DECLARE @weight FLOAT;
  DECLARE @planes INT;
  DECLARE @cargo_planes INT;
  DECLARE @regular_planes INT;
  
  SELECT
    @volume = SUM("Baggage"."space_amount"),
    @weight = SUM("Baggage"."weight")
  FROM "Baggage"
  WHERE "Baggage"."date_storage_in" BETWEEN @start_date AND @end_date;

  SELECT
    "Schedule"."id" AS "schedule_id",
    "Plane"."id" AS "plane_id",
    "Plane"."type_id" AS "type_id",
    "BaggageTr"."id" AS "transportation_id"
  INTO #Transport
  FROM "PlaneSchedule" AS "Schedule"
  INNER JOIN "Plane" ON "Plane"."id" = "Schedule"."plane_id"
  INNER JOIN "BaggageTransportation" AS "BaggageTr" ON "BaggageTr"."flight_id" = "Schedule"."id"
  INNER JOIN "Baggage" ON "Baggage"."id" = "BaggageTr"."baggage_id"
  WHERE "Baggage"."date_storage_in" BETWEEN @start_date AND @end_date;
  
  SELECT
    @planes = COUNT(DISTINCT #Transport."schedule_id")
  FROM #Transport;
  
  SELECT
    @cargo_planes = COUNT(DISTINCT #Transport."schedule_id")
  FROM #Transport
  WHERE #Transport."type_id" = 1;
    
  SELECT
    @regular_planes = COUNT(DISTINCT #Transport."schedule_id")
  FROM #Transport
  WHERE #Transport."type_id" = 2;
  
  INSERT INTO @res (
    "volume", "weight", "planes", "cargo_planes", "regular_planes"
  ) VALUES (
    @volume, @weight, @planes, @cargo_planes, @regular_planes
  );
  
  SELECT * FROM @res;
END;

GRANT EXECUTE ON "GetStorageStatistics" TO "Admin" WITH GRANT OPTION;

-- EXECUTE "GetStorageStatistics" @start_date = '2013-09-01T00:00:00', @end_date = '2013-09-30T00:00:00';




-- 10
-- Повний фінансовий звіт по зазначеній групі
-- в цілому
-- DROP PROCEDURE "FinancialReportByGroup"
CREATE PROCEDURE "FinancialReportByGroup"
  @group_id INT
AS
BEGIN
  DECLARE @res TABLE (
    "visa" MONEY,
    "excursions" MONEY,
    "planes" MONEY,
    "residence" MONEY,
    "additional" MONEY,
    "income" MONEY
  );
  DECLARE @visa MONEY;
  DECLARE @excursions MONEY;
  DECLARE @planes MONEY;
  DECLARE @baggage MONEY;
  DECLARE @residence MONEY;
  DECLARE @additional MONEY;
  DECLARE @income MONEY;
  
  SELECT *
  INTO #Tourists
  FROM "Tourist"
  WHERE "Tourist"."group_id" = @group_id;
  
  SELECT
    @visa = SUM("Visa"."cost"),
    @income = SUM(#Tourists."paid_for_tour")
  FROM #Tourists
  INNER JOIN "Visa" ON "Visa"."tourist_id" = #Tourists."id";
  
  SELECT
    @additional = SUM("Spending"."cost")
  FROM #Tourists
  INNER JOIN "Spending" ON "Spending"."tourist_id" = #Tourists."id";
  
  SELECT
    @excursions = SUM("Schedule"."cost")
  FROM #Tourists
  INNER JOIN "ExcursionVisit" AS "Visit" ON "Visit"."tourist_id" = #Tourists."id"
  INNER JOIN "ExcursionSchedule" AS "Schedule" ON "Schedule"."id" = "Visit"."excursion_id";
  
  SELECT
    @residence = SUM( DATEDIFF(day, "Residence"."move_in", "Residence"."move_out") * "Residence"."cost" )
  FROM #Tourists
  INNER JOIN "Residence" ON "Residence"."tourist_id" = #Tourists."id";
  
  SELECT
    @planes = SUM( "Schedule"."loading_cost" + "Schedule"."unloading_cost" + 
                   "Schedule"."takeoff_cost" + "Schedule"."landing_cost" + 
                   "Schedule"."dispetcher_cost" )
  FROM #Tourists
  INNER JOIN "Flight" ON "Flight"."tourist_id" = #Tourists."id"
  INNER JOIN "PlaneSchedule" AS "Schedule" ON "Schedule"."id" = "Flight"."flight_id"
  GROUP BY "Schedule"."id";
  
  SELECT
    @baggage = SUM( "Baggage"."packing_cost" + "Baggage"."insurance_cost" + 
                    DATEDIFF(day, "Baggage"."date_storage_in", "Baggage"."date_storage_out") * "Baggage"."keep_cost" )
  FROM #Tourists
  INNER JOIN "Flight" ON "Flight"."tourist_id" = #Tourists."id"
  INNER JOIN "Baggage" ON "Baggage"."tourist_flight_id" = "Flight"."id";
  
  INSERT INTO @res (
    "visa", "excursions", "planes", "residence", "additional", "income"   
  ) VALUES (
    @visa, @excursions, @planes + @baggage, @residence, @additional, @income
  );
  
  SELECT * FROM @res;
END;

GRANT EXECUTE ON "FinancialReportByGroup" TO "Admin" WITH GRANT OPTION;

-- EXECUTE "FinancialReportByGroup" @group_id=2;




-- 10
-- Повний фінансовий звіт по зазначеній групі
-- для певної категорії
-- DROP PROCEDURE "FinancialReportByGroupAndCategory"
CREATE PROCEDURE "FinancialReportByGroupAndCategory"
  @group_id INT,
  @category_id INT
AS
BEGIN
  DECLARE @res TABLE (
    "visa" MONEY,
    "excursions" MONEY,
    "planes" MONEY,
    "residence" MONEY,
    "additional" MONEY,
    "income" MONEY
  );
  DECLARE @visa MONEY;
  DECLARE @excursions MONEY;
  DECLARE @planes MONEY;
  DECLARE @baggage MONEY;
  DECLARE @residence MONEY;
  DECLARE @additional MONEY;
  DECLARE @income MONEY;
  
  SELECT *
  INTO #Tourists
  FROM "Tourist"
  WHERE "Tourist"."group_id" = @group_id
    AND "Tourist"."category_id" = @category_id;
  
  SELECT
    @visa = SUM("Visa"."cost"),
    @income = SUM(#Tourists."paid_for_tour")
  FROM #Tourists
  INNER JOIN "Visa" ON "Visa"."tourist_id" = #Tourists."id";
  
  SELECT
    @additional = SUM("Spending"."cost")
  FROM #Tourists
  INNER JOIN "Spending" ON "Spending"."tourist_id" = #Tourists."id";
  
  SELECT
    @excursions = SUM("Schedule"."cost")
  FROM #Tourists
  INNER JOIN "ExcursionVisit" AS "Visit" ON "Visit"."tourist_id" = #Tourists."id"
  INNER JOIN "ExcursionSchedule" AS "Schedule" ON "Schedule"."id" = "Visit"."excursion_id";
  
  SELECT
    @residence = SUM( DATEDIFF(day, "Residence"."move_in", "Residence"."move_out") * "Residence"."cost" )
  FROM #Tourists
  INNER JOIN "Residence" ON "Residence"."tourist_id" = #Tourists."id";
  
  SELECT
    @planes = SUM( "Schedule"."loading_cost" + "Schedule"."unloading_cost" + 
                   "Schedule"."takeoff_cost" + "Schedule"."landing_cost" + 
                   "Schedule"."dispetcher_cost" )
  FROM #Tourists
  INNER JOIN "Flight" ON "Flight"."tourist_id" = #Tourists."id"
  INNER JOIN "PlaneSchedule" AS "Schedule" ON "Schedule"."id" = "Flight"."flight_id"
  GROUP BY "Schedule"."id";
  
  SELECT
    @baggage = SUM( "Baggage"."packing_cost" + "Baggage"."insurance_cost" + 
                    DATEDIFF(day, "Baggage"."date_storage_in", "Baggage"."date_storage_out") * "Baggage"."keep_cost" )
  FROM #Tourists
  INNER JOIN "Flight" ON "Flight"."tourist_id" = #Tourists."id"
  INNER JOIN "Baggage" ON "Baggage"."tourist_flight_id" = "Flight"."id";
  
  INSERT INTO @res (
    "visa", "excursions", "planes", "residence", "additional", "income"   
  ) VALUES (
    @visa, @excursions, @planes + @baggage, @residence, @additional, @income
  );
  
  SELECT * FROM @res;
END;

GRANT EXECUTE ON "FinancialReportByGroupAndCategory" TO "Admin" WITH GRANT OPTION;

-- EXECUTE "FinancialReportByGroupAndCategory" @group_id = 1, @category_id = 1




-- 11
-- Дані про витрати і доходи за певний період:
-- Доходи
-- DROP FUNCTION "DebetCreditByPeriodIncome"
CREATE FUNCTION "DebetCreditByPeriodIncome" (
  @start_date DATETIME,
  @end_date DATETIME
) RETURNS MONEY
AS
BEGIN
  DECLARE @income MONEY;

  SELECT 
    @income = SUM( "Tourist"."paid_for_tour" )
  FROM "TouristInCountryDates" AS "Dates"
  INNER JOIN "Tourist" ON "Tourist"."id" = "Dates"."tourist_id"
  WHERE "Dates"."date_in" BETWEEN @start_date AND @end_date;

  IF (@income IS NULL) SET @income = 0;

  RETURN @income;
END;

GRANT EXECUTE, REFERENCES ON "DebetCreditByPeriodIncome" TO "Admin" WITH GRANT OPTION;

-- SELECT "dbo"."DebetCreditByPeriodIncome"('2013-09-01T00:00:00', '2013-09-30T00:00:00');




-- 11
-- Дані про витрати і доходи за певний період:
-- Обслуговування літака
-- DROP FUNCTION "DebetCreditByPeriodPlanes"
CREATE FUNCTION "DebetCreditByPeriodPlanes" (
  @start_date DATETIME,
  @end_date DATETIME
) RETURNS MONEY
AS
BEGIN
  DECLARE @planes MONEY;

  SELECT
    @planes = SUM( "Schedule"."loading_cost" + "Schedule"."unloading_cost" + 
                   "Schedule"."takeoff_cost" + "Schedule"."landing_cost" )
  FROM "PlaneSchedule" AS "Schedule"
  WHERE "Schedule"."takeoff_date" BETWEEN @start_date AND @end_date;

  IF (@planes IS NULL) SET @planes = 0;

  RETURN @planes;
END;

GRANT EXECUTE, REFERENCES ON "DebetCreditByPeriodPlanes" TO "Admin" WITH GRANT OPTION;

-- SELECT "dbo"."DebetCreditByPeriodPlanes"('2013-09-01T00:00:00', '2013-09-30T00:00:00');




-- 11
-- Дані про витрати і доходи за певний період:
-- Готель
-- DROP FUNCTION "DebetCreditByPeriodHotels"
CREATE FUNCTION "DebetCreditByPeriodHotels" (
  @start_date DATETIME,
  @end_date DATETIME
) RETURNS MONEY  
AS
BEGIN
  DECLARE @h_o MONEY;
  DECLARE @h_i MONEY;
  DECLARE @h_l MONEY;
  DECLARE @h_g MONEY;

  SELECT
    @h_i = SUM( DATEDIFF(day, "Residence"."move_in", "Residence"."move_out") * "Residence"."cost" )
  FROM "Residence"
  WHERE 
    ("Residence"."move_in" BETWEEN @start_date AND @end_date)
    AND
    ("Residence"."move_out" BETWEEN @start_date AND @end_date);

  SELECT
    @h_o = SUM( DATEDIFF(day, @start_date, @end_date) * "Residence"."cost" )
  FROM "Residence"
  WHERE 
    "Residence"."move_in" < @start_date
    AND
    "Residence"."move_out" > @end_date;
  
  SELECT
    @h_l = SUM( DATEDIFF(day, @start_date, "Residence"."move_out") * "Residence"."cost" )
  FROM "Residence"
  WHERE 
    "Residence"."move_in" < @start_date
    AND
    ("Residence"."move_out" BETWEEN @start_date AND @end_date);
  
  SELECT
    @h_g = SUM( DATEDIFF(day, "Residence"."move_in", @end_date) * "Residence"."cost" )
  FROM "Residence"
  WHERE 
    "Residence"."move_out" > @end_date
    AND
    ("Residence"."move_in" BETWEEN @start_date AND @end_date);

  IF (@h_l IS NULL) SET @h_l = 0;
  IF (@h_g IS NULL) SET @h_g = 0;
  IF (@h_i IS NULL) SET @h_i = 0;
  IF (@h_o IS NULL) SET @h_o = 0;

  RETURN @h_l + @h_g + @h_o + @h_i;
END;

GRANT EXECUTE, REFERENCES ON "DebetCreditByPeriodHotels" TO "Admin" WITH GRANT OPTION;

-- SELECT "dbo"."DebetCreditByPeriodHotels"('2013-09-01T00:00:00', '2013-09-30T00:00:00');




-- 11
-- Дані про витрати і доходи за певний період:
-- Екскурсії
-- DROP FUNCTION "DebetCreditByPeriodExcursions"
CREATE FUNCTION "DebetCreditByPeriodExcursions" (
  @start_date DATETIME,
  @end_date DATETIME
) RETURNS MONEY
AS
BEGIN
  DECLARE @excursions MONEY;

  SELECT
    @excursions = SUM( "Schedule"."cost" )
  FROM "ExcursionVisit" AS "Visit"
  INNER JOIN "ExcursionSchedule" AS "Schedule" ON "Schedule"."id" = "Visit"."excursion_id"
  WHERE "Schedule"."date" BETWEEN @start_date AND @end_date;

  IF (@excursions IS NULL) SET @excursions = 0;

  RETURN @excursions;
END;

GRANT EXECUTE, REFERENCES ON "DebetCreditByPeriodExcursions" TO "Admin" WITH GRANT OPTION;

-- SELECT "dbo"."DebetCreditByPeriodExcursions"('2013-09-01T00:00:00', '2013-09-30T00:00:00');




-- 11
-- Дані про витрати і доходи за певний період:
-- Візи
-- DROP FUNCTION "DebetCreditByPeriodVisas"
CREATE FUNCTION "DebetCreditByPeriodVisas" (
  @start_date DATETIME,
  @end_date DATETIME
) RETURNS MONEY
AS
BEGIN
  DECLARE @visas MONEY;

  SELECT
    @visas = SUM( "Visa"."cost" )
  FROM "Visa"
  WHERE "Visa"."date_given" BETWEEN @start_date AND @end_date;

  IF (@visas IS NULL) SET @visas = 0;

  RETURN @visas;
END;

GRANT EXECUTE, REFERENCES ON "DebetCreditByPeriodVisas" TO "Admin" WITH GRANT OPTION;

-- SELECT "dbo"."DebetCreditByPeriodVisas"('2013-09-01T00:00:00', '2013-09-30T00:00:00');




-- 11
-- Дані про витрати і доходи за певний період:
-- Витрати представництва
-- DROP FUNCTION "DebetCreditByPeriodSpendings"
CREATE FUNCTION "DebetCreditByPeriodSpendings" (
  @start_date DATETIME,
  @end_date DATETIME
) RETURNS MONEY
AS
BEGIN
  DECLARE @spendings MONEY;

  SELECT
    @spendings = SUM( "Spending"."cost" )
  FROM "Spending"
  WHERE "Spending"."date" BETWEEN @start_date AND @end_date;

  IF (@spendings IS NULL) SET @spendings = 0;

  RETURN @spendings;
END;

GRANT EXECUTE, REFERENCES ON "DebetCreditByPeriodSpendings" TO "Admin" WITH GRANT OPTION;

-- SELECT "dbo"."DebetCreditByPeriodSpendings"('2013-09-01T00:00:00', '2013-09-30T00:00:00');




-- 12
-- Отримати статистику по видах багажу, що відправляється 
-- і питому частку кожного виду в загальному вантажопотоці
-- drop procedure GetBaggageTypeStatistics
CREATE PROCEDURE "GetBaggageTypeStatistics"
  @start_date DATETIME,
  @end_date DATETIME
AS
BEGIN
  DECLARE @total_weight FLOAT;
  DECLARE @total_volume FLOAT;
  
  SELECT
    @total_weight = SUM("Baggage"."weight"),
    @total_volume = SUM("Baggage"."space_amount")
  FROM "Baggage"
  INNER JOIN "BaggageTransportation" AS "Transportation" ON "Transportation"."baggage_id" = "Baggage"."id"
  INNER JOIN "PlaneSchedule" AS "Schedule" ON "Schedule"."id" = "Transportation"."flight_id"
  WHERE "Schedule"."takeoff_date" BETWEEN @start_date AND @end_date;
  
  SELECT
    "Baggage"."type_id",
	"BaggageType".name AS "type_name",
    SUM("Baggage"."weight") AS "type_weight",
    SUM("Baggage"."space_amount") AS "type_volume",
	  @total_weight AS "total_weight",
    @total_volume AS "total_volume",
    SUM("Baggage"."weight") / @total_weight * 100.0 AS "type_total_weight_part",
    SUM("Baggage"."space_amount") / @total_volume * 100.0 AS "type_total_volume_part"
  FROM "Baggage"
  INNER JOIN "BaggageTransportation" AS "Transportation" ON "Transportation"."baggage_id" = "Baggage"."id"
  INNER JOIN "PlaneSchedule" AS "Schedule" ON "Schedule"."id" = "Transportation"."flight_id"
  INNER JOIN "BaggageType" ON "BaggageType"."id" = "Baggage"."type_id"
  WHERE "Schedule"."takeoff_date" BETWEEN @start_date AND @end_date
  GROUP BY "Baggage"."type_id", "BaggageType"."name";
END;

GRANT EXECUTE ON "GetBaggageTypeStatistics" TO "Admin" WITH GRANT OPTION;

-- EXECUTE "GetBaggageTypeStatistics" @start_date = '2013-09-01T00:00:00', @end_date = '2013-09-30T00:00:00';




-- 13
-- Рентабельність представництва (співвідношення доходів та витрат)
-- DROP FUNCTION "RentabilityByPeriod"
CREATE FUNCTION "RentabilityByPeriod" (
  @start_date DATETIME,
  @end_date DATETIME
) RETURNS FLOAT
AS
BEGIN
  DECLARE @income MONEY;
  DECLARE @planes MONEY;
  DECLARE @hotels MONEY;
  DECLARE @excursions MONEY;
  DECLARE @visas MONEY;
  DECLARE @spendings MONEY;

  SELECT @income = dbo."DebetCreditByPeriodIncome"(@start_date, @end_date);
  SELECT @planes = dbo."DebetCreditByPeriodPlanes"(@start_date, @end_date);
  SELECT @hotels = dbo."DebetCreditByPeriodHotels"(@start_date, @end_date);
  SELECT @excursions = dbo."DebetCreditByPeriodExcursions"(@start_date, @end_date);
  SELECT @visas = dbo."DebetCreditByPeriodVisas"(@start_date, @end_date);
  SELECT @spendings = dbo."DebetCreditByPeriodSpendings"(@start_date, @end_date);

  DECLARE @outcome_money MONEY;
  SET @outcome_money = @hotels + @excursions + @visas + @spendings;

  RETURN CAST(@income AS FLOAT) / CAST(@outcome_money AS FLOAT);
END;

GRANT EXECUTE, REFERENCES ON "RentabilityByPeriod" TO "Admin" WITH GRANT OPTION;

-- SELECT "dbo"."RentabilityByPeriod"('2013-09-01T00:00:00', '2013-09-30T00:00:00');




-- 14
-- Процентне відношення відпочиваючих туристів до туристів shop-турів
-- в цілому
-- DROP FUNCTION "GetRatioBetweenRestAndShop"
CREATE FUNCTION "GetRatioBetweenRestAndShop" (
) RETURNS FLOAT
AS 
BEGIN
  DECLARE @rest INT;
  DECLARE @shop INT;
  
  SELECT
    @rest = COUNT(1)
  FROM "Tourist"
  WHERE "Tourist"."category_id" = 1;
  
  SELECT
    @shop = COUNT(1)
  FROM "Tourist"
  WHERE "Tourist"."category_id" = 2;

  IF (@shop = 0) SET @shop = 1;
  
  RETURN CAST(@rest AS FLOAT) / CAST(@shop AS FLOAT) * 100.0;
END;

GRANT EXECUTE, REFERENCES ON "GetRatioBetweenRestAndShop" TO "Admin" WITH GRANT OPTION;

-- SELECT "dbo"."GetRatioBetweenRestAndShop"();




-- 14
-- Процентне відношення відпочиваючих туристів до туристів shop-турів
-- за вказаний період
-- DROP FUNCTION "GetRatioBetweenRestAndShopByPeriod";
CREATE FUNCTION "GetRatioBetweenRestAndShopByPeriod" (
  @start_date DATETIME,
  @end_date DATETIME
) RETURNS FLOAT
AS 
BEGIN
  DECLARE @rest INT;
  DECLARE @shop INT;
  
  SELECT
    @rest = COUNT(1)
  FROM "Tourist"
  INNER JOIN "TouristInCountryDates" AS "Dates" ON "Dates"."tourist_id" = "Tourist"."id"
  WHERE "Dates"."date_in" BETWEEN @start_date AND @end_date
    AND "Tourist"."category_id" = 1;
  
  SELECT
    @shop = COUNT(1)
  FROM "Tourist"
  INNER JOIN "TouristInCountryDates" AS "Dates" ON "Dates"."tourist_id" = "Tourist"."id"
  WHERE "Dates"."date_in" BETWEEN @start_date AND @end_date
    AND "Tourist"."category_id" = 2;

  IF (@shop = 0) SET @shop = 1;

  RETURN CAST(@rest AS FLOAT) / CAST(@shop AS FLOAT) * 100.0;
END;

GRANT EXECUTE, REFERENCES ON "GetRatioBetweenRestAndShopByPeriod" TO "Admin" WITH GRANT OPTION;

-- SELECT "dbo"."GetRatioBetweenRestAndShopByPeriod"('2013-09-01T00:00:00', '2013-09-21T00:00:00');




-- 15
-- Відомості про туристів зазначеного рейсу:
-- Список груп
-- DROP FUNCTION "GetGroupsByFlight"
CREATE FUNCTION "GetGroupsByFlight" (
  @flight_id INT
) RETURNS TABLE
AS
RETURN
SELECT DISTINCT "Tourist"."group_id"
FROM "PlaneSchedule" AS "Schedule"
INNER JOIN "Flight" ON "Flight"."flight_id" = "Schedule"."id"
INNER JOIN "Tourist" ON "Tourist"."id" = "Flight"."tourist_id"
WHERE "Schedule"."id" = @flight_id;

GRANT SELECT, REFERENCES ON "GetGroupsByFlight" TO "Admin" WITH GRANT OPTION;
-- GRANT EXECUTE ON "GetGroupsByFlight" TO "ExcursionManager";

-- SELECT * FROM "GetGroupsByFlight"(1);




-- 15
-- Відомості про туристів зазначеного рейсу:
-- Готелі
-- DROP FUNCTION "GetHotelsByFlight"
CREATE FUNCTION "GetHotelsByFlight" (
  @flight_id INT
) RETURNS TABLE
AS
RETURN
SELECT DISTINCT "Room"."hotel_id"
FROM "PlaneSchedule" AS "Schedule"
INNER JOIN "Flight" ON "Flight"."flight_id" = "Schedule"."id"
INNER JOIN "Tourist" ON "Tourist"."id" = "Flight"."tourist_id"
INNER JOIN "Residence" ON "Residence"."tourist_id" = "Tourist"."id"
INNER JOIN "Room" ON "Room"."id" = "Residence"."room_id"
WHERE "Schedule"."id" = @flight_id;

GRANT SELECT, REFERENCES ON "GetHotelsByFlight" TO "Admin" WITH GRANT OPTION;

-- SELECT * FROM "GetHotelsByFlight"(1);




-- 15
-- Відомості про туристів зазначеного рейсу:
-- Вантаж
-- DROP FUNCTION "GetBaggageByFlight"
CREATE FUNCTION "GetBaggageByFlight" (
  @flight_id INT
) RETURNS TABLE
AS
RETURN
SELECT "Baggage".*
FROM "PlaneSchedule" AS "Schedule"
INNER JOIN "Flight" ON "Flight"."flight_id" = "Schedule"."id"
INNER JOIN "Baggage" ON "Baggage"."tourist_flight_id" = "Flight"."id"
WHERE "Schedule"."id" = @flight_id;

GRANT SELECT, REFERENCES ON "GetBaggageByFlight" TO "Admin" WITH GRANT OPTION;

-- SELECT * FROM "GetBaggageByFlight"(1);