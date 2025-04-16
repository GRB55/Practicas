-- Analisis de datos exploratorio (EDA)

SELECT *
FROM Bengaluru_Ola_Booking_Data
WHERE [Booking Status] = 'Success';

SELECT [Vehicle Type], AVG(CAST([Ride Distance] AS FLOAT)) AS Avg_Ride_Dist
FROM Bengaluru_Ola_Booking_Data
GROUP BY [Vehicle Type];

SELECT COUNT(*)
FROM Bengaluru_Ola_Booking_Data
WHERE [Booking Status] = 'Cancelled by customer';

SELECT TOP 5 [Customer ID], COUNT([Booking ID]) AS Total_rides
FROM Bengaluru_Ola_Booking_Data
GROUP BY [Customer ID]
ORDER BY Total_rides DESC;

SELECT COUNT(*)
FROM Bengaluru_Ola_Booking_Data
WHERE [Reason for Cancelling by Driver] = 'Personal & Car related issues';

SELECT MIN([Driver Ratings]) AS Min_Driver_rating, MAX([Driver Ratings]) AS Max_driver_rating
FROM Bengaluru_Ola_Booking_Data
WHERE [Vehicle Type] = 'Prime Sedan'
AND [Driver Ratings] <> '';


SELECT *
FROM Bengaluru_Ola_Booking_Data
WHERE [Payment Method] = 'UPI';

SELECT [Vehicle Type], AVG(CAST([Customer Rating] AS FLOAT)) AS Avg_customer_rating
FROM Bengaluru_Ola_Booking_Data
GROUP BY [Vehicle Type];

SELECT SUM(CAST([Booking Value] AS FLOAT))
FROM Bengaluru_Ola_Booking_Data
WHERE [Booking Status] = 'Success';

SELECT [Incomplete Rides], [Incomplete Rides Reason]
FROM Bengaluru_Ola_Booking_Data
WHERE [Incomplete Rides] = 1;

SELECT [Time], COUNT(*) AS Total_Usage
FROM Bengaluru_Ola_Booking_Data
GROUP BY [Time]
ORDER BY Total_Usage DESC;



