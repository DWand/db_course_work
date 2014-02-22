USE "master";


DROP DATABASE "sp110_15_db_2013";
CREATE DATABASE "sp110_15_db_2013";


USE "sp110_15_db_2013";


CREATE ROLE "Admin";
CREATE LOGIN "admin" WITH PASSWORD = 'password2014!';
CREATE USER "adminUser" FOR LOGIN "admin";
ALTER ROLE "Admin" ADD MEMBER "adminUser";

CREATE ROLE "ExcursionManager";
CREATE LOGIN "excursionManager" WITH PASSWORD = 'password2014!!';
CREATE USER "excursionManagerUser" FOR LOGIN "excursionManager";
ALTER ROLE "ExcursionManager" ADD MEMBER "excursionManagerUser";

CREATE ROLE "Web";
CREATE LOGIN "web" WITH PASSWORD = 'password2014!!!';
CREATE USER "webUser" FOR LOGIN "web";
ALTER ROLE "Web" ADD MEMBER "webUser";




-- Таблица Пол человека
CREATE TABLE "Sex" (
  "id" TINYINT NOT NULL IDENTITY PRIMARY KEY
, "name" VARCHAR(10) NOT NULL                               -- название пола
);

GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON "Sex" TO "Admin" WITH GRANT OPTION;
-- GRANT SELECT ON "Sex" TO "ExcursionManager";




-- Таблица Люди
CREATE TABLE "Human" (
  "id" INT NOT NULL IDENTITY PRIMARY KEY
, "name" VARCHAR(45) NOT NULL                               -- имя
, "surname" VARCHAR(45) NOT NULL                            -- фамилия
, "patronymic" VARCHAR(45) NOT NULL                         -- отчество
, "passport" VARCHAR(20)                                    -- номер паспорта
, "sex_id" TINYINT NOT NULL                                 -- пол
, "birthday" DATETIME NOT NULL                              -- дата рождения
  
, CONSTRAINT "fk_human_sex" 
    FOREIGN KEY ("sex_id")
    REFERENCES "Sex"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);

GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON "Human" TO "Admin" WITH GRANT OPTION;
-- GRANT SELECT ON "Human" TO "ExcursionManager";




-- Таблица Категории туристов
CREATE TABLE "TouristCategory" (
  "id" TINYINT NOT NULL IDENTITY PRIMARY KEY
, "name" VARCHAR(30) NOT NULL                               -- Название категории туристов
);

GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON "TouristCategory" TO "Admin" WITH GRANT OPTION;
-- GRANT SELECT ON "TouristCategory" TO "ExcursionManager";




-- Таблица Группы туристов
CREATE TABLE "TouristGroup" (
  "id" INT NOT NULL IDENTITY PRIMARY KEY
, "label" VARCHAR(30) NOT NULL                              -- Код группы туристов
);

GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON "TouristGroup" TO "Admin" WITH GRANT OPTION;
-- GRANT SELECT ON "TouristGroup" TO "ExcursionManager";




-- Таблица Туристы
CREATE TABLE "Tourist" (
  "id" INT NOT NULL IDENTITY PRIMARY KEY
, "human_id" INT NOT NULL                                   -- Идентификатор человека
, "category_id" TINYINT NOT NULL                            -- Идентификатор категории туриста
, "group_id" INT NOT NULL                                   -- Идентификатор группы туриста
, "paid_for_tour" MONEY NOT NULL                            -- Сумма, которую турист заплатил за путевку
  
, CONSTRAINT "fk_tourist_human" 
    FOREIGN KEY ("human_id")
    REFERENCES "Human"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
                                
, CONSTRAINT "fk_tourist_category"
    FOREIGN KEY ("category_id")
    REFERENCES "TouristCategory"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    
, CONSTRAINT "fk_tourist_group"
    FOREIGN KEY ("group_id")
    REFERENCES "TouristGroup"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);

GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON "Tourist" TO "Admin" WITH GRANT OPTION;
-- GRANT SELECT ON "Tourist" TO "ExcursionManager";




