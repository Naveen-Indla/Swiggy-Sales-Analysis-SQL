# 🍔 Swiggy Sales Analysis (SQL Project)

## 📌 Project Overview
This project is an **end-to-end SQL data analytics project** built using **Microsoft SQL server Management Studio**.  
The objective is to clean raw Swiggy sales data, design an analytics-ready data model, and extract meaningful business insights using SQL.

This project follows **real-world data analytics practices** and is suitable for **entry-level Data Analyst roles**.


## 🛠️ Tools & Technologies
- **Database:** MySQL  
- **SQL IDE:** Microsoft SQL Server Management Studio  
- **Data Source:** CSV file , Excel File
- **Data Model:** Star Schema  


## 📂 Dataset Description
The dataset contains food delivery transaction data with the following columns:
- State  
- City  
- Order Date  
- Restaurant Name  
- Location  
- Category (Cuisine)  
- Dish Name  
- Price (INR)  
- Rating  
- Rating Count  


## 🧹 Data Cleaning & Validation
The following data quality checks were performed:

### ✅ Null Value Check
- Identified missing values across all critical columns

### ✅ Blank / Empty Value Check
- Removed records containing empty strings that could affect analysis

### ✅ Duplicate Detection & Removal
- Used `ROW_NUMBER()` to detect duplicate records
- Retained only one unique record per order
- Created a cleaned dataset for analytics


## ⭐ Data Modelling (Star Schema)

### Dimension Tables
- **dim_date** → Date, Year, Month, Quarter, Week  
- **dim_location** → State, City, Location  
- **dim_restaurant** → Restaurant Name  
- **dim_category** → Cuisine / Category  
- **dim_dish** → Dish Name  

### Fact Table
- **fact_swiggy_orders**
  - Price (INR)
  - Rating
  - Rating Count
  - Dimension IDs for analysis joins

> Foreign keys were intentionally avoided to ensure smooth execution and error-free analytics during development.


## 📊 Key Performance Indicators (KPIs)
- Total Orders  
- Total Revenue (INR Million)  
- Average Dish Price  
- Average Rating  


## 📈 Business Analysis Performed

### 🗓️ Date-Based Analysis
- Monthly order trends  
- Quarterly order trends  
- Year-wise growth  
- Orders by day of week  

### 📍 Location-Based Analysis
- Top 10 cities by order volume  
- Revenue contribution by state  

### 🍽️ Food Performance Analysis
- Top 10 restaurants by orders  
- Most popular cuisines  
- Most ordered dishes  
- Cuisine-wise average ratings  

### 💰 Customer Spending Insights
Orders grouped into spend buckets:
- Under 100  
- 100–199  
- 200–299  
- 300–499  
- 500+  

