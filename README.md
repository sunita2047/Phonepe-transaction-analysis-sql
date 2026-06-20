# 📱 PhonePe Transaction Analysis using MySQL

## 📌 Project Overview

This project analyzes PhonePe transaction data using MySQL to uncover valuable business insights related to user behavior, transaction performance, revenue generation, service usage, and payment success rates.

The project demonstrates end-to-end SQL workflow including data loading, data cleaning, exploratory data analysis, KPI generation, query optimization, and business insight extraction.

## 🎯 Business Objectives

The project aims to answer the following business questions:

* What is the total revenue generated through transactions?
* Which services generate the highest revenue?
* What are the transaction success and failure rates?
* Which users contribute the most revenue?
* How does revenue vary across age groups?
* Which months generate the highest revenue?
* What are the most common transaction failure reasons?

## 📂 Dataset Information

The project uses two datasets:

### 1. Users Dataset

| Column    | Description                     |
| --------- | ------------------------------- |
| user_id   | Unique identifier for each user |
| name      | User name                       |
| age       | Age of the user                 |
| join_date | User registration date          |

### 2. Transactions Dataset

| Column         | Description             |
| -------------- | ----------------------- |
| transaction_id | Unique transaction ID   |
| amount         | Transaction amount      |
| user_id        | User identifier         |
| service        | Type of service used    |
| service_type   | Category of service     |
| payment_status | Transaction status      |
| reason         | Failure reason (if any) |
| date           | Transaction date        |


## 🧹 Data Cleaning & Preparation

The following preprocessing steps were performed:

* Imported CSV files into MySQL using `LOAD DATA INFILE`.
* Created staging tables for raw data.
* Converted data types appropriately.
* Converted string dates into SQL DATE format using `STR_TO_DATE()`.
* Removed invalid records.
* Identified missing values.
* Checked minimum and maximum age values.

## 📊 SQL Analysis Performed

### KPI Analysis

* Total Users
* Total Transactions
* Total Revenue
* Unique Users
* Average Transaction Amount
* Highest and Lowest Transaction Amount

### Transaction Analysis

* Transactions by Service
* Revenue by Service
* Payment Status Distribution
* Transaction Failure Rate
* Failure Reason Analysis

### Time-based Analysis

* Monthly Revenue Trends
* Monthly Transaction Trends
* Daily Revenue Analysis
* Weekday-wise Revenue Analysis
* Highest Revenue Month
* Lowest Revenue Month

### Service Analysis

* Most Used Services
* Least Used Services
* Average Amount by Service
* Service Type Distribution
* Service-wise Failure Analysis

### User Analysis

* Revenue by Age
* Top 5 Highest Spending Users
* Top 5 Most Active Users
* Revenue by Age Group
* Revenue by User Join Year
* Average Revenue by Age and Service

### Advanced SQL Concepts Used

* INNER JOIN
* Aggregate Functions
* CASE Statements
* GROUP BY & HAVING
* Subqueries
* Nested Queries
* Indexing
* Query Optimization
  
## ⚡ Performance Optimization

Indexes were created to improve query performance:

* Index on `user_id`
* Index on `date`
* Index on `service`
* Index on `payment_status`


## 🛠️ Technologies Used

* MySQL
* SQL
* MySQL Workbench

## 🚀 Key Skills Demonstrated

* Data Cleaning
* SQL Query Writing
* Joins
* Aggregations
* Subqueries
* Data Analysis
* Query Optimization
* Indexing
* Business Insight Generation

## 👩‍💻 Author

** SUNITA SUTHAR **

Aspiring Data Analyst | SQL | Python | Power BI | Excel
