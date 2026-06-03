# Retail Sales Capstone Project – SQL Data Analysis

## Project Overview

This project demonstrates the use of SQL for database creation, data management, data cleaning, and business intelligence reporting using a retail sales dataset.

The objective was to design a relational database, organize retail transaction data, and answer key business questions that can support strategic decision-making.

---

## Business Problem

Retail businesses generate large volumes of transactional data daily. Without proper analysis, valuable insights regarding sales performance, customer behavior, product profitability, and discount effectiveness can remain hidden.

This project aims to:

- Build a structured retail database.
- Clean and standardize data.
- Analyze sales performance.
- Identify top-performing products and customers.
- Evaluate discount trends.
- Generate actionable business insights.

---

## Database Design

The database was designed using a relational model consisting of the following tables:

### 1. Categories
Stores product category information.

| Column | Description |
|----------|------------|
| CategoryID | Unique category identifier |
| CategoryName | Product category name |

### 2. Countries
Stores country information.

| Column | Description |
|----------|------------|
| CountryID | Unique country identifier |
| CountryName | Country name |
| CountryCode | Country code |

### 3. Cities
Stores city information.

| Column | Description |
|----------|------------|
| CityID | Unique city identifier |
| CityName | City name |
| Zipcode | Postal code |
| CountryID | Foreign key from Countries |

### 4. Customers
Stores customer information.

| Column | Description |
|----------|------------|
| CustomerID | Unique customer identifier |
| FirstName | Customer first name |
| MiddleInitial | Middle initial |
| LastName | Customer last name |
| CityID | Customer city |
| Address | Customer address |

### 5. Employees
Stores employee information.

| Column | Description |
|----------|------------|
| EmployeeID | Unique employee identifier |
| FirstName | Employee first name |
| LastName | Employee last name |
| BirthDate | Date of birth |
| Gender | Gender |
| CityID | Employee city |
| HireDate | Employment date |

### 6. Products
Stores product information.

| Column | Description |
|----------|------------|
| ProductID | Unique product identifier |
| ProductName | Product name |
| Price | Product price |
| CategoryID | Product category |
| Class | Product class |
| Resistant | Resistance indicator |
| IsAllergic | Allergy indicator |
| VitalityDays | Product shelf life |

### 7. Sales
Stores transaction records.

| Column | Description |
|----------|------------|
| SalesID | Unique sale identifier |
| SalesPersonID | Employee responsible |
| CustomerID | Customer making purchase |
| ProductID | Product sold |
| UnitPrice | Selling price |
| Quantity | Quantity sold |
| Discount | Discount applied |
| SalesDate | Transaction date |
| TransactionNumber | Transaction reference |

---

## Data Preparation

### Backup Tables

To ensure data integrity and recovery, backup tables were created for all primary tables.

Examples:

```sql
CREATE TABLE sales_backup AS
SELECT * FROM sales;
```

### Data Cleaning

The `IsAllergic` column was standardized using a CASE statement to eliminate inconsistent values.

```sql
UPDATE products
SET IsAllergic = CASE
    WHEN TRIM(LOWER(IsAllergic)) = 'true' THEN 'TRUE'
    WHEN TRIM(LOWER(IsAllergic)) = 'false' THEN 'FALSE'
    ELSE NULL
END;
```

---

# Business Questions & SQL Solutions

## 1. Total Sales Revenue

### Objective
Determine overall revenue generated after discounts.

```sql
SELECT SUM(UnitPrice * Quantity * (1 - Discount)) AS TotalSales
FROM sales;
```

### Business Value
Provides a high-level view of company performance.

---

## 2. Highest Revenue Generating Product

### Objective
Identify the product generating the highest sales revenue.

```sql
SELECT p.ProductName,
       SUM(s.UnitPrice * s.Quantity * (1 - s.Discount)) AS TotalSales
FROM sales s
JOIN products p
ON s.ProductID = p.ProductID
GROUP BY p.ProductName
ORDER BY TotalSales DESC
LIMIT 1;
```

### Business Value
Helps management focus inventory and marketing efforts on best-performing products.

---

## 3. Top Customer by Spending

### Objective
Identify the customer who spent the most.

```sql
SELECT c.FirstName,
       c.LastName,
       c.Address,
       SUM(s.UnitPrice * s.Quantity * (1 - s.Discount)) AS TotalSpent
FROM sales s
JOIN customers c
ON MOD(s.CustomerID,500)=c.CustomerID
GROUP BY c.CustomerID,
         c.FirstName,
         c.LastName,
         c.Address
ORDER BY TotalSpent DESC
LIMIT 1;
```

### Business Value
Supports customer loyalty and retention strategies.

---

## 4. Employee and City Information

### Objective
Display employee names and their cities.

```sql
SELECT e.FirstName,
       e.LastName,
       ci.CityName
FROM employees e
JOIN cities ci
ON e.CityID = ci.CityID;
```

