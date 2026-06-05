/*
===========================================================
Stored Procedure: Load Bronze Layer (Souce -> Bronze)

===========================================================
Script Purpose:
	This stored procedure loads data into the 'bronze' schema from external CSV files.
	This script also have the drop query to drop the stored procedure if exists.
	It performs the following actions:
	- Truncates the bronze tables before loading the data.
	- Uses the 'BULK INSERT' command to load the CSV files to bronze tables.

Parameters:
	None.
  this stored procedure doesnot accept any parameters or return any values.

Usage Example:
	EXEC bronze.load_bronze;
	
  Run this script to re-define the DDL structure of	'bronze' tables
===========================================================
*/

DROP PROCEDURE IF EXISTS Bronze.load_bronze;
GO
SELECT *
FROM sys.procedures
WHERE name = 'load_bronze';
--CREATING A STORED PROCEDURE TO LOAD THE DATA IN THE TABLE DAILY WITH A SINGLE COMMAND AS THIS SCRIPT WILL BE EXECUTED TO REFRESH THE DATA FROM THE SOURCE.
go
CREATE OR ALTER PROCEDURE Bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME
	BEGIN TRY
		SET @batch_start_time = GETDATE()
		PRINT '=========================================================';
		PRINT 'Loading Bronze Layer';
		PRINT '=========================================================';

		PRINT '---------------------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '---------------------------------------------------------';

		--DELETING ANY EXISTING DATA IN THE TABLE AND LOADIN THE WHOLE DATA FROM FRESH

		--INSERTING THE DATA INTO Bronze.crm_cust_info
		
		SET @start_time = GETDATE()
		
		PRINT '>>Truncating Table: Bronze.crm_cust_info';
		
		TRUNCATE TABLE Bronze.crm_cust_info
	
		PRINT '>>Inserting Data Into: Bronze.crm_cust_info';
	
		BULK INSERT Bronze.crm_cust_info
		FROM 'I:\transfer\polestar anbalytics\SQL\SQL DataWarehousing project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		SET @end_time = GETDATE()
		PRINT '>>Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR(50))+' seconds'
		PRINT '-------------------'

		--INSERTING THE DATA INTO Bronze.crm_prd_info

		SET @start_time = GETDATE()

		PRINT '>>Truncating Table: Bronze.crm_prd_info';
	
		TRUNCATE TABLE Bronze.crm_prd_info
	
		PRINT '>>Inserting Data Into: Bronze.crm_prd_info';
	
		BULK INSERT Bronze.crm_prd_info
		FROM 'I:\transfer\polestar anbalytics\SQL\SQL DataWarehousing project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		SET @end_time = GETDATE()
		PRINT '>>Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR(50))+' seconds'
		PRINT '-------------------'

		--INSERTING THE DATA INTO Bronze.crm_sales_details

		SET @start_time = GETDATE()

		PRINT '>>Truncating Table: Bronze.crm_sales_details';
	
		TRUNCATE TABLE Bronze.crm_sales_details
	
		PRINT '>>Inserting Data Into: Bronze.crm_sales_details';
	
		BULK INSERT Bronze.crm_sales_details
		FROM 'I:\transfer\polestar anbalytics\SQL\SQL DataWarehousing project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		SET @end_time = GETDATE()
		PRINT '>>Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR(50))+' seconds'
		PRINT '-------------------'

		PRINT '---------------------------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '---------------------------------------------------------';

		--INSERTING THE DATA INTO Bronze.erp_cust_az12

		SET @start_time = GETDATE()

		PRINT '>>Truncating Table: Bronze.erp_cust_az12';
	
		TRUNCATE TABLE Bronze.erp_cust_az12
	
		PRINT '>>Inserting Data Into: Bronze.erp_cust_az12';
	
		BULK INSERT Bronze.erp_cust_az12
		FROM 'I:\transfer\polestar anbalytics\SQL\SQL DataWarehousing project\sql-data-warehouse-project\datasets\source_erp\cust_az12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		SET @end_time = GETDATE()
		PRINT '>>Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR(50))+' seconds'
		PRINT '-------------------'

		--INSERTING THE DATA INTO Bronze.erp_loc_a101

		SET @start_time = GETDATE()

		PRINT '>>Truncating Table: Bronze.erp_loc_a101';
	
		TRUNCATE TABLE Bronze.erp_loc_a101
	
		PRINT '>>Inserting Data Into: Bronze.erp_loc_a101';
	
		BULK INSERT Bronze.erp_loc_a101
		FROM 'I:\transfer\polestar anbalytics\SQL\SQL DataWarehousing project\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		SET @end_time = GETDATE()
		PRINT '>>Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR(50))+' seconds'
		PRINT '-------------------'

		--INSERTING THE DATA INTO Bronze.erp_px_cat_g1v2

		SET @start_time = GETDATE()

		PRINT '>>Truncating Table: Bronze.erp_px_cat_g1v2';
	
		TRUNCATE TABLE Bronze.erp_px_cat_g1v2
	
		PRINT '>>Inserting Data Into: Bronze.erp_px_cat_g1v2';
	
		BULK INSERT Bronze.erp_px_cat_g1v2
		FROM 'I:\transfer\polestar anbalytics\SQL\SQL DataWarehousing project\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		SET @end_time = GETDATE()
		PRINT '>>Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR(50))+' seconds'
		PRINT '-------------------'

		SET @batch_end_time = GETDATE()
		PRINT '=========================================================';
		PRINT 'Loading Bronze Layer is Completed'
		PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(second,@batch_start_time,@batch_end_time) AS NVARCHAR(50))+' seconds'
		PRINT '=========================================================';

	END TRY
	BEGIN CATCH
		PRINT '=========================================================';
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR(50));
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR(50));
		PRINT '=========================================================';
	END CATCH
END;
GO
