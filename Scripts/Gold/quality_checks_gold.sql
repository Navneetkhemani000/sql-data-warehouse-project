/*
===========================================================
Quality Checks
===========================================================
Script Purpose:
	This script performs various quality checks for data to validate
	integrity, consistency, and accuracy across the gold schemas. 
	it includes checks for:
		--Uniqueness of surrogate keys in dimension tables.
		--Refrential integrity between fact and dimension tables.
		--Validation of relationships in the data model for analytical purpose.

Usage Note:
	--Run These checks after data loading Silver layer.
	--Investigate and resolve any discrepencies found during the checks.
===========================================================
*/

--===========================================================
--Checking 'gold.dim_customers'
--===========================================================

--Joining crm_cust_info(Master table) with erp_cust_az12(Sub table) and erp_loc_a101(sub table) upon primary key. 
--mode of join : LEFT JOIN

SELECT 
	ci.cst_id,
	ci.cst_key,
	ci.cst_firstname,
	ci.cst_lastname,
	ci.cst_marital_status,
	ci.cst_gndr,
	ci.cst_create_date,
	ca.gen,
	ca.bdate,
	cl.cntry
FROM Silver.crm_cust_info ci
LEFT JOIN Silver.erp_cust_az12 ca
ON		ci.cst_key = ca.cid
LEFT JOIN Silver.erp_loc_a101 cl
ON		ci.cst_key = cl.cid

--here we are doing joining ad sometimes after joining tables we see that data gets duplicated. so check that if there any duplicates introduced by the join logic.
--so for that we will be going to group by data on the customer id and checks the count which has greater than one.
SELECT cst_id, COUNT(*) FROM (
	SELECT 
		ci.cst_id,
		ci.cst_key,
		ci.cst_firstname,
		ci.cst_lastname,
		ci.cst_marital_status,
		ci.cst_gndr,
		ci.cst_create_date,
		ca.gen,
		ca.bdate,
		cl.cntry
	FROM Silver.crm_cust_info ci
	LEFT JOIN Silver.erp_cust_az12 ca
	ON ci.cst_key = ca.cid
	LEFT JOIN Silver.erp_loc_a101 cl
	ON ci.cst_key = cl.cid
)t GROUP BY cst_id
HAVING COUNT(*) > 1

--now after joinng we can see there are two gender columns one is from the master table and another comes from the sub table so for this we will go the DATA INTEGRATION 
--here we will check whether the values from both the columns matching or not 
SELECT DISTINCT
	ci.cst_gndr,
	ca.gen
FROM Silver.crm_cust_info ci
LEFT JOIN Silver.erp_cust_az12 ca
ON		ci.cst_key = ca.cid
LEFT JOIN Silver.erp_loc_a101 cl
ON		ci.cst_key = cl.cid
ORDER BY 1,2

--we have checked and we got some of the issue and we will so this to source expert and sk them which s the master table and we will then by tking permission we will transform the columns accordingly

SELECT DISTINCT
	ci.cst_gndr,
	ca.gen,
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr --CRM is the mater for gender Info
		 ELSE COALESCE (ca.gen, 'n/a')
	END AS new_gen
FROM Silver.crm_cust_info ci
LEFT JOIN Silver.erp_cust_az12 ca
ON		ci.cst_key = ca.cid
LEFT JOIN Silver.erp_loc_a101 cl
ON		ci.cst_key = cl.cid
ORDER BY 1,2

--now our transformation looks nice so we will be going to rename columns to friendly, meaningful names of the columns according to the naming convention like :
--words will be seperated by '_' 
--all will be in smallcase
--avoid using the reserved SQL words

SELECT 
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_number,
	ci.cst_firstname AS first_name,
	ci.cst_lastname AS last_name,
	ci.cst_marital_status AS marital_status,
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr --CRM is the mater for gender Info
		 ELSE COALESCE (ca.gen, 'n/a')
	END AS gender,
	ci.cst_create_date AS create_date,
	ca.bdate AS birth_date,
	cl.cntry AS country
FROM Silver.crm_cust_info ci
LEFT JOIN Silver.erp_cust_az12 ca
ON		ci.cst_key = ca.cid
LEFT JOIN Silver.erp_loc_a101 cl
ON		ci.cst_key = cl.cid

--Next we will be going to sort the column into the logical groups to improve readability
--we are using the above transformed code here as to be consisitent with the data

SELECT 
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

--Now we can see that the customer object is almost ready so we should check whether it is a dimension or a fact table.
--we know that the dimension table provides the descriptive information of the object and here we can clearly see that each row of the object is describing the each coustomer of their company so we can say that it is a dimension table.
--one thing is that when we creating dimension table there must be a primay key present in the dimension table. we can use the customer id as primary key which we get from source but soetimes we cannot count on those columns
--so in that case we have to generate new primary key in the data warehouse and those primary key are called as surrogate key

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

--upto now all the transformations has been completed and now we will be creating this table in the form of view. 

--===========================================================
--Checking 'gold.dim_product'
--===========================================================