### Business Value
Useful for workforce reporting and geographic analysis.

---

## 5. Average Sales per Customer

### Objective
Determine average purchase value for each customer.

```sql
SELECT CustomerID,
       AVG(UnitPrice * Quantity * (1 - Discount)) AS AvgSales
FROM sales
GROUP BY CustomerID;
```

### Business Value
Helps segment customers based on spending habits.

---

## 6. Product Categories

### Objective
Display products and their categories.

```sql
SELECT p.ProductName,
       c.CategoryName
FROM products p
JOIN categories c
ON p.CategoryID = c.CategoryID;
```

### Business Value
Provides a complete product classification structure.

---

## 7. Sales Classification

### Objective
Classify transactions into High, Medium, and Low sales.

```sql
SELECT *,
CASE
    WHEN (UnitPrice * Quantity * (1 - Discount)) > 1000
         THEN 'High Sales'
    WHEN (UnitPrice * Quantity * (1 - Discount))
         BETWEEN 500 AND 1000
         THEN 'Medium Sales'
    ELSE 'Low Sales'
END AS SalesCategory
FROM sales;
```

### Business Value
Enables performance segmentation and reporting.

---

## 8. Product Ranking Using CTE and ROW_NUMBER()

### Objective
Rank products based on total revenue generated.

```sql
WITH ProductSales AS
(
    SELECT p.ProductID,
           p.ProductName,
           SUM(s.UnitPrice * s.Quantity * (1 - s.Discount))
           AS SalesAmountAfterDiscount
    FROM sales s
    JOIN products p
    ON s.ProductID = p.ProductID
    GROUP BY p.ProductID,
             p.ProductName
)

SELECT *,
ROW_NUMBER() OVER
(ORDER BY SalesAmountAfterDiscount DESC) AS RowNum
FROM ProductSales;
```

### Business Value
Helps identify top-performing and underperforming products.

---

## 9. Average Discount by Product

### Objective
Determine average discount offered per product.

```sql
SELECT ProductID,
       AVG(Discount) AS AvgDiscount
FROM sales
GROUP BY ProductID;
```

### Business Value
Evaluates pricing and discount strategies.

---

## 10. Products Above Average Price

### Objective
Identify premium-priced products.

```sql
SELECT ProductName,
       Price
FROM products
WHERE Price >
(
    SELECT AVG(Price)
    FROM products
);
```

### Business Value
Supports premium product marketing strategies.

---

# Key Insights

Based on the analysis, several valuable business insights can be obtained:

- Total sales revenue provides an overall measure of business performance.
- A small number of products contribute significantly to total revenue.
- High-value customers generate a substantial portion of sales.
- Discount levels vary across products and may impact profitability.
- Premium products can be identified for targeted marketing campaigns.
- Product ranking highlights opportunities for inventory optimization.

---

# Recommendations

As a Data Analyst, I recommend the following actions:

### 1. Strengthen Customer Retention Programs

Focus on high-spending customers through:

- Loyalty rewards
- Personalized offers
- VIP membership programs

**Expected Outcome:** Increased customer lifetime value and repeat purchases.

---

### 2. Optimize Inventory Management

Maintain higher stock levels for top-selling products while reviewing low-performing items.

**Expected Outcome:** Reduced stockouts and improved inventory turnover.

---

### 3. Review Discount Strategy

Analyze products receiving high discounts but generating low revenue.

**Expected Outcome:** Improved profit margins without negatively impacting sales.

---

### 4. Expand High-Performing Product Categories

Allocate more marketing budget and shelf space to categories with strong sales performance.

**Expected Outcome:** Revenue growth and improved market share.

---

### 5. Implement Customer Segmentation

Classify customers into:

- High Value
- Medium Value
- Low Value

for targeted marketing campaigns.

**Expected Outcome:** Higher campaign effectiveness and customer engagement.

---

### 6. Build Executive Dashboards

Integrate SQL outputs into:

- Microsoft Power BI
- Tableau
- Excel Dashboards

for real-time monitoring of:

- Revenue
- Product Performance
- Customer Spending
- Discounts
- Sales Trends

**Expected Outcome:** Faster and more informed business decisions.

---

# Tools & Technologies

- SQL (MySQL)
- Relational Database Design
- Data Cleaning
- Aggregate Functions
- Joins
- CASE Statements
- Common Table Expressions (CTEs)
- Window Functions
- Business Intelligence Concepts

---

# Conclusion

This project demonstrates practical SQL skills used in real-world data analytics, including database creation, data cleaning, relational modeling, business reporting, and performance analysis. The insights generated can support strategic decisions related to sales optimization, customer retention, inventory planning, and revenue growth.

---
**Author:** Kayode Peace
**Role:** Data Analyst | SQL Developer 
