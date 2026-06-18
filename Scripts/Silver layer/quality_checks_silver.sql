/*
===========================================================
Quality Checks
===========================================================
Script Purpose:
	This script performs various quality checks for data 
	consistency, accuracy, and standardization across the silver schemas. 
	it includes checks for:
		--Null or Duplicate Primary key.
		--Unwanted spaces in the string field.
		--Data standardization and consistency.
		--Invalid date ranges and orders.
		--Data Consistency between related fields.

Usage Note:
	--Run These checks after data loading Silver layer.
	--Investigate and resolve any discrepencies found during the checks.
===========================================================
*/

--===========================================================
--Checking 'Silver.crm_cust_info'
--===========================================================

--Check for null and Duplicates in Primary Key
--Expectation: No Result
--We will count the number of primary key and group them by the primary key column itself and check whether any primary key occurance is more than once or not

SELECT * FROM Bronze.crm_cust_info;

SELECT cst_id, COUNT(*)
FROM Bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

--now checking that all the values which we have transformed pass all the quality checks or not.
SELECT * FROM Silver.crm_cust_info;

SELECT cst_id, COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

--now by this we can see the fault that there are some duplicates in primary key so we have to check each primary key and try to select the most genuine data from those duplicates.

SELECT * FROM(
	SELECT *,
	ROW_NUMBER() OVER 
	(PARTITION BY cst_id
	ORDER BY cst_create_date DESC) AS flag_last
	FROM Bronze.crm_cust_info
)t WHERE flag_last = 1

--Check for unwanted spaces
--Expectation: No Result
--for that we will use the trim function which used for trimiing the extra spaces from start and end but here we will compare the orginal text column with the trimmed text column to see how many of them are having issues.

--checking firstname
SELECT cst_firstname
FROM Bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)

--checking lastname
SELECT cst_lastname
FROM Bronze.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname)

--checking gender
SELECT cst_gndr
FROM Bronze.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr)

--now checking that all the values which we have transformed pass all the quality checks or not.
--checking firstname
SELECT cst_firstname
FROM Silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)

--checking lastname
SELECT cst_lastname
FROM Silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname)

--checking gender
SELECT cst_gndr
FROM Silver.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr)

--so as of now we have checked the data and in first and last name there were extra spaces present so we will trim those extra spaces using trim function from both the colums

SELECT 
cst_id,
cst_key,
TRIM(cst_firstname) AS cst_firstname,
TRIM(cst_lastname) AS cst_lastname,
cst_marital_status,
cst_gndr,
cst_create_date
from
Bronze.crm_cust_info

-- Data Standardization and consistency
--here we will check what type of value does it have 

--checking cst_gndr
SELECT DISTINCT cst_gndr
FROM Bronze.crm_cust_info

--checking cst_marital_status
SELECT DISTINCT cst_marital_status
FROM Bronze.crm_cust_info

--now checking that all the values which we have transformed pass all the quality checks or not.
--checking cst_gndr
SELECT DISTINCT cst_gndr
FROM Silver.crm_cust_info

--checking cst_marital_status
SELECT DISTINCT cst_marital_status
FROM Silver.crm_cust_info


--there is no as such changes needed but we will set the fullname instead of using the abbriviations in the whole project wherever we find the abbriviated gender

--transforming cst_gndr
SELECT 
cst_id,
cst_key,
cst_firstname,
cst_lastname,
cst_marital_status,
CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'	
	 WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
	 ELSE 'n/a'
END cst_gndr,
cst_create_date
from
Bronze.crm_cust_info

--transforming cst_martial_status
SELECT 
cst_id,
cst_key,
cst_firstname,
cst_lastname,
CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'	
	 WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
	 ELSE 'n/a'
END cst_marital_status,
cst_gndr,
cst_create_date
from
Bronze.crm_cust_info

--we have done all the transformations of crm_cust_info and now its time to insert the value into the table which we have created.

--===========================================================
--Checking 'Silver.crm_prd_info'
--===========================================================

