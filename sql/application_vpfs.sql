use sp110_15_db_2013;

-- drop view ClientData
create view ClientData
as
select 
	h.id as id,
	h.name as name,
	h.surname as surname,
	h.patronymic as patronymic,
	h.passport as passport,
	h.birthday as birthday,
	s.id as sex_id,
	s.name as sex
from Human as h
inner join Sex as s on s.id = h.sex_id;

-- select * from ClientData

grant select on ClientData to Admin with grant option;

-- drop view HotelData
create view HotelData
as
select
	Hotel.id as id,
	Hotel.name as name,
	City.id as city_id,
	City.name as city
from Hotel
inner join City on City.id = Hotel.city_id;

grant select on HotelData to Admin with grant option;

create view PlaneData
as
select 
	Plane.id as id,
	Plane.name as name,
	t.id as type_id,
	t.name as type
from Plane
inner join PlaneType as t on t.id = Plane.type_id;

grant select on PlaneData to Admin with grant option;

-- drop view FlightScheduleData
create view FlightScheduleData
as
select
	sch.id as id,
	sch.plane_id as plane_id,
	pl.name as plane,
	pl.type_id as plane_type_id,
	pl.type as plane_type,
	sch.takeoff_date as takeoff_date,
	sch.landing_date as landing_date,
	sch.loading_cost as loading_cost,
	sch.unloading_cost as unloading_cost,
	sch.takeoff_cost as takeoff_cost,
	sch.landing_cost as landing_cost,
	sch.dispetcher_cost as dispetcher_cost,
	pl.name + ' / ' + convert(varchar(20), sch.takeoff_date, 120) as name
from PlaneSchedule as sch
inner join PlaneData as pl on pl.id = sch.plane_id;

-- select * from FlightScheduleData;
grant select on FlightScheduleData to Admin with grant option;

create view RoomData
as
select
	Room.id as id,
	Room.label as name,
	Hotel.id as hotel_id,
	Hotel.name as hotel
from Room
inner join Hotel on Hotel.id = Room.hotel_id;

grant select on RoomData to Admin with grant option;

create view ExcursionData
as
select
	Excursion.id as id,
	Excursion.name as name,
	Excursion.description as description,
	agency.id as agency_id,
	agency.name as agency_name
from Excursion
inner join ExcursionAgency as agency on agency.id = Excursion.agency_id;

grant select on ExcursionData to Admin with grant option;
grant select on ExcursionData to ExcursionManager;


create view ExcursionScheduleData
as
select
	sch.id as id,
	sch.cost as cost,
	sch.date as date,
	ed.id as excursion_id,
	ed.name as excursion_name,
	ed.description as excursion_description,
	ed.agency_id as agency_id,
	ed.agency_name as agency_name,
	ed.name + ' / ' + convert(varchar(20), sch.date, 120) as name
from ExcursionSchedule as sch
inner join ExcursionData as ed on ed.id = sch.excursion_id;

grant select on ExcursionScheduleData to Admin with grant option;


create view ResidenceData
as
select
  "Tourist"."id" AS "tourist_id",
  "Hotel"."id" AS "hotel_id",
  "Hotel"."name" AS "hotel_name",
  "Room"."id" AS "room_id",
  "Room"."label" AS "room_label",
  "Residence"."id" AS "residence_id",
  "Residence"."move_in" AS "move_in",
  "Residence"."move_out" AS "move_out",
  "Residence"."cost" AS "cost"
from "Hotel"
INNER JOIN "Room" ON "Room"."hotel_id" = "Hotel"."id"
INNER JOIN "Residence" ON "Residence"."room_id" = "Room"."id"
INNER JOIN "Tourist" ON "Tourist"."id" = "Residence"."tourist_id";

grant select on ResidenceData to Admin with grant option;


create function GetHotelsFromCity (
	@city_id INT
) returns table
as
return
select *
from HotelData
where city_id = @city_id;

grant select on GetHotelsFromCity to Admin with grant option;

