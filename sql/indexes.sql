USE "sp110_15_db_2013";




CREATE INDEX "TakeOff" ON "PlaneSchedule"("takeoff_date" ASC);

CREATE INDEX "Dates" ON "Residence"("move_in" ASC, "move_out" ASC);

CREATE INDEX "Date" ON "Spending"("date" ASC);

CREATE INDEX "Date" ON "ExcursionSchedule"("date" ASC);
