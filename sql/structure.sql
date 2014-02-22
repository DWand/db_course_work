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




-- ������� ��� ��������
CREATE TABLE "Sex" (
  "id" TINYINT NOT NULL IDENTITY PRIMARY KEY
, "name" VARCHAR(10) NOT NULL                               -- �������� ����
);

GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON "Sex" TO "Admin" WITH GRANT OPTION;
-- GRANT SELECT ON "Sex" TO "ExcursionManager";




-- ������� ����
CREATE TABLE "Human" (
  "id" INT NOT NULL IDENTITY PRIMARY KEY
, "name" VARCHAR(45) NOT NULL                               -- ���
, "surname" VARCHAR(45) NOT NULL                            -- �������
, "patronymic" VARCHAR(45) NOT NULL                         -- ��������
, "passport" VARCHAR(20)                                    -- ����� ��������
, "sex_id" TINYINT NOT NULL                                 -- ���
, "birthday" DATETIME NOT NULL                              -- ���� ��������
  
, CONSTRAINT "fk_human_sex" 
    FOREIGN KEY ("sex_id")
    REFERENCES "Sex"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);

GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON "Human" TO "Admin" WITH GRANT OPTION;
-- GRANT SELECT ON "Human" TO "ExcursionManager";




-- ������� ��������� ��������
CREATE TABLE "TouristCategory" (
  "id" TINYINT NOT NULL IDENTITY PRIMARY KEY
, "name" VARCHAR(30) NOT NULL                               -- �������� ��������� ��������
);

GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON "TouristCategory" TO "Admin" WITH GRANT OPTION;
-- GRANT SELECT ON "TouristCategory" TO "ExcursionManager";




-- ������� ������ ��������
CREATE TABLE "TouristGroup" (
  "id" INT NOT NULL IDENTITY PRIMARY KEY
, "label" VARCHAR(30) NOT NULL                              -- ��� ������ ��������
);

GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON "TouristGroup" TO "Admin" WITH GRANT OPTION;
-- GRANT SELECT ON "TouristGroup" TO "ExcursionManager";