create function GetPlanesOfType (
	@type_id INT
) returns table
as
return
select *
from PlaneData
where type_id = @type_id;

grant select on GetPlanesOfType to Admin with grant option;

create procedure AddHotel
	@name varchar(50),
	@city_id int
as begin
	insert into Hotel (name, city_id) values (@name, @city_id);
end;

grant execute on AddHotel to Admin with grant option;


create procedure AddPlane
	@name varchar(45),
	@type_id int
as begin
	insert into Plane (name, type_id) values (@name, @type_id);
end;

grant execute on AddPlane to Admin with grant option;



create procedure AddAgency
	@name varchar(50)
as begin
	insert into ExcursionAgency (name) values (@name);
end;

grant execute on AddAgency to Admin with grant option;
grant execute on AddAgency to ExcursionManager;


create procedure AddGroup
	@name varchar(30)
as begin
	insert into TouristGroup (label) values (@name);
end;

grant execute on AddGroup to Admin with grant option;


create procedure AddClient
	@name varchar(45),
	@surname varchar(45),
	@patronymic varchar(45),
	@passport varchar(20),
	@sex_id tinyint,
	@birthday datetime
as begin
	insert into Human
	(name, surname, patronymic, passport, sex_id, birthday)
	values
	(@name, @surname, @patronymic, @passport, @sex_id, @birthday);
end;

grant execute on AddClient to Admin with grant option;

create procedure UpdateCity
	@id int,
	@name varchar(45)
as begin
	update City
	set
		name = @name
	where
		id = @id;
end;

grant execute on UpdateCity to Admin with grant option;

create procedure DeleteCity
	@id int
as begin
	delete from City where id = @id;
end;

grant execute on DeleteCity to Admin with grant option;


create function GetRoomsOfHotel (
	@hotel_id int
) returns table
as
return
select *
from RoomData
where hotel_id = @hotel_id;

grant select on GetRoomsOfHotel to Admin with grant option;


create procedure AddRoom
	@name varchar(30),
	@hotel_id int
as begin
	insert into Room (label, hotel_id) values (@name, @hotel_id);
end;

grant execute on AddRoom to Admin with grant option;


create procedure DeleteRoom
	@id int
as begin
	delete from Room where id = @id;
end;

grant execute on DeleteRoom to Admin with grant option;


create procedure AddTourForClient 
	@client_id int,
	@group_id int,
	@category_id int,
	@cost money
as begin
	insert into Tourist
	(human_id, group_id, category_id, paid_for_tour)
	values
	(@client_id, @group_id, @category_id, @cost);
end;

grant execute on AddTourForClient to Admin with grant option;


create procedure DeleteTour
	@tour_id int
as begin
	delete from Tourist where id = @tour_id;
end;

grant execute on DeleteTour to Admin with grant option;


create function GetTouristsByGroup (
	@group_id int
) returns table
as
return
select *
from TouristInfo
where group_id = @group_id;

grant select on GetTouristsByGroup to Admin with grant option;



create procedure DeleteGroup
	@group_id int
as begin
	delete from TouristGroup where id = @group_id;
end;

grant execute on DeleteGroup to Admin with grant option;


create function GetExcursionsByAgency (
	@agency_id int
) returns table
as
return
select *
from ExcursionData
where ExcursionData.agency_id = @agency_id;

grant select on GetExcursionsByAgency to Admin with grant option;
grant select on GetExcursionsByAgency to ExcursionManager;


create procedure DeleteAgency
	@id int
as begin
	delete from ExcursionAgency where id = @id;
end;

grant execute on DeleteAgency to Admin with grant option;
grant execute on DeleteAgency to ExcursionManager;


create procedure AddExcursion
	@name varchar(50),
	@description varchar(300),
	@agency_id int
as begin
	insert into Excursion
	(name, description, agency_id)
	values
	(@name, @description, @agency_id);
end;

grant execute on AddExcursion to Admin with grant option;
grant execute on AddExcursion to ExcursionManager;


