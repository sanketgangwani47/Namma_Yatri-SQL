CREATE DATABASE namma_yatri;
USE namma_yatri;

-- TOTAL DRIVERS
SELECT COUNT(DISTINCT driverid) AS "No_Of_drivers"
FROM trips;

-- TOTAL EARNINGS
SELECT SUM(fare) AS "Total_Revenue"
FROM trips;

-- TOTAL SEARCHES
SELECT COUNT(*) AS "Total_Searches"
FROM trip_details;

-- TOTAL SUCCESSFUL TRIPS
SELECT COUNT(*) AS "Total_Successful_Trips" 
FROM trip_details
WHERE end_ride = 1;

-- PERCENTAGE OF CUSTOMERS THAT SEARCHED FOR A RIDE AND LATER COMPLETED THE RIDE
SELECT 
CONCAT((COUNT(*)/(SELECT COUNT(*) FROM trip_details) )* 100 ,"%") AS "Percentage"
FROM trip_details
WHERE end_ride = 1;

-- TOTAL TRIPS THAT GOT CANCELLED BY DRIVER
SELECT COUNT(*) AS "No_Of_Trips"
FROM trip_details
WHERE driver_not_cancelled = 0;

-- AVERAGE DISTANCE PER TRIP
SELECT AVG(distance) AS "Average_Distance"
FROM trips;

-- AVERAGE FARE PER TRIP
SELECT AVG(fare) AS "Average_Fare"
FROM trips;

-- NUMBER OF TRIPS & REVENUE CONTRIBUTION BY EACH METHOD
SELECT *,
(Total_Revenue/(SELECT SUM(fare) FROM trips))*100 AS "Percentage_Contribution_In_Total_Revenue" 
FROM 
(SELECT p.method AS "Method",COUNT(p.method) AS "Total_Trips",
SUM(t.fare) AS Total_Revenue FROM trips AS t
JOIN payment AS p
ON t.faremethod = p.id
GROUP BY p.method) a
ORDER BY Total_Revenue DESC;

-- ROUTE WITH MOST NUMBER OF TRIPS
WITH my_cte AS
(SELECT loc_from,loc_to,COUNT(*) AS "No_Of_Trips"
FROM trips 
GROUP BY loc_from,loc_to
ORDER BY COUNT(*) DESC) 
SELECT * FROM my_Cte 
WHERE No_Of_Trips = (SELECT MAX(No_Of_Trips) FROM my_cte);


-- TOP 5 DRIVERS WITH MOST EARNINGS AND THEIR TOTAL TRIPS
SELECT driverid,Total_Trips,Total_Earnings FROM
(SELECT *,DENSE_RANK() OVER(ORDER BY Total_Earnings DESC) AS Rnk FROM 
(SELECT driverid,COUNT(driverid) AS "Total_Trips",SUM(fare) AS "Total_Earnings"
FROM trips
GROUP BY driverid) a) b
WHERE Rnk<6;

-- WHICH DURATION BUCKET HAD MOST NUMBER OF TRIPS
SELECT duration,Total_Trips FROM
(SELECT *,DENSE_RANK() OVER(ORDER BY Total_Trips DESC) AS Rnk FROM
(SELECT d.duration,COUNT(d.duration) AS "Total_Trips" FROM trips AS t
JOIN duration AS d
ON t.duration = d.id
GROUP BY d.duration) a) b
WHERE Rnk = 1;

-- AREAWISE CONTRIBUTION IN TOTAL REVENUE
SELECT *,(Revenue/(SELECT SUM(fare) FROM trips))*100 AS "%_Contribution" FROM
(SELECT Assembly AS Area,COUNT(tripid) AS "Trips",SUM(fare) AS "Revenue" 
FROM trips AS t
JOIN assembly AS a 
ON t.loc_from = a.id
GROUP BY Assembly
ORDER BY SUM(fare) DESC) a;

-- AREA WITH MOST NUMBER OF DRIVER CANCELLATIONS
SELECT Assembly AS "Area",Trips_Cancelled FROM
(SELECT *,DENSE_RANK() OVER(ORDER BY Trips_Cancelled DESC) AS Rnk FROM
(SELECT a.Assembly,COUNT(a.Assembly) AS "Trips_Cancelled" FROM trip_details AS t
JOIN Assembly AS a
ON t.loc_from = a.id
WHERE driver_not_cancelled = 0
GROUP BY a.Assembly) a) b
WHERE Rnk = 1;

-- AREA WITH MOST NUMBER OF TRIPS
SELECT Area,No_of_trips FROM
(SELECT *,DENSE_RANK() OVER(ORDER BY No_of_trips DESC) AS "Rnk" FROM
(SELECT a.Assembly AS "Area",COUNT(a.Assembly) AS "No_of_trips" FROM trips AS t
JOIN Assembly AS a
ON t.loc_from = a.id 
GROUP BY a.Assembly) a)b
WHERE Rnk = 1;

-- DURATION BUCKET WITH MOST NUMBER OF TRIPS AND TOTAL REVENUE GENERATED
SELECT duration,No_Of_Trips,Total_Revenue FROM
(SELECT *,DENSE_RANK() OVER(ORDER BY No_Of_trips DESC) AS Rnk FROM
(SELECT d.duration,COUNT(d.duration) AS "No_Of_Trips",
SUM(t.fare) AS "Total_Revenue" FROM trips AS t
JOIN duration AS d
ON t.duration = d.id
GROUP BY d.duration) a) b
WHERE Rnk = 1;