--Check for null and Duplicates in Primary Key
--Expectation: No Result
--We will count the number of primary key and group them by the primary key column itself and check whether any primary key occurance is more than once or not

SELECT * FROM Bronze.crm_prd_info;

SELECT prd_id, COUNT(*)
FROM Bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;
--checking in silver layer after load
SELECT prd_id, COUNT(*)
FROM Silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

--in prd_key column the cat_id is hidden so we will be splitting the column into two other columns in which we will derive the cat_id column and another column will be the actual prd_key

--for this we will be using the substring function which help to extract the specific part of a string value.
--we have to pass the three values substring(name of the column from which it is to be extracted, position of start, num of characters).
--when we are extractig the second column there we can  see the length of the prd_key is not same for all the rows so we cannot make it static for hat we will use the LEN function which gives the number of charactes of the string so if we pass this then it will automatically check the numbers of character.

--also we found that in the cat_id column has underscore in the 3rd place which is to be joined with the newly created cat_id in prd_info table which has hyphen in third place so we will be going to replace the hyphen with underscore. so for that we will be going to use replace function.

SELECT 
prd_id,
prd_key,
REPLACE(SUBSTRING(prd_key, 1, 5),'-','_') AS cat_id,
SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
prd_nm,
prd_cost,
prd_line,
prd_start_dt,
prd_end_dt
FROM Bronze.crm_prd_info;

--Check for unwanted spaces
--Expectation: No Result
--for that we will use the trim function which used for trimiing the extra spaces from start and end but here we will compare the orginal text column with the trimmed text column to see how many of them are having issues.

SELECT prd_nm
FROM Bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)

--checking in silver layer after load

SELECT prd_nm
FROM Silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)

--Check for NULLS or Negative Numbers
--Expectation: No Result
--there is nor negative value but there is null values
--so to handle that null values we will be replacing the null values with the 0 using the ISNULL fucntion which helps to rplace the null value with the specified value.

SELECT prd_cost
FROM Bronze.crm_prd_info
WHERE prd_cost <0 OR prd_cost IS NULL

--now checking that all the values which we have transformed pass all the quality checks or not.
SELECT prd_cost
FROM Silver.crm_prd_info
WHERE prd_cost <0 OR prd_cost IS NULL

--transforming prd_cost
SELECT 
prd_id,
prd_key,
prd_nm,
ISNULL(prd_cost,0) AS prd_cost,
prd_line,
prd_start_dt,
prd_end_dt
FROM Bronze.crm_prd_info;

-- Data Standardization and consistency
--here we will check what type of value does it have 

SELECT DISTINCT prd_line
FROM Bronze.crm_prd_info

--now checking that all the values which we have transformed pass all the quality checks or not.

SELECT DISTINCT prd_line
FROM Silver.crm_prd_info

--there is no as such changes needed but we will set the fullname instead of using the abbriviations in the whole project wherever we find the abbriviated columns

SELECT 
prd_id,
prd_key,
prd_nm,
CASE UPPER(TRIM(prd_line)) 
	 WHEN 'M' THEN 'Mountain'	
	 WHEN 'R' THEN 'Road'
	 WHEN 'S' THEN 'Other Sales'
	 WHEN 'T' THEN 'Touring'
	 ELSE 'n/a'
END prd_line,
prd_start_dt,
prd_end_dt
FROM Bronze.crm_prd_info;

-- here in the table single prd_key is repeates 2 to 3 times as ther is a change in cost price and when there is a change a new record is inserted in the table with the stat and the end date 

--here when we check the date column in which end date should be smaller then start date and upon comparison we have fond there are multiple rows having inconsistent data as start date cannot be smaller than the end date.

--so we have to update the end date according to the start date where the end date of the first record will be 1-start date of the second record. and so on and in the last record the end date ill be null as there is no chage in the price till now.

--so transformation will not be done initially on whole table first we will apply the logic on some recods once it is successfully validiated then we will integrate for the whole data.