create procedure DeleteExcursion
	@id int
as begin
	delete from Excursion where id = @id;
end;

grant execute on DeleteExcursion to Admin with grant option;
grant execute on DeleteExcursion to ExcursionManager;


create function GetScheduleForExcursion (
	@id int
) returns table
as
return
select
	sch.id as id,
	sch.date as date,
	sch.cost as cost,
	sch.excursion_id as excursion_id,
	data.name as name,
	data.description as description,
	data.agency_id as agency_id,
	data.agency_name as agency
from ExcursionSchedule as sch
inner join ExcursionData as data on data.id = sch.excursion_id
where sch.excursion_id = @id;

grant select on GetScheduleForExcursion to Admin with grant option;
grant select on GetScheduleForExcursion to ExcursionManager;


-- drop procedure AddExcursionSchedule
create procedure AddExcursionSchedule
	@id int,
	@date nvarchar(50),
	@cost money
as begin
	insert into ExcursionSchedule 
	(excursion_id, date, cost)
	values
	(@id, convert(datetime, @date, 126), @cost);
end;

grant execute on AddExcursionSchedule to Admin with grant option;
grant execute on AddExcursionSchedule to ExcursionManager;


create function GetScheduleForPlane (
	@id int
) returns table
as
return
select *
from FlightScheduleData
where plane_id = @id;

grant select on GetScheduleForPlane to Admin with grant option;


-- drop procedure AddPlaneSchedule
create procedure AddPlaneSchedule
	@plane_id int,
	@takeoff_date nvarchar(50),
	@landing_date nvarchar(50),
	@loading_cost money,
	@unloading_cost money,
	@takeoff_cost money,
	@landing_cost money,
	@dispetcher_cost money
as begin
	insert into PlaneSchedule
	(plane_id, takeoff_date, landing_date, loading_cost, unloading_cost, takeoff_cost, landing_cost, dispetcher_cost)
	values
	(@plane_id, convert(datetime, @takeoff_date, 126), convert(datetime,  @landing_date, 126), @loading_cost, @unloading_cost, @takeoff_cost, @landing_cost, @dispetcher_cost);
end;

grant execute on AddPlaneSchedule to Admin with grant option;


create procedure DeletePlaneSchedule
	@id int
as begin
	delete from PlaneSchedule where id = @id;
end;

grant execute on DeletePlaneSchedule to Admin with grant option;


-- drop function GetFlightsByTourist
create function GetFlightsByTourist (
	@tourist_id int
) returns table
as
return
select sch.*, Flight.id as flight_id
from FlightScheduleData as sch
inner join Flight on Flight.flight_id = sch.id
where Flight.tourist_id = @tourist_id;

grant select on GetFlightsByTourist to Admin with grant option;


create function GetFlightDetails (
	@flight_id int
) returns table
as
return
select sch.*, Flight.id as flight_id
from FlightScheduleData as sch
inner join Flight on Flight.flight_id = sch.id
where Flight.id = @flight_id;

grant select on GetFlightDetails to Admin with grant option;


create function GetTouristByFlight (
	@flight_id int
) returns table
as
return
select TouristInfo.*
from TouristInfo
inner join Flight on Flight.tourist_id = TouristInfo.id
where Flight.id = @flight_id;

grant select on GetTouristByFlight to Admin with grant option;


create procedure DeleteTouristFlight
	@flight_id int
as begin
	delete from Flight where id = @flight_id;
end;

grant execute on DeleteTouristFlight to Admin with grant option;


create procedure AddFlightForTourist
	@tourist_id int,
	@schedule_id int
as begin
	insert into Flight
	(tourist_id, flight_id)
	values
	(@tourist_id, @schedule_id);
end;

grant execute on AddFlightForTourist to Admin with grant option;


create procedure UpdateClient
	@id int,
	@name varchar(45),
	@surname varchar(45),
	@patronymic varchar(45),
	@passport varchar(20),
	@sex_id tinyint,
	@birthday varchar(max)