-- ������� �������
CREATE TABLE "Tourist" (
  "id" INT NOT NULL IDENTITY PRIMARY KEY
, "human_id" INT NOT NULL                                   -- ������������� ��������
, "category_id" TINYINT NOT NULL                            -- ������������� ��������� �������
, "group_id" INT NOT NULL                                   -- ������������� ������ �������
, "paid_for_tour" MONEY NOT NULL                            -- �����, ������� ������ �������� �� �������
  
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




-- ������� ����
CREATE TABLE "Visa" (
  "id" INT NOT NULL IDENTITY PRIMARY KEY
, "tourist_id" INT NOT NULL                                 -- ������������� �������, �������� ���� ����
, "date_given" DATETIME NOT NULL                            -- ���� ������ ����
, "date_expires" DATETIME NOT NULL                          -- ���� ��������� ����
, "cost" MONEY NOT NULL                                     -- ��������� ���������� ����

, CONSTRAINT "fk_visa_tourist"
    FOREIGN KEY ("tourist_id")
    REFERENCES "Tourist"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);

GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON "Visa" TO "Admin" WITH GRANT OPTION;



-- ������� ����������� �����
CREATE TABLE "Parent" (
  "id" INT NOT NULL IDENTITY PRIMARY KEY
, "parent_id" INT NOT NULL                                  -- ������������� �������� �������
, "child_id" INT NOT NULL                                   -- ������������� ������� �������

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




-- ������� ���� ��������
CREATE TABLE "SpendingType" (
  "id" SMALLINT NOT NULL PRIMARY KEY IDENTITY
, "name" VARCHAR(30) NOT NULL                               -- �������� ���� ��������
);

GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON "SpendingType" TO "Admin" WITH GRANT OPTION;
-- GRANT SELECT ON "SpendingType" TO "ExcursionManager";




-- ������� ������� �� �������
CREATE TABLE "Spending" (
  "id" INT NOT NULL IDENTITY PRIMARY KEY
, "tourist_id" INT NOT NULL                                 -- ������������� �������, �� �������� ���� ��������� ������
, "type_id" SMALLINT NOT NULL                               -- ������������� ���� ��������
, "cost" MONEY NOT NULL                                     -- ���������� �����
, "date" DATETIME NOT NULL                                  -- ����, ����� ������ ���� ���������
, "description" VARCHAR(50) NOT NULL                        -- ������� �������� ��������

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




-- ������� ��������� ���������
CREATE TABLE "ExcursionAgency" (
  "id" SMALLINT NOT NULL IDENTITY PRIMARY KEY
, "name" VARCHAR(50) NOT NULL                               -- �������� �������� ���������
);

GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON "ExcursionAgency" TO "Admin" WITH GRANT OPTION;
GRANT SELECT, INSERT, UPDATE, DELETE ON "ExcursionAgency" TO "ExcursionManager";
GRANT SELECT ON "ExcursionAgency" TO "Web";




-- ������� ���������
CREATE TABLE "Excursion" (
  "id" INT NOT NULL IDENTITY PRIMARY KEY
, "agency_id" SMALLINT NOT NULL                             -- ������������� ��������, ������� �������������� ���������
, "name" VARCHAR(50) NOT NULL                               -- �������� ���������
, "description" VARCHAR(300) NULL                           -- ������� �������� ���������

, CONSTRAINT "fk_excursion_agency"
    FOREIGN KEY ("agency_id")
    REFERENCES "ExcursionAgency"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);

GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON "Excursion" TO "Admin" WITH GRANT OPTION;
GRANT SELECT, INSERT, UPDATE, DELETE ON "Excursion" TO "ExcursionManager";
GRANT SELECT ON "Excursion" TO "Web";




-- ������� ���������� ���������
CREATE TABLE "ExcursionSchedule" (
  "id" INT NOT NULL IDENTITY PRIMARY KEY
, "excursion_id" INT NOT NULL                               -- ������������� ���������
, "date" DATETIME NOT NULL                                  -- ���� ���������� ���������
, "cost" MONEY NOT NULL                                     -- ��������� ���������

, CONSTRAINT "fk_excursionschedule_excursion"
    FOREIGN KEY ("excursion_id")
    REFERENCES "Excursion"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);

GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON "ExcursionSchedule" TO "Admin" WITH GRANT OPTION;
GRANT SELECT, INSERT, UPDATE, DELETE ON "ExcursionSchedule" TO "ExcursionManager";
GRANT SELECT ON "ExcursionSchedule" TO "Web";




-- ������� ��������� ���������
CREATE TABLE "ExcursionVisit" (
  "id" INT NOT NULL IDENTITY PRIMARY KEY
, "tourist_id" INT NOT NULL                                 -- ������������� �������
, "excursion_id" INT NOT NULL                               -- ������������� ��������� (� ����������)

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




-- ������� �����
CREATE TABLE "City" (
  "id" SMALLINT NOT NULL IDENTITY PRIMARY KEY
, "name" VARCHAR(45) NOT NULL                               -- �������� ������
);

GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON "City" TO "Admin" WITH GRANT OPTION;




-- ������� ������
CREATE TABLE "Hotel" (
  "id" INT NOT NULL IDENTITY PRIMARY KEY
, "name" VARCHAR(50) NOT NULL                               -- �������� �����
, "city_id" SMALLINT NOT NULL                               -- �������� ������

, CONSTRAINT "fk_hotel_city"
    FOREIGN KEY ("city_id")
    REFERENCES "City"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);

GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON "Hotel" TO "Admin" WITH GRANT OPTION;




-- ������� ������� ������
CREATE TABLE "Room" (
  "id" INT NOT NULL IDENTITY PRIMARY KEY
, "hotel_id" INT NOT NULL                                   -- ������������� �����
, "label" VARCHAR(30)                                       -- ��� ������

, CONSTRAINT "fk_room_hotel"
    FOREIGN KEY ("hotel_id")
    REFERENCES "Hotel"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);

GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON "Room" TO "Admin" WITH GRANT OPTION;




-- ������� ����������
CREATE TABLE "Residence" (
  "id" INT NOT NULL IDENTITY PRIMARY KEY
, "tourist_id" INT NOT NULL                                 -- ������������� �������
, "room_id" INT NOT NULL                                    -- ������������� ������
, "move_in" DATETIME NOT NULL                               -- ���� �������� � �����
, "move_out" DATETIME NOT NULL                              -- ���� ��������� �� ������
, "cost" MONEY NOT NULL                                     -- ��������� ���������� �� �����  

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




-- ������� ���� ��������
CREATE TABLE "PlaneType" (
  "id" TINYINT NOT NULL IDENTITY PRIMARY KEY
, "name" VARCHAR(30) NOT NULL                               -- ��� ��������
);

GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON "PlaneType" TO "Admin" WITH GRANT OPTION;
GRANT SELECT ON "PlaneType" TO "Web";




-- ������� ��������
CREATE TABLE "Plane" (
  "id" SMALLINT NOT NULL IDENTITY PRIMARY KEY
, "name" VARCHAR(45) NOT NULL                               -- �������� (���) ��������
, "type_id" TINYINT NOT NULL                                -- ������������� ���� ��������

, CONSTRAINT "fk_plane_type"
    FOREIGN KEY ("type_id")
    REFERENCES "PlaneType"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);

GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON "Plane" TO "Admin" WITH GRANT OPTION;
GRANT SELECT ON "Plane" TO "Web";




-- ������� ���������� �������
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



  
-- ������� �������
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



  
-- ������� ��� ������
CREATE TABLE "BaggageType" (
  "id" SMALLINT NOT NULL IDENTITY PRIMARY KEY
, "name" VARCHAR(45) NOT NULL
);

GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON "BaggageType" TO "Admin" WITH GRANT OPTION;




-- ������� �����
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




-- ������� ������� ������
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