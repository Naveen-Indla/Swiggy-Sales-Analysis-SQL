SELECT * FROM Swiggy_Data
SELECT 
	SUM(CASE WHEN State IS NULL THEN 1 ELSE 0 END) AS null_state,
	SUM(CASE WHEN City IS NULL THEN 1 ELSE 0 END) AS null_city,
	SUM(CASE WHEN Order_Date IS NULL THEN 1 ELSE 0 END) AS null_order_date,
	SUM(CASE WHEN Order_Date IS NULL THEN 1 ELSE 0 END) AS null_order_date,
	SUM(CASE WHEN Restaurant_Name IS NULL THEN 1 ELSE 0 END) AS null_restaurant,
	SUM(CASE WHEN Location IS NULL THEN 1 ELSE 0 END) AS null_location,
	SUM(CASE WHEN Category IS NULL THEN 1 ELSE 0 END) AS null_category,
	SUM(CASE WHEN Dish_Name IS NULL THEN 1 ELSE 0 END) AS null_dish,
	SUM(CASE WHEN Price_INR IS NULL THEN 1 ELSE 0 END) AS null_price,
	SUM(CASE WHEN Rating IS NULL THEN 1 ELSE 0 END) AS null_rating,
	SUM(CASE WHEN Rating_Count IS NULL THEN 1 ELSE 0 END)AS null_rating_count 
FROM Swiggy_Data

--CHECKING FOR BLANKS OR EMPTY STRINGS
SELECT *
FROM Swiggy_Data
WHERE 
State = '' OR City = '' OR Restaurant_Name = '' OR Location = '' OR Category = '' OR Dish_Name = ''


--IDENTIFYING DUPLICATES OR DUPLICATES DECTECTION
SELECT 
State, City,order_date,restaurant_name, location, category,
Dish_Name, price_INR, rating ,rating_count , COUNT(*) as CNT
FROM Swiggy_Data
GROUP BY 
State, City,order_date,restaurant_name, location, category,
Dish_Name, price_INR, rating ,rating_count 
HAVING  count(*)>1

--DELETING THE DUPLICATES 
WITH CTE AS (
SELECT *, ROW_NUMBER() OVER(
	PARTITION BY State, City,order_date,restaurant_name, location, category,
Dish_Name, price_INR, rating ,rating_count 
ORDER  BY (SELECT NULL)
) AS rn
FROM Swiggy_Data
)
DELETE FROM CTE WHERE rn > 1

--CREATING SCHEMA 
--CREATING DIMENSION TABLES 
--dim_date(DIMENSIONAL DATE TABLE)
CREATE TABLE dim_date(
	date_id INT IDENTITY(1,1) PRIMARY KEY,
	Full_Date DATE,
	Year INT,
	Month INT,
	Month_Name VARCHAR(20),
	Quarter INT,
	Day INT,
	Week INT
	)

--dim_location (DIMENSIONAL LOCATION TABLE)
CREATE TABLE dim_location(
	location_id INT IDENTITY(1,1) PRIMARY KEY,
	State VARCHAR(100),
	City VARCHAR(100),
	Location VARCHAR(200)
	);

--dim_restaurant(DIMENSIONAL RESTAURENT TABLE)
CREATE TABLE dim_restaurant (
	restaurant_id INT IDENTITY(1,1) PRIMARY KEY,
	Restaurant_Name VARCHAR(200)
	);

--dim_category(DIMENSIONAL CATEGORY TABLE)
CREATE TABLE dim_category(
	category_id INT IDENTITY(1,1) PRIMARY KEY,
	Category VARCHAR(200)
	);

--dim_dish(DIMENSIONAL DISH TABLE)
CREATE TABLE dim_dish(
	dish_id INT IDENTITY(1,1) PRIMARY KEY,
	Dish_Name VARCHAR(200)
	);


SELECT *FROM swiggy_data

--CREATING FACT TABLE 
CREATE TABLE fact_swiggy_orders (
	order_id INT IDENTITY(1,1) PRIMARY KEY,

	date_id INT,
	Price_INR DECIMAL(10,2),
	Rating DECIMAL(4,2),
	Rating_Count INT,

	location_id INT,
	restaurant_id INT,
	category_id INT,
	dish_id INT,
	
	FOREIGN KEY (date_id) REFERENCES dim_date(date_id),
	FOREIGN KEY (location_id) REFERENCES dim_location(location_id),
	FOREIGN KEY (restaurant_id) REFERENCES dim_restaurant(restaurant_id),
	FOREIGN KEY (category_id) REFERENCES dim_category(category_id),
	FOREIGN KEY (dish_id) REFERENCES dim_dish(dish_id)
);
SELECT * FROM fact_swiggy_orders;

