USE "sp110_15_db_2013";
-- EXEC sp_table_privileges @table_name = 'Sex';

-- DROP ROLE "Admin"
CREATE ROLE "Admin";

-- ������� �� �������


























-- ������� �� View







-- ������� �� Procedure









-- ������� �� Function

























-- DROP LOGIN "admin"
-- DROP USER "adminUser"
CREATE LOGIN "admin" WITH PASSWORD = 'password';
CREATE USER "adminUser" FOR LOGIN "admin";
ALTER ROLE "Admin" ADD MEMBER "adminUser";




-- DROP ROLE "ExcursionManager"
CREATE ROLE "ExcursionManager";

-- ������� �� �������












-- ������� �� View






-- ������� �� Procedure







-- ������� �� Function






-- DROP LOGIN "excursionManager"
-- DROP USER "excursionManagerUser"
CREATE LOGIN "excursionManager" WITH PASSWORD = 'password';
CREATE USER "excursionManagerUser" FOR LOGIN "excursionManager";
ALTER ROLE "ExcursionManager" ADD MEMBER "excursionManagerUser";




-- DROP ROLE "Web"
CREATE ROLE "Web";

-- ������� �� �������








-- DROP LOGIN "web"
-- DROP USER "webUser"
CREATE LOGIN "web" WITH PASSWORD = 'webPassw0rd';
CREATE USER "webUser" FOR LOGIN "web";
ALTER ROLE "Web" ADD MEMBER "webUser";

