-- creating a database
create database Retail_Capstone;

-- Use the Database
use Retail_Capstone;

-- Creating tables for each CSV file
-- creating categories tables
create table Categories (
    CategoryID int primary key,
    CategoryName varchar(100)
);

-- creating table for countries
create table Countries (
    CountryID int primary key,
    CountryName varchar(100),
    CountryCode varchar(10)
);

-- creating cities table
create table cities (
    CityID int primary key,
    CityName varchar(100),
    Zipcode int,
    CountryID int,
    foreign key (CountryID) references countries(CountryID)
);

-- creating customers table
create table customers (
    CustomerID int primary key,
    FirstName varchar(100),
    MiddleInitial varchar(10),
    LastName varchar(100),
    CityID int,
    Address varchar(255),
    foreign key (CityID) references cities(CityID)
);

-- creating employees table
create table employees (
    EmployeeID int primary key,
    FirstName varchar(100),
    MiddleInitial varchar(10),
    LastName varchar(100),
    BirthDate date,
    Gender varchar(10),
    CityID int,
    HireDate date,
    foreign key (CityID) references cities(CityID)
);

-- creating products table
create table products (
    ProductID int primary key,
    ProductName varchar(255),
    Price decimal(10,2),
    CategoryID int,
    Class varchar(50),
    ModifyDate date,
    Resistant varchar(10),
    IsAllergic varchar(10),
    VitalityDays int
);

-- creating sales table
create table sales (
    SalesID int primary key,
    SalesPersonID int,
    CustomerID int,
    ProductID int,
    UnitPrice decimal(10,2),
    Quantity int,
    Discount decimal(5,2),
    SalesDate date,
    TransactionNumber varchar(50)
);

use RetailCapstone;

-- creating backup tables for each table
-- backup table for categories
create table categories_backup as
select*from categories;

-- backup table for countries table
create table countries_backup as 
select * from countries;

-- backup table for cities
create table cities_backup as 
select *from cities;

-- backup table for customers
create table customers_backup as 
select * from customers; 

-- backup table for employees
create table employees_backup as
select *from employees; 

-- backup table for products
create table products_backup as
select * from products;

-- backup table for sales
create table sales_backup as 
select * from sales;

-- update statement with a case expression
set sql_safe_updates = 0;
update products
set IsAllergic = case
    when TRIM(LOWER(IsAllergic)) = 'true' then 'TRUE'
    when TRIM(LOWER(IsAllergic)) = 'false' then 'FALSE'
    else null
end;

-- Q1.  What is the total sales amount? 
select SUM(UnitPrice * Quantity * (1 - Discount)) as TotalSales
from sales;


-- Q2.  Which product has the highest total sales amount? 
select p.ProductName,
       SUM(s.UnitPrice * s.Quantity * (1 - s.Discount)) AS TotalSales
from sales s
join products p on s.ProductID = p.ProductID
GROUP BY p.ProductName
order by TotalSales desc
limit 1;

-- Q3.  What is the name and address of the top customer, i.e., who purchased the most? 
select 
    c.FirstName,
    c.LastName,
    c.Address,
    SUM(s.UnitPrice * s.Quantity * (1 - s.Discount)) AS TotalSpent
from sales s
join customers c 
    on mod(s.CustomerID, 500) = c.CustomerID
group by 
    c.CustomerID, c.FirstName, c.LastName, c.Address
order by TotalSpent desc
limit 1;

-- Q4. Show all the employee names and the cities they live in.  
select e.FirstName, e.LastName, ci.CityName
from employees e
join cities ci on e.CityID = ci.CityID;

-- Q5. What are the average sales purchased per customer? 
select CustomerID,
       avg(UnitPrice * Quantity * (1 - Discount)) as AvgSales
from sales
group by CustomerID;

-- Q6. Show all the ProductName and what categories they belong to?  
select p.ProductName, c.CategoryName
from products p
join categories c on p.CategoryID = c.CategoryID;

-- Q7.  Classify the SalesAmountAfterDiscount column as High sales, Medium sales, or  Low sales based on their total sales amount.
select *,
case 
    when (UnitPrice * Quantity * (1 - Discount)) > 1000 then 'High Sales'
    when (UnitPrice * Quantity * (1 - Discount)) between 500 and 1000 then 'Medium Sales'
    else 'Low Sales'
END AS SalesCategory
from sales;

-- Q8. Product Sales + ROW_NUMBER (Using CTE)
WITH ProductSales AS (
    select p.ProductID,
           p.ProductName,
           SUM(s.UnitPrice * s.Quantity * (1 - s.Discount)) AS SalesAmountAfterDiscount
    from sales s
    join products p on s.ProductID = p.ProductID
    group by p.ProductID, p.ProductName
)

select *,
row_number() over (order by SalesAmountAfterDiscount desc) as RowNum
from ProductSales;

-- Q9. Find the average discount given for each product 
select ProductID,
avg(Discount) as AvgDiscount
from sales
group by ProductID;

-- Q10.List the products that are greater than the average price using a subquery. 
select ProductName, Price
from products
where Price > (select avg(Price) from products);