/*
===========================================================
DDL Script: Create Gold Views
===========================================================
Script Purpose:
	This script creates view for the gold layer in the data warehouse.
	The gold layer represents the final dimension and fact tables (Star Schema)

	Each View perform transformations and combines data from the silver layer 
	to produce a clean, enriched, and business-ready dataset.

Usage:
	- These views can be queried directly for analytics and reporting.
===========================================================
*/

--=========================================================
--Create Dimension: Gold.dim_customers
--=========================================================

--first checking whether the table already exist of not if exists drop and then Creating view dim_customers
IF OBJECT_ID('Gold.dim_customers', 'V') IS NOT NULL
	DROP VIEW Gold.dim_customers;
GO
CREATE VIEW gold.dim_customers AS
SELECT 
	ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_number,
	ci.cst_firstname AS first_name,
	ci.cst_lastname AS last_name,
	cl.cntry AS country,
	ci.cst_marital_status AS marital_status,
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr --CRM is the mater for gender Info
		 ELSE COALESCE (ca.gen, 'n/a')
	END AS gender,
	ca.bdate AS birth_date,
	ci.cst_create_date AS create_date	
FROM Silver.crm_cust_info ci
LEFT JOIN Silver.erp_cust_az12 ca
ON		ci.cst_key = ca.cid
LEFT JOIN Silver.erp_loc_a101 cl
ON		ci.cst_key = cl.cid
GO
SELECT * FROM Gold.dim_customers

--=========================================================
--Create Dimension: Gold.dim_product
--=========================================================

--first checking whether the table already exist of not if exists drop and then Creating view dim_product
IF OBJECT_ID('Gold.dim_product', 'V') IS NOT NULL
	DROP VIEW Gold.dim_product;
GO
CREATE VIEW gold.dim_product AS
SELECT 
	ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,
	pn.prd_id AS product_id,
	pn.prd_key AS product_number,
	pn.prd_nm AS product_name,
	pn.cat_id AS category_id,
	pc.cat AS category,
	pc.subcat AS subcategory,
	pc.maintenance,
	pn.prd_cost AS cost,
	pn.prd_line AS product_line,
	pn.prd_start_dt AS start_date
FROM Silver.crm_prd_info pn
LEFT JOIN Silver.erp_px_cat_g1v2 pc
ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL -- Filter out all historical data 
GO
SELECT * FROM Gold.dim_product

--=========================================================
--Create Dimension: Gold.fact_sales
--=========================================================

--first checking whether the table already exist of not if exists drop and then Creating view fact_sales
IF OBJECT_ID('Gold.fact_sales', 'V') IS NOT NULL
	DROP VIEW Gold.fact_sales;
GO
CREATE VIEW Gold.fact_sales AS
SELECT 
sd.sls_ord_num AS order_number,
pr.product_key,
ci.customer_key,
sd.sls_order_dt AS order_date,
sd.sls_ship_dt AS ship_date,
sd.sls_due_dt AS due_date,
sd.sls_sales AS sales_amount,
sd.sls_quantity AS quantity,
sls_price AS price
FROM Silver.crm_sales_details sd
LEFT JOIN Gold.dim_product pr
ON sd.sls_prd_key = pr.product_number
LEFT JOIN Gold.dim_customers ci
ON sd.sls_cust_id = ci.customer_id
GO
SELECT * FROM Gold.fact_sales