--in sql if we are in a specific record and want to access another information from another record for doing this we have 2 amazing window functions that is LEAD() And LAG().
--so LEAD() function helps to access values from the next row within a window.
--and LAG() function helps to access values from the previous row within a window.

--checking any invalid date orders
SELECT * 
FROM Bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt

--checking in silver layer after load
SELECT * 
FROM Silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt

--transforming end_date column
SELECT
    prd_id,
    prd_key,
    prd_nm,
    prd_line,
    prd_start_dt,
    prd_end_dt,
    DATEADD(
        DAY,
        -1,
        LEAD(prd_start_dt) OVER (
            PARTITION BY prd_key
            ORDER BY prd_start_dt
        )
    ) AS Prd_end_dt_test
FROM Bronze.crm_prd_info
WHERE prd_key IN ('AC-HE-HL-U509-R', 'AC-HE-HL-U509');

--we have done all the transformations crm_prd_info and now its time to insert the value into the table which we have created.

--===========================================================
--Checking 'Silver.crm_sales_details'
--===========================================================

--Check for null and Duplicates in Primary Key
--Expectation: No Result
--We will count the number of primary key and group them by the primary key column itself and check whether any primary key occurance is more than once or not

SELECT * FROM Bronze.crm_sales_details;

SELECT sls_ord_num, COUNT(*)
FROM Bronze.crm_sales_details
GROUP BY sls_ord_num
HAVING COUNT(*) > 1 OR sls_ord_num IS NULL;

--checking in silver layer after load
SELECT * FROM Silver.crm_sales_details;

SELECT sls_ord_num, COUNT(*)
FROM Silver.crm_sales_details
GROUP BY sls_ord_num
HAVING COUNT(*) > 1 OR sls_ord_num IS NULL;

--Check for unwanted spaces
--Expectation: No Result
--for that we will use the trim function which used for trimiing the extra spaces from start and end but here we will compare the orginal text column with the trimmed text column to see how many of them are having issues.

SELECT sls_ord_num
FROM Bronze.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num)

--checking in silver layer after load

SELECT sls_ord_num
FROM Silver.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num)

--data integration check in which we will verify that all the foriegn keys present matches completely with the primary key.
--expectation: no result

--checking sls_prd_key 
SELECT * FROM Bronze.crm_sales_details
WHERE sls_prd_key NOT IN (SELECT prd_key FROM Silver.crm_prd_info)

--checking sls_cust_id 
SELECT * FROM Bronze.crm_sales_details
WHERE sls_cust_id NOT IN (SELECT cst_id FROM Silver.crm_cust_info)

--here in this table you will notice that there are 3 date tables but they are not in the date format but it is in the integer format
--so first we will check the consistency of the date as integer value that is there any null or zero present ot not.
--then we will check the length of the value which should be 8 because value is showing the format YYYYMMDD
--then we will check the boundry of the date 
--so we have zeros in the order date so we wil handle it by replacing zero with null
--and also we will convert the in consistent value which has length less than 8 we will make it null

--Checking sls_ordr_dt
SELECT sls_order_dt
FROM Bronze.crm_sales_details
WHERE sls_order_dt <=0 
OR LEN(sls_order_dt) !=8
OR sls_order_dt > 20500101
OR sls_order_dt < 19000101

--Checking sls_ship_dt
SELECT sls_ship_dt
FROM Bronze.crm_sales_details
WHERE sls_ship_dt <=0 
OR LEN(sls_ship_dt) !=8
OR sls_ship_dt > 20500101
OR sls_ship_dt < 19000101

--Checking sls_due_dt
SELECT sls_due_dt
FROM Bronze.crm_sales_details
WHERE sls_due_dt <=0 
OR LEN(sls_due_dt) !=8
OR sls_due_dt > 20500101
OR sls_due_dt < 19000101

--checking in silver layer after load

--Checking sls_ordr_dt
SELECT sls_order_dt
FROM Silver.crm_sales_details
WHERE sls_order_dt <=0 
OR LEN(sls_order_dt) !=8
OR sls_order_dt > 20500101
OR sls_order_dt < 19000101