--INSERTING DATA INTO TO ALL TABLES 
--INSERING DATA TO dim_date
INSERT INTO dim_date(Full_Date,Year,Month, Month_Name,Quarter,Day,Week)
SELECT DISTINCT
	Order_Date,
	YEAR(Order_Date),
	MONTH(Order_Date),
	DATENAME(MONTH,Order_Date),
	DATEPART(QUARTER,Order_Date),
	DAY(Order_Date),
	DATEPART(WEEK,Order_Date)
FROM swiggy_data
WHERE Order_Date IS NOT NULL;

SELECT * FROM dim_date;

--INSERTING DATA INTO dim_location
INSERT INTO dim_location(State,City,Location)
SELECT DISTINCT
	State,
	City,
	Location
FROM swiggy_data

SELECT * FROM dim_location

--INSERTING DATA INTO dim_restaurant
INSERT INTO dim_restaurant(Restaurant_Name)
SELECT DISTINCT
	Restaurant_Name
FROM swiggy_data

SELECT  * FROM dim_restaurant

--INSERTING DATA INTO dim_category
INSERT INTO dim_category(category)
SELECT DISTINCT
	Category
FROM swiggy_data

SELECT * FROM dim_category

--INSERTING DATA INTO dim_dish
INSERT INTO dim_dish(Dish_Name)
SELECT DISTINCT 
	Dish_Name
FROM swiggy_data

SELECT * FROM dim_dish



--INSERTING DATA IN FACT TABLE 
INSERT INTO fact_swiggy_orders
(
	date_id,
	Price_INR,
	Rating,
	Rating_Count,
	location_id,
	restaurant_id,
	category_id,
	dish_id
)
SELECT 
	dd.date_id,
	s.Price_INR,
	s.Rating,
	s.Rating_Count,

	dl.location_id,
	dr.restaurant_id,
	dc.category_id,
	dsh.dish_id

FROM swiggy_data  AS s

JOIN dim_date dd
	ON dd.full_date =s.Order_Date

JOIN dim_location dl
	ON dl.State = s.State
	AND dl.City = s.City
	AND dl.Location = s.Location

JOIN dim_restaurant dr
	ON dr.Restaurant_Name = s.Restaurant_Name
	
JOIN dim_category dc
	ON dc.Category = s.Category

JOIN dim_dish dsh
	ON dsh.Dish_Name = s.Dish_Name;
	
SELECT *
FROM fact_swiggy_orders --THIS ID'S ARE USED TO JOIN THE DIMENSIONAL TABLES 

SELECT * FROM fact_swiggy_orders f
JOIN dim_date d ON f.date_id = d.date_id
JOIN dim_location l ON f.location_id = l.location_id
JOIN dim_restaurant r ON f.restaurant_id = r.restaurant_id
JOIN dim_category c ON f.category_id = c.category_id
JOIN dim_dish di ON f.dish_id = di.dish_id

