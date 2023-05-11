'''Creating tables and inserting values into the database for storing 
metadata survey information from csv file'''

__author__ = "François d'Entremont"

from os import environ

environ['PROJ_LIB'
        ] = r'C:\Users\w0483484\.conda\envs\prog5000\Library\share\proj'

import csv
import psycopg2

csv.field_size_limit(2147483647)

conn = psycopg2.connect('dbname=assignment3 user=postgres password=postgres')
cursor = conn.cursor()
# Check the character encoding for the connection
print(conn.encoding)
# It's UTF8

# Creating tables in the database to store the metadata survey
ddl = """
        create table surveying.originator (
            id             serial primary key,
            name           varchar(32)
        );

        create table surveying.location (
            id             serial primary key,
            name           varchar(40)
        );

        create table surveying.ocean (
            id             serial primary key,
            name           varchar(32)
        );

        create table surveying.survey (
            metadata_identifier     char(36) primary key,
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
"""
# Execute the query
with conn:
    cursor.execute(ddl)

# Insert queries - which are parameterized
dml_originator = """insert into surveying.originator (name) values (%s)"""
dml_location = """insert into surveying.location (name) values (%s)"""
dml_ocean = """insert into surveying.ocean (name) values (%s)"""
dml_survey = """insert into surveying.survey 
                values (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"""

# Count the row in the survey table with the identifiers
dql_ocean = """
            select count(s.ocean_id)
            from surveying.survey s
            where s.ocean_id = %s
"""
dql_originator = """
            select count(s.originator_id)
            from surveying.survey s
            where s.originator_id = %s
"""
dql_location = """
            select count(s.location_id)
            from surveying.survey s
            where s.location_id = %s
"""
# Insert the data from the metadata-survey csv file
with (open('metadata-survey.csv', 'r', encoding='utf-8') as mds, conn):
    # Create a csv reader - in this case the data is delimited by comma
    reader = csv.reader(mds)
    next(reader)
    # For each of the rows in the source data
    for row in reader:
        cursor.execute(dql_ocean, (row[1], ))
        ocean_count = cursor.fetchone()[0]
        
        cursor.execute(dql_originator, (row[8], ))
        originator_count = cursor.fetchone()[0]

        cursor.execute(dql_location, (row[3], ))
        location_count = cursor.fetchone()[0]

        # If the count is 0 then insert the row
        if ocean_count == 0:
            cursor.execute(dml_ocean, (row[1], ))

        if originator_count == 0:
            cursor.execute(dml_originator, (row[8], ))

        if location_count == 0:
           cursor.execute(dml_location, (row[3], ))
           
        # Insert the survey data for the current row
        cursor.execute(dml_survey, (row[0], row[1], row[2], row[3],
        row[4],row[5],row[6],row[7],row[8], row[9], ))