--Checking sls_ship_dt
SELECT sls_ship_dt
FROM Silver.crm_sales_details
WHERE sls_ship_dt <=0 
OR LEN(sls_ship_dt) !=8
OR sls_ship_dt > 20500101
OR sls_ship_dt < 19000101

--Checking sls_due_dt
SELECT sls_due_dt
FROM Silver.crm_sales_details
WHERE sls_due_dt <=0 
OR LEN(sls_due_dt) !=8
OR sls_due_dt > 20500101
OR sls_due_dt < 19000101

--transforming sls_order_dt
--first replacing zero with null
--we will use the NULLIF() Function returns NULL if 2 given values are equal, other wise it returns the first expression.
SELECT 
sls_order_dt,
CASE WHEN sls_order_dt = 0
          OR LEN(sls_order_dt) != 8
     THEN NULL
     ELSE CAST(
              CAST(
                   sls_order_dt AS VARCHAR
              )AS DATE
          )
END AS sls_order_dt
FROM Bronze.crm_sales_details

--transforming sls_ship_dt
--first replacing zero with null
--we will use the NULLIF() Function returns NULL if 2 given values are equal, other wise it returns the first expression.
SELECT 
sls_ship_dt,
CASE WHEN sls_ship_dt = 0
          OR LEN(sls_ship_dt) != 8
     THEN NULL
     ELSE CAST(
              CAST(
                   sls_ship_dt AS VARCHAR
              )AS DATE
          )
END AS sls_ship_dt
FROM Bronze.crm_sales_details

--transforming sls_due_dt
--first replacing zero with null
--we will use the NULLIF() Function returns NULL if 2 given values are equal, other wise it returns the first expression.
SELECT 
sls_due_dt,
CASE WHEN sls_due_dt = 0
          OR LEN(sls_due_dt) != 8
     THEN NULL
     ELSE CAST(
              CAST(
                   sls_due_dt AS VARCHAR
              )AS DATE
          )
END AS sls_due_dt
FROM Bronze.crm_sales_details

--now one more thing to check is that order date must be earlier than the shipping date or due date.
SELECT * FROM Bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

--transformed loaded into silver layer
SELECT * FROM Silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

--we know that sales quantity and price are connected to each others.
--there is a business rule that is sales = quantity *price
--we must check that all sales, price and quantity are neither negative nor null and also no zero
--expectation: no result
--so to handle that null values we will be replacing the null values with the 0 using the ISNULL fucntion which helps to replace the null value with the specified value.

SELECT DISTINCT
sls_sales,
sls_quantity,
sls_price
FROM Bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <=0 OR sls_quantity <=0 OR sls_price <=0
ORDER BY sls_sales, sls_quantity, sls_price

--transformed loaded into silver layer

SELECT DISTINCT
sls_sales,
sls_quantity,
sls_price
FROM Silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <=0 OR sls_quantity <=0 OR sls_price <=0
ORDER BY sls_sales, sls_quantity, sls_price

--now upon checking the data e have found lots of in consistency in the sales ad price column.
-- so there asr 2 was to solve them
--1. either ask the management to improve the data and fresh load into the system 
--2. transforming the data in the silver layer with the consent and support of the management. so here we are going to transform these column according to some set of rules
--rule 1: if sales is zero, negative, null derive it using quantity and price
--rule 2: if price is zero, null, calculate using sales and quantity.
--rule 3: if price is negative convert it to positive

SELECT DISTINCT
sls_sales AS old_sls_sales,
CASE WHEN sls_sales IS NULL OR sls_sales <=0 OR sls_sales != sls_quantity * ABS(sls_price)
     THEN sls_quantity * ABS(sls_price)
     ELSE sls_sales 
END AS sls_sales,
sls_quantity,
sls_price AS old_sls_price,
CASE WHEN sls_price IS NULL OR sls_price <=0
     THEN sls_sales / NULLIF(sls_quantity,0)
     ELSE sls_price
