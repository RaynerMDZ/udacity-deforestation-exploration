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

-- Global Situation
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

-- Regional Outlook
-- Part 1
WITH data AS (SELECT
    r.region,
    fa.country_code,
    fa.country_name,
    fa.year,
    fa.forest_area_sqkm AS forest_area,
    la.total_area_sq_km AS land_area,
    (la.total_area_sq_km - fa.forest_area_sqkm ) AS difference,
    ((fa.forest_area_sqkm / la.total_area_sq_km) * 100) AS forest_percentage_in_country
FROM forest_area fa
INNER JOIN (
        SELECT country_code, country_name, year, (total_area_sq_mi * 2.58999) AS total_area_sq_km
        FROM land_area) la
    ON fa.country_code = la.country_code AND fa.year = la.year
INNER JOIN regions r
    ON fa.country_code = r.country_code
WHERE fa.year IN (1990, 2016) AND la.year IN (1990, 2016)
ORDER BY fa.country_code)

SELECT region, year , (SUM(forest_area) / SUM(land_area)) * 100 AS percentage_per_region
FROM data
WHERE year = 1990
GROUP BY 1, 2
ORDER BY 3 DESC;

-- Part 2
WITH data AS (SELECT
    r.region,
    fa.country_code,
    fa.country_name,
    fa.year,
    fa.forest_area_sqkm AS forest_area,
    la.total_area_sq_km AS land_area,
    (la.total_area_sq_km - fa.forest_area_sqkm ) AS difference,
    ((fa.forest_area_sqkm / la.total_area_sq_km) * 100) AS forest_percentage_in_country
FROM forest_area fa
INNER JOIN (
        SELECT country_code, country_name, year, (total_area_sq_mi * 2.58999) AS total_area_sq_km
        FROM land_area) la
    ON fa.country_code = la.country_code AND fa.year = la.year
INNER JOIN regions r
    ON fa.country_code = r.country_code
WHERE fa.year IN (1990, 2016) AND la.year IN (1990, 2016)
ORDER BY fa.country_code),

percentage_1990 AS (SELECT * FROM data WHERE year = 1990),
percentage_2016 AS (SELECT * FROM data WHERE year = 2016)

SELECT a.region,
       (SUM(a.forest_area) / SUM(a.land_area)) * 100 AS percentage_per_regionin_1990,
       (SUM(b.forest_area) / SUM(b.land_area)) * 100 AS percentage_per_regionin_2016,
       CASE
           WHEN ((SUM(b.forest_area) / SUM(b.land_area)) * 100) < ((SUM(a.forest_area) / SUM(a.land_area)) * 100) THEN 'yes'
           ELSE 'no'
       END AS decreased
FROM percentage_1990 a
JOIN percentage_2016 b
ON a.country_code = b.country_code
GROUP BY 1;
