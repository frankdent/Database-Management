""" Raster interpolation """

__author__ = "François d'Entremont"

from os import environ

environ['PROJ_LIB'
        ] = r'C:\Users\w0483484\.conda\envs\prog5000\Library\share\proj'

import csv
import psycopg2

with open('deconflicted-soundings.csv', 'r') as bathy:
    reader = csv.reader(bathy)
    # The points are in the SRID:4326 coordinate system which has axis order
    # latitude, longitude. MULTIPOINT Z in wkt requires X Y Z ordering.
    # A wkt string is created by appending the soundings information one point
    # at a time into the string. We have an extra comma and space at the end 
    # so we have to remove the two last characters and add a closing 
    # parenthesis.  
    multipoint = 'SRID=4326;MULTIPOINT Z ('
    for row in reader:
        multipoint += f'{row[1]} {row[0]} {row[2]}, '
    multipoint = multipoint[:-2] + ')'
# Connect to the database
conn = psycopg2.connect('dbname=assignment3 user=postgres password=postgres')
cursor = conn.cursor()
with conn:
    sql = """insert into bathymetry.dem (grid) values (ST_InterpolateRaster(
                ST_Transform(%s::geometry, 25831),
                'linear:nodata:-9999:radius:0',
                ST_AddBand(ST_MakeEmptyRaster(3100, 1400, 288800, 6004800,
                10, -10, 0, 0, 25831), '32BF'))
    )"""
    cursor.execute(sql, (multipoint,))