-- I think some of these links might help
-- https://www.postgresql.org/docs/13/queries-with.html
-- https://www.crunchydata.com/blog/postgis-raster-and-crunchy-bridge
-- https://www.crunchydata.com/blog/elevation-profiles-and-flightlines-with-postgis
with path as (
	-- I think that the function ST_Segmentize might be used here somehow
),
points as (
	select row_number() over () as row_num, p.points
	from (
		-- I think that the function ST_DumpPoints might be used here somehow
	) p
)
-- I think this part will return a result set containing the distances
-- along the cable route. But I don't know how the extract the elevation
-- values from the raster dataset. Can you please help?
select (points.row_num - 1) * 50 as distance
from points, bathymetry.dem b
where ST_Intersects(b.grid, points)
order by points.row_num;