END AS sls_price
FROM Bronze.crm_sales_details

--we have done all the transformations of crm_sales_details and now its time to insert the value into the table which we have created.

--===========================================================
--Checking 'Silver.erp_cust_az12'
--===========================================================

select * from Bronze.erp_cust_az12

--consistency of Cid
--see in this data we have cid which can be compared with cst_key from cust_info table but cid has NAS at the begining of each id so we have to remove that NAS from each row

--transformation
SELECT
cid,
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
	 ELSE cid
END cid
FROM Bronze.erp_cust_az12

--now we will check whether the date column in a consistent range.
--expectation: No result
--here the date is inconsistent as bdate is showing very old to future date so it is inconsistent 
SELECT DISTINCT
bdate
FROM Bronze.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE()

--checking after transforming
SELECT DISTINCT
bdate
FROM Silver.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE()

--transform date column 
SELECT
bdate,
CASE WHEN bdate > GETDATE() THEN NULL
	 ELSE bdate
END AS bdate
FROM Bronze.erp_cust_az12

--data standardization and consistency
--here data is inconsistent so we will clean it and make it only three values that is male, female, n/a
SELECT DISTINCT gen
from Bronze.erp_cust_az12

--Checking after transforming
SELECT DISTINCT gen
from Silver.erp_cust_az12

--transforming gen
SELECT 
gen,
CASE WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
	 WHEN UPPER(TRIM(gen)) IN ('M','MALE') THEN 'Male'
	 ELSE 'n/a'
END AS gen
from Bronze.erp_cust_az12


--we have done all the transformations of erp_cust_az12 and now its time to insert the value into the table which we have created.

--===========================================================
--Checking 'Silver.erp_loc_a101'
--===========================================================

select * from Bronze.erp_loc_a101

--consistency of Cid
--see in this data we have cid which can be compared with cst_key from cust_info table but cid has '-' to seperate the string value from the integer value id so we have to remove that '-' from each row.

--transformation
SELECT
cid,
REPLACE (cid, '-', '') AS cid
FROM Bronze.erp_loc_a101

--data standardization and consistency
--here data is inconsistent as the datas value has a mix of full name and abrivations and null also 
SELECT DISTINCT cntry
from Bronze.erp_loc_a101
ORDER BY cntry

--Checking after transforming
SELECT DISTINCT cntry
from Silver.erp_loc_a101
ORDER BY cntry

--transforming cntry
SELECT 
cntry,
CASE WHEN UPPER(TRIM(cntry)) = 'DE' THEN 'Germany'
	 WHEN UPPER(TRIM(cntry)) IN ('US','USA') THEN 'United States'
	 WHEN UPPER(TRIM(cntry)) = '' OR cntry IS NULL THEN 'n/a'
	 ELSE TRIM(cntry)
END AS cntry
from Bronze.erp_loc_a101


--we have done all the transformations of erp_loc_a101 and now its time to insert the value into the table which we have created.

--===========================================================
--Checking 'Silver.erp_px_cat_g1v2'
--===========================================================


select * from Bronze.erp_px_cat_g1v2

-- there is a category and subcategory column and we will be checking unwanted spaces in both column
--expectation no result

select * from Bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) 
OR subcat != TRIM(subcat)
OR maintenance != TRIM(maintenance)

--data standardization and consistency
--expectation: No result

--checking cat
select DISTINCT
cat
from Bronze.erp_px_cat_g1v2

--checking subcat
select DISTINCT
subcat
from Bronze.erp_px_cat_g1v2

--checking mainenance
select DISTINCT
maintenance
from Bronze.erp_px_cat_g1v2

--Checking after transforming
--checking cat
select DISTINCT
cat
from Silver.erp_px_cat_g1v2

--checking subcat
select DISTINCT
subcat
from Silver.erp_px_cat_g1v2

--checking mainenance
select DISTINCT
maintenance
from Silver.erp_px_cat_g1v2


--we have done all the transformations erp_px_cat_g1v2 and now its time to insert the value into the table which we have created.