--Joining crm_prd_info(Master table) with erp_pc_cat_g1v2 (Sub table). 
--mode of join : LEFT JOIN
--note that here in this table we can see that there is both historic and current data so we will be going to work only upon the current data so to filter out this if we work upon the records where the end date is null by this we will get only the current data.

SELECT 
pn.prd_id,
pn.cat_id,
pn.prd_key,
pn.prd_nm,
pn.prd_cost,
pn.prd_line,
pn.prd_start_dt,
pc.cat,
pc.subcat,
pc.maintenance
FROM Silver.crm_prd_info pn
LEFT JOIN Silver.erp_px_cat_g1v2 pc
ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL -- Filter out all historical data

--here we are doing joining ad sometimes after joining tables we see that data gets duplicated. so check that if there any duplicates introduced by the join logic.
--so for that we will be going to group by data on the customer id and checks the count which has greater than one.
--result expectation: No result

SELECT prd_key, COUNT(*) FROM (
	SELECT 
		pn.prd_id,
		pn.cat_id,
		pn.prd_key,
		pn.prd_nm,
		pn.prd_cost,
		pn.prd_line,
		pn.prd_start_dt,
		pc.cat,
		pc.subcat,
		pc.maintenance
	FROM Silver.crm_prd_info pn
	LEFT JOIN Silver.erp_px_cat_g1v2 pc
	ON pn.cat_id = pc.id
	WHERE prd_end_dt IS NULL -- Filter out all historical data
)t GROUP BY prd_key
HAVING COUNT(*) > 1

--now our transformation looks nice so we will be going to rename columns to friendly, meaningful names of the columns according to the naming convention like :
--words will be seperated by '_' 
--all will be in smallcase
--avoid using the reserved SQL words

SELECT 
	pn.prd_id AS product_id,
	pn.cat_id AS category_id,
	pn.prd_key AS product_number,
	pn.prd_nm AS product_name,
	pn.prd_cost AS cost,
	pn.prd_line AS product_line,
	pn.prd_start_dt AS start_date,
	pc.cat AS category,
	pc.subcat AS subcategory,
	pc.maintenance
FROM Silver.crm_prd_info pn
LEFT JOIN Silver.erp_px_cat_g1v2 pc
ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL -- Filter out all historical data 

--Next we will be going to sort the column into the logical groups to improve readability
--we are using the above transformed code here as to be consisitent with the data

SELECT 
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

--Now we can see that the product object is almost ready so we should check whether it is a dimension or a fact table.
--we know that the dimension table provides the descriptive information of the object and here we can clearly see that each row of the object is describing the each product of their company so we can say that it is a dimension table.
--one thing is that when we creating dimension table there must be a primay key present in the dimension table. we can use the product_id as primary key which we get from source but sometimes we cannot count on those columns
--so in that case we have to generate new primary key in the data warehouse and those primary key are called as surrogate key

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

	
--upto now all the transformations has been completed and now we will be creating this table in the form of view. 

--===========================================================
--Checking 'gold.fact_sales'
--===========================================================

--we should check whether crm_sales_details is a dimension or a fact table.
--we know that the fact table provides the transactional event information of the object, mny different keys present denoting the dimension tables and here we can clearly see that each row of the object is a transaction where some customer bought some products from this company so we can say that it is a fact table.
--one thing is that when we creat fact table then primary key of the dimension table must be present as a reference key in the fact table. 
--we can use the product_key and cust_id from the crm_sales_details and join it with the relavent keys from the dimension table to bring the generated surrogate keys in the sales_details and later on we will remove those prd_key and cust_id from the sales_details.
--the process of joining the tables to get only the relevant information from those tables is known as DATA LOOKUP.
--mode of join: LEFT JOIN

SELECT 
sd.sls_ord_num,
pr.product_key,
--sd.sls_prd_key,
ci.customer_key,
--sd.sls_cust_id,
sd.sls_order_dt,
sd.sls_ship_dt,
sd.sls_due_dt,
sd.sls_sales,
sd.sls_quantity,
sls_price
FROM Silver.crm_sales_details sd
LEFT JOIN Gold.dim_product pr
ON sd.sls_prd_key = pr.product_number
LEFT JOIN Gold.dim_customers ci
ON sd.sls_cust_id = ci.customer_id

--now our transformation looks nice so we will be going to rename columns to friendly, meaningful names of the columns according to the naming convention like :
--words will be seperated by '_' 
--all will be in smallcase
--avoid using the reserved SQL words

SELECT 
sd.sls_ord_num AS order_number,
pr.product_key,
--sd.sls_prd_key,
ci.customer_key,
--sd.sls_cust_id,
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
--upto now all the transformations has been completed and now we will be creating this table in the form of view. 

--As we have created the fact table we must check the foriegn key integrity with each dimension table.

--checking with gold.dim_customer

SELECT * FROM Gold.fact_sales f
LEFT JOIN Gold.dim_customers c
ON c.customer_key = f.customer_key
WHERE c.customer_key IS NULL

--checking with gold.dim_customer

SELECT * FROM Gold.fact_sales f
LEFT JOIN Gold.dim_product p
ON p.product_key = f.product_key
WHERE p.product_key IS NULL

SELECT * FROM Gold.dim_product

SELECT * FROM Gold.dim_customers
