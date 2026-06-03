/*
=====================================================
Create Database and Schemas
=====================================================
Script Purpose:
	This script creates a new database named 'DataWarehouse' after checking if it already exists. 
	If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas within the database: 'bronze', 'silver', and 'gold'.

WARNING:
	Running this script will drop the entire 'DataWarehouse' database if it exists. All data in the database will be permanently deleted. Proceed with caution and ensure you have proper backups before running this script.
*/

--drop and recreate the 'datawarehouse' database

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'datawarehouse')
BEGIN
	ALTER DATABASE datawarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE datawarehouse;
END;
GO

--create database 'Datawarehouse'

CREATE DATABASE DataWarehouse;

USE DataWarehouse;

--we will be creating schemas. it is like a folder or a container helps to keep things organised. we will be creating schemas for each layer which we have discussed earlier: Bronze, Silver, Gold

GO  --separate batches when working with multiple SQL Statements
CREATE SCHEMA Bronze;
GO
CREATE SCHEMA Silver;
GO
CREATE SCHEMA Gold;
