#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-'EOSQL'
    CREATE USER docker;
    CREATE DATABASE carshop;
    GRANT ALL PRIVILEGES ON DATABASE carshop TO docker;
	\c carshop;
	CREATE TABLE Sales (
    ID            SERIAL primary key,
    name        varchar(100) NOT NULL
	);

	CREATE TABLE Customers (
    ID            SERIAL primary key,
    name        varchar(100) NOT NULL,
	phoneNumber	    varchar(30) NOT NULL
	);

	CREATE TABLE Manufacturers (
    ID            SERIAL primary key,
    name        varchar(100) NOT NULL,
	details	    varchar(3000)
	);

	CREATE TABLE Models (
    ID            SERIAL primary key,
    name        varchar(100) NOT NULL,
	manufacturer    int	references Manufacturers(ID) NOT NULL
	);

	CREATE TABLE ModelVariants (
    ID            SERIAL primary key,
    name        varchar(100) NOT NULL,
	model    int	references Models(ID) NOT NULL,
	weight    real NOT NULL,
	ECcapacity  int  NOT NULL
	);

	CREATE TYPE geartype AS ENUM ('auto', 'manual');

	CREATE TABLE Cars (
    ID            SERIAL primary key,
	manufactureDate    date NOT NULL,
    manufacturePlace    varchar(100) NOT NULL,
	used    boolean NOT NULL,
	firstRegisterDate    date CHECK((NOT used) OR (used AND (firstRegisterDate IS NOT NULL))),
	mileage   int   NOT NULL,
	gearType    geartype   NOT NULL,
	listStatus    boolean   DEFAULT FALSE,
	listPrice     real    CHECK((NOT listStatus) OR (listStatus AND  (listPrice IS NOT NULL))),
	listDate    date    CHECK((NOT listStatus) OR (listStatus AND  (listDate IS NOT NULL))),
	modelVariant int references ModelVariants(ID)
	);

	CREATE TABLE AccidentRecords (
    ID            SERIAL primary key,
    data        date NOT NULL,
	description    varchar(4000)    NOT NULL,
	fileUrls    varchar(1000)[],
	car    int    references Cars(ID) NOT NULL
	);

	CREATE TABLE ServiceRecords (
    ID            SERIAL primary key,
    data        date NOT NULL,
	details    varchar(4000)    NOT NULL,
	car    int    references Cars(ID) NOT NULL
	);

	CREATE TABLE Transaction (
    ID            SERIAL primary key,
	customer    int    references Customers(ID) NOT NULL,
    salePerson    int    references Sales(ID) NOT NULL,
	car    int    references Cars(ID) NOT NULL,
	datetime    timestamp,
	cancelStatus   boolean   DEFAULT FALSE,
	cancelResaons    varchar(4000)    CHECK((NOT cancelStatus) OR (cancelStatus AND  (cancelResaons IS NOT NULL))),
	cancelDatetime    timestamp
	);

	CREATE OR REPLACE FUNCTION update_datetime_column() RETURNS TRIGGER AS $$
	BEGIN
		NEW.datetime = now();
		RETURN NEW;
	END;
	$$ language 'plpgsql';

	CREATE TRIGGER update_transaction_datetime BEFORE INSERT ON Transaction FOR EACH ROW EXECUTE PROCEDURE  update_datetime_column();

	CREATE OR REPLACE FUNCTION update_canceldatetime_column()
	RETURNS TRIGGER AS $$
	BEGIN
		IF (NEW.customer IS DISTINCT FROM OLD.customer
			OR NEW.salePerson IS DISTINCT FROM OLD.salePerson
			OR NEW.car IS DISTINCT FROM OLD.car) THEN
			RAISE EXCEPTION 'Trasaction record cannot be modified';
		ELSE
			IF ((OLD.cancelStatus == FALSE) AND (NEW.cancelStatus==TRUE)) THEN
				NEW.cancelDatetime = now();
				RETURN NEW;
			END IF;
			IF((OLD.cancelStatus == FALSE) AND (NEW.cancelStatus==TRUE)) THEN
				RAISE EXCEPTION 'Canceled Trasaction record cannot be reactivated';
			END IF;
		END IF;
	END;
	$$ language 'plpgsql';

	CREATE TRIGGER update_transaction_canceldatetime BEFORE UPDATE ON Transaction FOR EACH ROW EXECUTE PROCEDURE  update_datetime_column();


EOSQL
