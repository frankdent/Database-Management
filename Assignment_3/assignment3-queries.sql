-- Assignment 3 - François d’Entremont
-- GISY5003/3082/Spatial Database Management

-- Which surveys are available at the location of the windfarm?
-- Coordinate reference system:
-- Most data in this exercise will be referenced to the coordinate
-- reference system urn:ogc:def:crs:EPSG::25831. We will transform
-- the survey geometries to 25831
SELECT s.metadata_identifier, s.title AS survey_title,
	age(s.end_date) AS survey_age,
	s.points / (ST_Area(s.geom) / 10000) AS 
	soundings_per_hectare,
	o.name AS originator_name
FROM surveying.survey s, asset.windfarm w, surveying.originator o
WHERE ST_Intersects(w.windmill_polygon,
					ST_Transform(s.geom::geometry,25831)) AND
	o.id = s.originator_id;

-- Map of surveys at the windfarm site
-- Data loaded into QGIS and filtered for the three surveys that are
-- available for the windfarm.

-- Surveys that intersect the cable route
SELECT s.metadata_identifier, s.title AS survey_title
FROM surveying.survey s, asset.route r
WHERE ST_Intersects(r.route, ST_Transform(s.geom::geometry,25831));

-- Surveys within 1km of the route of the cable
SELECT s.metadata_identifier, s.title AS survey_title
FROM surveying.survey s, asset.route r
WHERE ST_DWithin(r.route, ST_Transform(s.geom::geometry,25831), 1000);

-- Heights along the path of the cable route.
WITH path AS (
		SELECT ST_Segmentize(r.route, 50) AS segment
        FROM asset.route r
             ),
    points AS (
        SELECT row_number() OVER () AS row_num, p.pts
        FROM (
			SELECT (ST_DumpPoints(path.segment)).geom AS pts
            FROM path
             ) p
        	  )
    SELECT (points.row_num - 1) * 50 AS distance,
		ST_Value(grid, 1, points.pts) AS heights
    FROM points, bathymetry.dem b
    WHERE ST_Intersects(b.grid, pts)
    ORDER BY points.row_num;