as begin
	update Human set
		name = @name,
		surname = @surname,
		patronymic = @patronymic,
		passport = @passport,
		sex_id = @sex_id,
		birthday = convert(datetime, @birthday, 126)
	where id = @id;
end;

grant execute on UpdateClient to Admin with grant option;


create procedure UpdateTourist
	@id int,
	@group_id int,
	@category_id int,
	@paid money
as begin
	update Tourist set
		group_id = @group_id,
		category_id = @category_id,
		paid_for_tour = @paid
	where id = @id;
end;

grant execute on UpdateTourist to Admin with grant option;


create procedure UpdateGroup
	@id int,
	@label varchar(30)
as begin
	update TouristGroup set
		label = @label
	where id = @id;
end;

grant execute on UpdateGroup to Admin with grant option;


create procedure UpdateAgency
	@id int,
	@name varchar(50)
as begin
	update ExcursionAgency set
		name = @name
	where id = @id;
end;

grant execute on UpdateAgency to Admin with grant option;
grant execute on UpdateAgency to ExcursionManager;


create procedure UpdateExcursion
	@id int,
	@agency_id int,
	@name varchar(50),
	@description varchar(300)
as begin
	update Excursion set
		agency_id = @agency_id,
		name = @name,
		description = @description
	where id = @id;
end;

grant execute on UpdateExcursion to Admin with grant option;
grant execute on UpdateExcursion to ExcursionManager;


create procedure UpdateHotel
	@id int,
	@city_id int,
	@name varchar(50)
as begin
	update Hotel set
		city_id = @city_id,
		name = @name
	where id = @id;
end;

grant execute on UpdateHotel to Admin with grant option;


create procedure UpdateRoom
	@id int,
	@label varchar(30)
as begin
	update Room set
		label = @label
	where id = @id;
end;

grant execute on UpdateRoom to Admin with grant option;


create procedure UpdatePlane
	@id int,
	@name varchar(45),
	@type_id int
as begin 
	update Plane set
		name = @name,
		type_id = @type_id
	where id = @id;
end;

grant execute on UpdatePlane to Admin with grant option;


create procedure UpdateFlightSchedule
	@id int,
	@plane_id int,
	@takeoff_date varchar(max),
	@landing_date varchar(max),
	@loading_cost money,
	@unloading_cost money,
	@takeoff_cost money,
	@landing_cost money,
	@dispetcher_cost money
as begin
	update PlaneSchedule set
		plane_id = @plane_id,
		takeoff_date = convert(datetime, @takeoff_date, 126),
		landing_date = convert(datetime, @landing_date, 126),
		loading_cost = @loading_cost,
		unloading_cost = @unloading_cost,
		takeoff_cost = @takeoff_cost,
		landing_cost = @landing_cost,
		dispetcher_cost = @dispetcher_cost
	where id = @id;
end;

grant execute on UpdateFlightSchedule to Admin with grant option;


create procedure AddResidence
	@tourist_id int,
	@room_id int,
	@move_in varchar(max),
	@move_out varchar(max),
	@cost money
as begin
	insert into Residence
	(tourist_id, room_id, move_in, move_out, cost)
	values
	(@tourist_id, @room_id, convert(datetime, @move_in, 126), convert(datetime, @move_out, 126), @cost);
end;

grant execute on AddResidence to Admin with grant option;


-- drop procedure AddExcursionVisit
create procedure AddExcursionVisit
	@tourist_id int,
	@excSch_id int
as begin
	if exists(select 1 from Parent where child_id = @tourist_id)
	begin
		if exists(
			select 1 
			from ExcursionVisit
			where 
				excursion_id = @excSch_id AND
				tourist_id in (select parent_id from Parent where child_id = @tourist_id)
		)
			insert into ExcursionVisit (tourist_id, excursion_id) values (@tourist_id, @excSch_id);
		else
		begin
			raiserror('Children can not visit excursions without parents', 15, 1);
		end
	end
	else
		insert into ExcursionVisit (tourist_id, excursion_id) values (@tourist_id, @excSch_id);
