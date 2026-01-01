select count(*)
from locations;

select count(*)
from make_details;

select count(*)
from stolen_vehicles;


-- key columns to be joined - location_id, make_id

-- main query to work on
with main_query as (
SELECT 
	sv.vehicle_id,
    sv.vehicle_type,
    sv.make_id,
    sv.model_year,
    sv.vehicle_desc,
    sv.color,
    sv.date_stolen,
    sv.location_id,
    md.make_name,
    md.make_type,
    l.region,
    l.country,
    l.population,
    l.density
FROM
    stolen_vehicles sv
        LEFT JOIN
    make_details md ON sv.make_id = md.make_id
        LEFT JOIN
    locations l ON sv.location_id = l.location_id)
    
-- checking for Null values in the dataset
-- column vehicle type has 26 null values

select count(case when vehicle_type is null then 1 end) as vehicle_type_nulls,
	   count(case when make_id is null then 1 end) as make_id_nulls,
       count(case when model_year is null then 1 end) as model_year_nulls,
       count(case when vehicle_desc is null then 1 end) as vehicle_desc_nulls,
       count(case when color is null then 1 end) as color_nulls,
       count(case when date_stolen is null then 1 end) as date_stolen_nulls,
       count(case when location_id is null then 1 end) as vehicle_type_nulls,
       count(case when make_name is null then 1 end) as make_name_nulls,
       count(case when make_type is null then 1 end) as make_type_nulls,
       count(case when region is null then 1 end) as region_nulls,
       count(case when country is null then 1 end) as country_nulls,
       count(case when population is null then 1 end) as population_nulls,
       count(case when density is null then 1 end) as density_nulls
from main_query;


-- taking a look into the NULL values and trying to see if there is a pattern
-- the Null values cannot be dropped as they are vital to the analysis
-- There are NULL values but the date on which the car/vehicle was stolen is recorded
-- so the Null values cannot be dropped for the purpose of our analysis
SELECT 
	sv.vehicle_id,
    sv.vehicle_type,
    sv.make_id,
    sv.model_year,
    sv.vehicle_desc,
    sv.color,
    sv.date_stolen,
    sv.location_id,
    md.make_name,
    md.make_type,
    l.region,
    l.country,
    l.population,
    l.density
FROM
    stolen_vehicles sv
        LEFT JOIN
    make_details md ON sv.make_id = md.make_id
        LEFT JOIN
    locations l ON sv.location_id = l.location_id
where sv.vehicle_type is null or sv.make_id is null or model_year is null or vehicle_desc is null or color is null or make_name is null or make_type is null;




-- what day of the week are the vehicles most often and least often stolen

SELECT 
    DAYNAME(date_stolen) AS day_name,
    COUNT(*) AS stolen_vehicle_count
FROM
    stolen_vehicles
GROUP BY 1
ORDER BY 2 DESC;


-- what type of vehicles are most often and least often stolen? does this vary by region ?

SELECT 
    vehicle_type, COUNT(*) AS vehicle_types_stolen
FROM
    stolen_vehicles
GROUP BY 1
ORDER BY 2 DESC;

-- the most stolen vehicle type includes the Stationwagon, Saloon, Hatchback
-- the least stolen with a count less than 5 is Articulated Truck, Special Purpose vehicle, Mobile machine, Trail bike, Tractor

-- changing the data type of the location_id column in the locations table

alter table locations
modify column location_id INT;

-- changing the data type of the location_id column in stolen_vehicles table to INT
alter table stolen_vehicles
modify column location_id INT;

SELECT 
    vehicle_type, region, count(vehicle_id) as vehicles_stolen_by_region
FROM
    stolen_vehicles sv
        LEFT JOIN
    locations l ON sv.location_id = l.location_id
group by 1, 2
order by region, vehicles_stolen_by_region desc;



-- trying to identify if there is a trend in the thefts

-- query by the monthly trend
SELECT 
	monthname(date_stolen) name_of_month,
    year(date_stolen) stolen_year,
    count(*) as total_thefts
FROM
    stolen_vehicles
group by
	1,2
order by year(date_stolen), month(date_stolen);

-- query to find the daily trend

