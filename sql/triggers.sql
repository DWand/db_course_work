USE "sp110_15_db_2013";



CREATE TRIGGER "AvoidCreateNewSex"
ON "dbo"."Sex"
AFTER INSERT
AS
BEGIN
  RAISERROR ('Unable to create new sex.', 1, 1);
  ROLLBACK TRANSACTION;
  RETURN;
END;

-- INSERT INTO "Sex" VALUES ('middle');




CREATE TRIGGER "AvoidRemoveSex"
ON "dbo"."Sex"
AFTER DELETE
AS
BEGIN
  RAISERROR ('Unable to remove sex.', 1, 1);
  ROLLBACK TRANSACTION;
  RETURN;
END;

-- DELETE FROM "Sex" WHERE "id" = 1;