end;

grant execute on AddExcursionVisit to Admin with grant option;


create function GetParents (
	@tourist_id int
) returns table
as
return
select info.*
from TouristInfo as info
inner join Parent on Parent.parent_id = info.id
where Parent.child_id = @tourist_id;

grant select on GetParents to Admin with grant option;


create function GetChildren (
	@tourist_id int
) returns table
as
return
select info.*
from TouristInfo as info
inner join Parent on Parent.child_id = info.id
where Parent.parent_id = @tourist_id;

grant select on GetChildren to Admin with grant option;


create procedure AddParent
	@tourist_id int,
	@parent_id int
as begin
	insert into Parent (parent_id, child_id) values (@parent_id, @tourist_id);
end;

grant execute on AddParent to Admin with grant option;


create procedure AddChild
	@tourist_id int,
	@child_id int
as begin
	insert into Parent (parent_id, child_id) values (@tourist_id, @child_id);
end;

grant execute on AddChild to Admin with grant option;


create procedure RemoveParent
	@tourist_id int,
	@parent_id int
as begin
	delete from Parent where parent_id = @parent_id AND child_id = @tourist_id;
end;

grant execute on RemoveParent to Admin with grant option;


create procedure RemoveChild
	@tourist_id int,
	@child_id int
as begin
	delete from Parent where parent_id = @tourist_id AND child_id = @child_id;
end;

grant execute on RemoveChild to Admin with grant option;


create function GetTouristByResidence (
	@res_id int
) returns table 
as
return
select TouristInfo.*
from TouristInfo
inner join Residence on Residence.tourist_id = TouristInfo.id
where Residence.id = @res_id;

grant select on GetTouristByResidence to Admin with grant option;


create procedure DeleteResidence
	@id int
as begin
	delete from Residence where id = @id;
end;

grant execute on DeleteResidence to Admin with grant option;


create procedure UpdateResidence
	@id int,
	@room_id int,
	@move_in varchar(max),
	@move_out varchar(max),
	@cost money
as begin
	update Residence set
		room_id = @room_id,
		move_in = convert(datetime, @move_in, 126),
		move_out = convert(datetime, @move_out, 126),
		cost = @cost
	where id = @id;
end;

grant execute on UpdateResidence to Admin with grant option;


create procedure DeleteExcursionVisit
	@id int
as begin
	delete from ExcursionVisit where id = @id;
end;

grant execute on DeleteExcursionVisit to Admin with grant option;


create procedure AddBaggage
	@tourist_id int,
	@type_id int,
	@weight float,
	@self_cost money,
	@space_amount float,
	@packing_cost money,
	@insurance_cost money,
	@keep_cost money,
	@date_storage_in varchar(max),
	@date_storage_out varchar(max),
	@flight_id int
as begin
	insert into Baggage
	(tourist_flight_id, type_id, weight, self_cost, space_amount, packing_cost, insurance_cost, keep_cost, date_storage_in, date_storage_out)
	values
	(@tourist_id, @type_id, @weight, @self_cost, @space_amount, @packing_cost, @insurance_cost, @keep_cost, @date_storage_in, @date_storage_out);

	declare @lastID int;
	SELECT @lastID = ID FROM Baggage WHERE ID = @@Identity;

	insert into BaggageTransportation
	(baggage_id, flight_id)
	values
	(@lastID, @flight_id);
end;

grant execute on AddBaggage to Admin with grant option;


-- drop procedure DeleteBaggage
create procedure DeleteBaggage
	@baggage_id int
as begin
	delete from BaggageTransportation where baggage_id = @baggage_id;
	delete from Baggage where id = @baggage_id;
end;

grant execute on DeleteBaggage to Admin with grant option;


create procedure DeleteHotel
	@id int
as begin
	delete from Hotel where id = @id;
end;

grant execute on DeleteHotel to Admin with grant option;