-- Таблица Визы
CREATE TABLE "Visa" (
  "id" INT NOT NULL IDENTITY PRIMARY KEY
, "tourist_id" INT NOT NULL                                 -- Идентификатор туриста, которому дана виза
, "date_given" DATETIME NOT NULL                            -- Дата выдачи визы
, "date_expires" DATETIME NOT NULL                          -- Дата истечения визы
, "cost" MONEY NOT NULL                                     -- Стоимость оформления визы

, CONSTRAINT "fk_visa_tourist"
    FOREIGN KEY ("tourist_id")
    REFERENCES "Tourist"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);

GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON "Visa" TO "Admin" WITH GRANT OPTION;



-- Таблица Родственные связи
CREATE TABLE "Parent" (
  "id" INT NOT NULL IDENTITY PRIMARY KEY
, "parent_id" INT NOT NULL                                  -- Идентификатор родителя туриста
, "child_id" INT NOT NULL                                   -- Идентификатор ребенка туриста

, CONSTRAINT "check_parents_not_childs"
	CHECK ("parent_id" <> "child_id")
  
, CONSTRAINT "unique_parent_child_pair"
  UNIQUE NONCLUSTERED (
    "parent_id", "child_id"
  )

, CONSTRAINT "fk_parent_parent_tourist"
    FOREIGN KEY ("parent_id")
    REFERENCES "Tourist"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    
, CONSTRAINT "fk_parent_child_tourist"
    FOREIGN KEY ("child_id")
    REFERENCES "Tourist"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);

GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON "Parent" TO "Admin" WITH GRANT OPTION;
-- GRANT SELECT ON "Parent" TO "ExcursionManager";




-- Таблица Типы расходов
CREATE TABLE "SpendingType" (
  "id" SMALLINT NOT NULL PRIMARY KEY IDENTITY
, "name" VARCHAR(30) NOT NULL                               -- Название типа расходов
);

GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON "SpendingType" TO "Admin" WITH GRANT OPTION;
-- GRANT SELECT ON "SpendingType" TO "ExcursionManager";




-- Таблица Расходы на туриста
CREATE TABLE "Spending" (
  "id" INT NOT NULL IDENTITY PRIMARY KEY
, "tourist_id" INT NOT NULL                                 -- Идентификатор туриста, на которого были потрачены деньги
, "type_id" SMALLINT NOT NULL                               -- Идентификатор типа расходов
, "cost" MONEY NOT NULL                                     -- Потраченая сумма
, "date" DATETIME NOT NULL                                  -- Дата, когда деньги были потрачены
, "description" VARCHAR(50) NOT NULL                        -- Краткое описание расходов

, CONSTRAINT "fk_spending_tourist"
    FOREIGN KEY ("tourist_id")
    REFERENCES "Tourist"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    
, CONSTRAINT "fk_spending_type"
    FOREIGN KEY ("type_id")
    REFERENCES "SpendingType"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);

GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON "Spending" TO "Admin" WITH GRANT OPTION;
-- GRANT SELECT, INSERT, UPDATE, DELETE ON "Spending" TO "ExcursionManager";




-- Таблица Агентство экскурсий
CREATE TABLE "ExcursionAgency" (
  "id" SMALLINT NOT NULL IDENTITY PRIMARY KEY
, "name" VARCHAR(50) NOT NULL                               -- Название агенства экскурсий
);

GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON "ExcursionAgency" TO "Admin" WITH GRANT OPTION;
GRANT SELECT, INSERT, UPDATE, DELETE ON "ExcursionAgency" TO "ExcursionManager";
GRANT SELECT ON "ExcursionAgency" TO "Web";




-- Таблица Экскурсии
CREATE TABLE "Excursion" (
  "id" INT NOT NULL IDENTITY PRIMARY KEY
, "agency_id" SMALLINT NOT NULL                             -- Идентификатор агенства, которое организовывает экскурсию
, "name" VARCHAR(50) NOT NULL                               -- Название экскурсии
, "description" VARCHAR(300) NULL                           -- Краткое описание экскурсии

, CONSTRAINT "fk_excursion_agency"
    FOREIGN KEY ("agency_id")
    REFERENCES "ExcursionAgency"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);

GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON "Excursion" TO "Admin" WITH GRANT OPTION;
GRANT SELECT, INSERT, UPDATE, DELETE ON "Excursion" TO "ExcursionManager";
GRANT SELECT ON "Excursion" TO "Web";




-- Таблица Расписание экскурсий
CREATE TABLE "ExcursionSchedule" (
  "id" INT NOT NULL IDENTITY PRIMARY KEY
, "excursion_id" INT NOT NULL                               -- Идентификатор экскурсии
, "date" DATETIME NOT NULL                                  -- Дата проведения экскурсии
, "cost" MONEY NOT NULL                                     -- Стоимость экскурсии

, CONSTRAINT "fk_excursionschedule_excursion"
    FOREIGN KEY ("excursion_id")
    REFERENCES "Excursion"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);

GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON "ExcursionSchedule" TO "Admin" WITH GRANT OPTION;
GRANT SELECT, INSERT, UPDATE, DELETE ON "ExcursionSchedule" TO "ExcursionManager";
GRANT SELECT ON "ExcursionSchedule" TO "Web";




-- Таблица Посещение экскурсий
CREATE TABLE "ExcursionVisit" (
  "id" INT NOT NULL IDENTITY PRIMARY KEY
, "tourist_id" INT NOT NULL                                 -- Идентификатор туриста
, "excursion_id" INT NOT NULL                               -- Идентификатор экскурсии (в расписании)

, CONSTRAINT "fk_excursionvisit_tourist"
    FOREIGN KEY ("tourist_id")
    REFERENCES "Tourist"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    
, CONSTRAINT "fk_excursionvisit_excursionschedule"
    FOREIGN KEY ("excursion_id")
    REFERENCES "ExcursionSchedule"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);

GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON "ExcursionVisit" TO "Admin" WITH GRANT OPTION;
GRANT SELECT, INSERT, UPDATE, DELETE ON "ExcursionVisit" TO "ExcursionManager";




-- Таблица Город
CREATE TABLE "City" (
  "id" SMALLINT NOT NULL IDENTITY PRIMARY KEY
, "name" VARCHAR(45) NOT NULL                               -- Название города
);

GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON "City" TO "Admin" WITH GRANT OPTION;




-- Таблица Отелей
CREATE TABLE "Hotel" (
  "id" INT NOT NULL IDENTITY PRIMARY KEY
, "name" VARCHAR(50) NOT NULL                               -- Название отеля
, "city_id" SMALLINT NOT NULL                               -- Название города

, CONSTRAINT "fk_hotel_city"
    FOREIGN KEY ("city_id")
    REFERENCES "City"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);

GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON "Hotel" TO "Admin" WITH GRANT OPTION;




-- Таблица Номеров отелей
CREATE TABLE "Room" (
  "id" INT NOT NULL IDENTITY PRIMARY KEY
, "hotel_id" INT NOT NULL                                   -- Идентификатор отеля
, "label" VARCHAR(30)                                       -- Код номера

, CONSTRAINT "fk_room_hotel"
    FOREIGN KEY ("hotel_id")
    REFERENCES "Hotel"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);

GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON "Room" TO "Admin" WITH GRANT OPTION;




-- Таблица Проживание
CREATE TABLE "Residence" (
  "id" INT NOT NULL IDENTITY PRIMARY KEY
, "tourist_id" INT NOT NULL                                 -- Идентификатор туриста
, "room_id" INT NOT NULL                                    -- Идентификатор номера
, "move_in" DATETIME NOT NULL                               -- Дата вселения в номер
, "move_out" DATETIME NOT NULL                              -- Дата выселения из номера
, "cost" MONEY NOT NULL                                     -- Стоимость проживания за сутки  

, CONSTRAINT "fk_residence_tourist"
    FOREIGN KEY ("tourist_id")
    REFERENCES "Tourist"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    
, CONSTRAINT "fk_residence_room"
    FOREIGN KEY ("room_id")
    REFERENCES "Room"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);

GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON "Residence" TO "Admin" WITH GRANT OPTION;




-- Таблица Типы самолета
CREATE TABLE "PlaneType" (
  "id" TINYINT NOT NULL IDENTITY PRIMARY KEY
, "name" VARCHAR(30) NOT NULL                               -- Тип самолета
);

GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON "PlaneType" TO "Admin" WITH GRANT OPTION;
GRANT SELECT ON "PlaneType" TO "Web";




-- Таблица Самолеты
CREATE TABLE "Plane" (
  "id" SMALLINT NOT NULL IDENTITY PRIMARY KEY
, "name" VARCHAR(45) NOT NULL                               -- Название (код) самолета
, "type_id" TINYINT NOT NULL                                -- Идентификатор типа самолета

, CONSTRAINT "fk_plane_type"
    FOREIGN KEY ("type_id")
    REFERENCES "PlaneType"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);

GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON "Plane" TO "Admin" WITH GRANT OPTION;
GRANT SELECT ON "Plane" TO "Web";




-- Таблица Расписание полетов
CREATE TABLE "PlaneSchedule" (
  "id" INT NOT NULL IDENTITY PRIMARY KEY
, "plane_id" SMALLINT NOT NULL                              -- 
, "takeoff_date" DATETIME NOT NULL
, "landing_date" DATETIME NOT NULL
, "loading_cost" MONEY NOT NULL
, "unloading_cost" MONEY NOT NULL
, "takeoff_cost" MONEY NOT NULL
, "landing_cost" MONEY NOT NULL
, "dispetcher_cost" MONEY NOT NULL

, CONSTRAINT "fk_planeschedule_plane"
    FOREIGN KEY ("plane_id")
    REFERENCES "Plane"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);

GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON "PlaneSchedule" TO "Admin" WITH GRANT OPTION;
GRANT SELECT ON "PlaneSchedule" TO "Web";



  
-- Таблица Перелет
CREATE TABLE "Flight" (
  "id" INT NOT NULL IDENTITY PRIMARY KEY
, "tourist_id" INT NOT NULL
, "flight_id" INT NOT NULL

, CONSTRAINT "fk_flight_tourist"
    FOREIGN KEY ("tourist_id")
    REFERENCES "Tourist"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    
, CONSTRAINT "fk_flight_planeschedule"
    FOREIGN KEY ("flight_id")
    REFERENCES "PlaneSchedule"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);

GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON "Flight" TO "Admin" WITH GRANT OPTION;



  
-- Таблица Тип багажа
CREATE TABLE "BaggageType" (
  "id" SMALLINT NOT NULL IDENTITY PRIMARY KEY
, "name" VARCHAR(45) NOT NULL
);

GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON "BaggageType" TO "Admin" WITH GRANT OPTION;




-- Таблица Багаж
CREATE TABLE "Baggage" (
  "id" INT NOT NULL IDENTITY PRIMARY KEY
, "tourist_flight_id" INT NOT NULL
, "type_id" SMALLINT NOT NULL
, "weight" FLOAT NOT NULL
, "self_cost" MONEY NOT NULL
, "space_amount" FLOAT NOT NULL
, "packing_cost" MONEY NOT NULL
, "insurance_cost" MONEY NOT NULL
, "keep_cost" MONEY NOT NULL
, "date_storage_in" DATETIME NOT NULL
, "date_storage_out" DATETIME NOT NULL

, CONSTRAINT "fk_baggage_flight"
    FOREIGN KEY ("tourist_flight_id")
    REFERENCES "Flight"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    
, CONSTRAINT "fk_bagagge_type"
    FOREIGN KEY ("type_id")
    REFERENCES "BaggageType"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);

GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON "Baggage" TO "Admin" WITH GRANT OPTION;




-- Таблица Перевоз багажа
CREATE TABLE "BaggageTransportation" (
  "id" INT NOT NULL IDENTITY PRIMARY KEY
, "baggage_id" INT NOT NULL
, "flight_id" INT NOT NULL

, CONSTRAINT "fk_baggagetransportation_baggage"
    FOREIGN KEY ("baggage_id")
    REFERENCES "Baggage"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    
, CONSTRAINT "fk_baggagetransportation_planeschedule"
    FOREIGN KEY ("flight_id")
    REFERENCES "PlaneSchedule"
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);

GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON "BaggageTransportation" TO "Admin" WITH GRANT OPTION;