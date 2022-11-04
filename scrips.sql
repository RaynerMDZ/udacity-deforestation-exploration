-- Tables to insert data to local database.
CREATE TABLE forest_area (
    country_code VARCHAR,
    country_name VARCHAR,
    year SMALLINT,
    forest_area_sqkm DOUBLE PRECISION
);

CREATE TABLE land_area (
    country_code VARCHAR,
    country_name VARCHAR,
    year SMALLINT,
    total_area_sq_mi DOUBLE PRECISION
);

CREATE TABLE regions (
    country_name VARCHAR,
    country_code VARCHAR,
    region VARCHAR,
    income_group VARCHAR
);

-- Part #1
WITH table_1990 AS (SELECT country_code, SUM(COALESCE(forest_area_sqkm, 0)) AS forest_area_sqkm
                    FROM forest_area
                    WHERE year = 1990 AND country_name = 'World'
                    GROUP BY 1),
    table_2016 AS (SELECT country_code, SUM(COALESCE(forest_area_sqkm, 0)) AS forest_area_sqkm
                    FROM forest_area
                    WHERE year = 2016 AND country_name = 'World'
                    GROUP BY 1)
SELECT a.forest_area_sqkm AS year_1990,
       b.forest_area_sqkm AS year_2016,
       (a.forest_area_sqkm - b.forest_area_sqkm) AS difference,
       (((a.forest_area_sqkm - b.forest_area_sqkm) / a.forest_area_sqkm) * 100) AS percentage
FROM table_1990 a
JOIN table_2016 b ON a.country_code = b.country_code;

SELECT *, (total_area_sq_mi * 2.58999) total_area_sq_km
FROM land_area
WHERE year = 2016 AND (total_area_sq_mi * 2.58999) < 1324449
ORDER BY year, total_area_sq_mi DESC;