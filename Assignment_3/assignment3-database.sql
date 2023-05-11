-- Assignment 3 - François d’Entremont
-- GISY5003/3082/Spatial Database Management

-- Spatially enabling the database.
CREATE EXTENSION postgis;

-- Adding extension postgis_raster to deal with raster data types
create extension postgis_raster;

-- Inserting schemas.
CREATE SCHEMA surveying;
CREATE SCHEMA asset;
CREATE SCHEMA bathymetry;

-- Inserting a table for the raster
CREATE TABLE bathymetry.dem (
	identifier serial PRIMARY KEY,
	grid raster
);

-- Here we normalize the survey metadata into four tables.
-- The following tables were created using python and the survey
-- metadata was loaded into all four tables at once. 
-- (see assignment3-load_survey_metadata.py)

CREATE TABLE surveying.originator (
	id             serial PRIMARY KEY,
	name           varchar(32)
);

CREATE TABLE surveying.location (
	id             serial PRIMARY KEY,
	name           varchar(40)
);

CREATE TABLE surveying.ocean (
	id             serial PRIMARY KEY,
	name           varchar(32)
);

CREATE TABLE surveying.survey (
	metadata_identifier     char(36) PRIMARY KEY,
	ocean_id                varchar(32),
	title                   varchar(32),
	location_id             varchar(40),
	start_date              timestamp without time zone,
	end_date                timestamp without time zone,
	points                  int,
	description             varchar(350),
	originator_id           varchar(32),
	geom                    geography
);

-- SQL Server uses the default SRID 4326 for the geom layer. WGS84
-- uses degrees so it makes more sense to make it a geography. 
-- The survey table will be altered after inserting the data from the
-- excel file

-- Changing names into ids and creating foreign keys
UPDATE surveying.survey
SET ocean_id = '1';

ALTER TABLE surveying.survey
ALTER COLUMN ocean_id
TYPE int
USING ocean_id::integer;

ALTER TABLE surveying.survey
ADD FOREIGN KEY (ocean_id)
REFERENCES surveying.ocean(id);

UPDATE surveying.survey
SET location_id = '1'
WHERE location_id = 'Bridlington Bay';

UPDATE surveying.survey
SET location_id = '2'
WHERE location_id = 'Spurn Head to Flamborough Head';

UPDATE surveying.survey
SET location_id = '3'
WHERE location_id = 'Outer Silver Pit';

UPDATE surveying.survey
SET location_id = '4'
WHERE location_id = 'Whitby Ground to Flamborough Head Ground';

UPDATE surveying.survey
SET location_id = '5'
WHERE location_id = 'Flamborough Head Ground';

ALTER TABLE surveying.survey
ALTER COLUMN location_id
TYPE int
USING location_id::integer;

ALTER TABLE surveying.survey
ADD FOREIGN KEY (location_id)
REFERENCES surveying.location(id);

UPDATE surveying.survey
SET originator_id = '1'
WHERE originator_id = 'Royal Navy';

UPDATE surveying.survey
SET originator_id = '2'
WHERE originator_id = 'U.D.I. Group Ltd';

UPDATE surveying.survey
SET originator_id = '3'
WHERE originator_id = 'Gardline Surveys';

ALTER TABLE surveying.survey
ALTER COLUMN originator_id
TYPE int
USING originator_id::integer;

ALTER TABLE surveying.survey
ADD FOREIGN KEY (originator_id)
REFERENCES surveying.originator(id);

-- Cable route and windfarm tables have been created using python
-- using the following queries and then data was loaded
CREATE TABLE asset.windfarm (
	identifier 			int PRIMARY KEY,
	windmill_polygon 	geometry(GEOMETRY, 25831)
);
	
CREATE TABLE asset.route (
    identifier	int PRIMARY KEY,
    route 		geometry(GEOMETRY, 25831)
);