SELECT 
    date_stolen, COUNT(vehicle_id) AS daily_theft_count
FROM
    stolen_vehicles
GROUP BY DAY(date_stolen) , MONTH(date_stolen) , YEAR(date_stolen)
ORDER BY YEAR(date_stolen) , MONTH(date_stolen) , DAY(date_stolen);



-- clearly there has been an increasing trend of the thefts happening since october to March
-- and since we have data until the 6th of april, 2022, April itself has 329 thefts
SELECT 
    *
FROM
    stolen_vehicles
WHERE
    MONTHNAME(date_stolen) = 'April'
        AND YEAR(date_stolen) = 2022
ORDER BY DAY(date_stolen);


-- finding the average age of the vehicles stolen

select round(avg(year(date_stolen) - model_year),0) as average_age_of_stolen_cars
from stolen_vehicles;

-- average age of the stolen cars is 16 years

-- checking to see if the average age vary based on vehicle type of the stolen vehicle
select coalesce(vehicle_type, 'Unknown') as vehicle_type,  round(avg(year(date_stolen) - model_year),0) as average_age_of_stolen_cars
from stolen_vehicles
group by vehicle_type
order by 2 desc;

-- Special Purpose vehicle has the highest average because there is only one special purpose vehicle that has been stolen
-- The Null value has been replaced by "unknown" to aid for the analysis
-- the average age does differ by the different vehicle type


SELECT 
    COALESCE(color, 'Unknown') AS color,
    COUNT(*) AS most_stolen_colors
FROM
    stolen_vehicles
GROUP BY color
ORDER BY 2 DESC;

-- from the above query it is evident that Silver color is the most stolen color
-- followed by White, Black and Blue with more than 500 theft counts in the last 6 months
-- pink color is the least stolen color


-- finding the make and the model name having the most thefts
-- the criteria that I have kept is that there should be atleast 5 thefts for the make and the model

SELECT 
    md.make_name,
    sv.vehicle_desc,
    COUNT(*) AS popular_make_model_thefts
FROM
    make_details md
        LEFT JOIN
    stolen_vehicles sv ON md.make_id = sv.make_id
GROUP BY make_name , vehicle_desc
HAVING COUNT(*) >= 5
ORDER BY popular_make_model_thefts DESC;

-- the most popular make and model thefts are for the Toyota Hilux
-- followed by Ford Courier
-- and Mazda Demio
-- The least stolen make and model combinations include BMW 335i, Volkswagen POLO

-- which regions has the most and the least number of stolen vehicles

SELECT 
    region, COUNT(sv.location_id) AS thefts_per_region
FROM
    locations l
        LEFT JOIN
    stolen_vehicles sv ON l.location_id = sv.location_id
GROUP BY region
ORDER BY 2 DESC;

-- Most number of the Vehicle thefts are happening in Auckland followed by Canterbury and Bay of Plenty
-- There are no theft records in Tasman, Marlborough and the West Coast


SELECT 
    region,
    population,
    density,
    COUNT(*) AS total_thefts_per_region
FROM
    locations l
        LEFT JOIN
    stolen_vehicles sv ON l.location_id = sv.location_id
GROUP BY region
ORDER BY total_thefts_per_region DESC;


-- trying to find the pearson correlation between population and the total thefts per region

SELECT 
    (COUNT(*) * SUM(population * total_thefts_per_region) - SUM(population) * SUM(total_thefts_per_region)) / SQRT((COUNT(*) * SUM(population * population) - SUM(population) * SUM(population)) * (COUNT(*) * SUM(total_thefts_per_region * total_thefts_per_region) - SUM(total_thefts_per_region) * SUM(total_thefts_per_region))) AS correlation_measure
FROM
    (SELECT 
        region,
            population,
            density,
            COUNT(*) AS total_thefts_per_region
    FROM
        locations l
    LEFT JOIN stolen_vehicles sv ON l.location_id = sv.location_id
    GROUP BY region) pc;
    
    
-- as per the correlation analysis, there is a high correlation of 0.9821 between population and total thefts per region
-- So, the thefts are mainly happening more in populous areas but we need more data to confirm if there are any factors
-- associated with the number of thefts in a populous region