--KEY PERFORMANCE INDICATORS(KPI'S)
--TOTAL ORDERS
SELECT COUNT(*) AS Total_Orders
FROM fact_swiggy_orders

--TOTAL REVENUE (INR Million)
SELECT 
FORMAT(SUM(CONVERT(FLOAT,Price_INR))/1000000, 'N2')+ 'INR MILLION'
AS Total_Revenue
FROM fact_swiggy_orders

--AVERAGE DISH PRICE
SELECT 
FORMAT(AVG(CONVERT(FLOAT,Price_INR)),'N2')+ 'INR'
AS Avg_Dish_Price
FROM fact_swiggy_orders

--AVERAGE RATING
SELECT 
AVG(Rating) AS Avg_Rating 
FROM fact_swiggy_orders




--DEEP-DIVE INTO BUSINESS ANALYSIS
--MONTHLY ORDER TRENDS
SELECT 
d.year,
d.month,
d.month_name,
count(*) as Total_Orders
FROM fact_swiggy_orders f
JOIN dim_date d on f.date_id = d.date_id
GROUP BY d.year,
d.month,
d.month_name
ORDER BY count(*) DESC 

--MONTHLY TOTAL REVENUE 
SELECT 
d.year,
d.month,
d.month_name,
SUM(Price_INR) AS Total_Revenue
FROM fact_swiggy_orders f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY d.year,
d.month,
d.month_name
ORDER BY  SUM(Price_INR) DESC

--QUARTERLY TREND
SELECT 
d.year,
d.quarter,
count(*) AS Total_Orders
FROM fact_swiggy_orders f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY d.year,
d.quarter
ORDER BY count(*) DESC

--YEARLY-WISE GROWTH TREND
SELECT 
d.year,
count(*) AS Total_Orders
FROM fact_swiggy_orders f 
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY d.year
ORDER BY count(*) DESC

--ORDERS RECIEVED  BY DAY OF WEEK(MON-SUN)
SELECT
	DATENAME(WEEKDAY, d.full_date)AS day_name,
	COUNT(*) AS Total_Orders
FROM fact_swiggy_orders f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY DATENAME(WEEKDAY, d.full_date), DATEPART(WEEKDAY,d.full_date)
ORDER BY DATEPART(WEEKDAY,d.full_date);




--LOCATION BASED ANALYSIS
--TOP 10 CITIES BY ORDER VOLUME
SELECT TOP 10
l.city, 
COUNT(*) AS Total_Orders
FROM fact_swiggy_orders f
JOIN dim_location l
ON l.location_id =f.location_id
GROUP  BY l.city
ORDER BY COUNT(*) DESC

--TOP 10 CITIES BY REVENUE 
SELECT TOP 10 
l.city,
SUM(f.Price_INR) AS Total_Revenue FROM fact_swiggy_orders f
JOIN dim_location l
ON l.location_id = f.location_id
GROUP BY l.city
ORDER BY SUM(Price_INR) DESC

--REVENUE CONTRIBUTION BY STATES
SELECT 
l.state,
SUM(f.Price_INR) AS Total_Revenue FROM fact_swiggy_orders f
JOIN dim_location l
On l.location_id = f.location_id
GROUP BY l.State
ORDER BY SUM(f.Price_INR) DESC




--FOOD PERFORMANCE 
--TOP 10 RESTAURANT  BY ORDERS
SELECT TOP 10
r.restaurant_name,
SUM(f.Price_INR) AS Total_Revenue FROM fact_swiggy_orders f
JOIN dim_restaurant r
ON r.restaurant_id = f.restaurant_id
GROUP BY r.Restaurant_Name
ORDER  BY SUM(f.Price_INR) DESC

--TOP CATEGORIES BY ORDER VOLUME
SELECT c.category,COUNT(*) As Total_Orders
FROM fact_swiggy_orders f
JOIN dim_category c ON f.category_id = c.category_id
GROUP BY c.Category
ORDER BY Total_Orders DESC

--MOST ORDERED DISHES 
SELECT TOP 10
d.dish_name,
COUNT(*) AS Order_Count
FROM fact_swiggy_orders f
JOIN dim_dish d ON f.dish_id = d.dish_id
GROUP BY d.dish_name
ORDER BY Order_Count DESC

--CUISINE PERFORMANCE (ORDERS+AVERAGE RATING)
SELECT	
	c.category,
	COUNT(*) AS Total_Orders,
	AVG(f.rating)AS avg_rating
FROM fact_swiggy_orders f
JOIN dim_category c ON f.category_id = c.category_id
GROUP BY c.Category
ORDER BY Total_Orders DESC




--TOTAL ORDERS BY PRICE RANGE
SELECT 
	CASE 
		WHEN CONVERT(FLOAT, Price_INR)<100 THEN 'Under 100'
		WHEN CONVERT(FLOAT, Price_INR) BETWEEN 100 AND 199 THEN '100-199'
		WHEN CONVERT(FLOAT, Price_INR) BETWEEN 200 AND 299 THEN '200-299'
		WHEN CONVERT(FLOAT, pricE_INR) BETWEEN 300 AND 499 THEN '300-499'
		ELSE '500+'
	END AS Price_Range,
	COUNT (*) AS Total_Orders
FROM fact_swiggy_orders 
GROUP BY 
	CASE
		WHEN CONVERT(FLOAT, Price_INR)<100 THEN 'Under 100'
		WHEN CONVERT(FLOAT, Price_INR) BETWEEN 100 AND 199 THEN '100-199'
		WHEN CONVERT(FLOAT, Price_INR) BETWEEN 200 AND 299 THEN '200-299'
		WHEN CONVERT(FLOAT, pricE_INR) BETWEEN 300 AND 499 THEN '300-499'
		ELSE '500+' 
	END 
ORDER BY Total_Orders DESC



--RATING ANALYSIS
--RATING COUNT DISTRIBUTED (1-5)
SELECT 
	rating,
	COUNT(*) AS rating_count
FROM  fact_swiggy_orders
GROUP BY rating
ORDER BY Rating DESC

