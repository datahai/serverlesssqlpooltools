# serverlesssqlpooltools (sspt)
SQL scripts for Azure Synapse Analytics Serverless SQL Pools

These are utility scripts for various operations in Azure Synapse Analytics Serverless SQL Pools.

---

## createaggregateswithcetas
This is a dynamic CREATE EXTERNAL TABLE AS SELECT process to write data out to an Azure Data Lake Gen2 account.  This is the code that supports blog post https://www.serverlesssql.com/optimisation/using-cetas-to-create-pre-calculated-datasets/
<br /><br />

## createview
This is a dynamic CREATE VIEW process which loads an external metadata CSV file then iterates and creates the appropriate views
<br /><br />

## querystoragelogs
This is code to create a Serverless SQL Pools LogAnalytics database and then a View over the Azure Storage log format.  Supports blog post https://www.serverlesssql.com/optimisation/use-azure-storage-logs-to-analyse-synapse-analytics-serverless-sql-pools-activity/
<br /><br />

## createviewsdynamically.sql 
Basic SQL statement which can be used to construct a CREATE VIEW statement dynamically using file metadata extraction from sp_describe_first_result_set.
<br /><br />

## dataprocessed.sql 
Shows the data processed metric vs the daily/weekly/monthly TB (terabytes) limits set.
<br /><br />

## externaltablemetadata.sql 
Shows the metadata attached to an External Table such as file formats and data source.
<br /><br />

## showerrorfiles.sql
Creates a view to show errors logged as part of the OPENROWSET ERRORFILE_LOCATION and ERRORFILE_DATA_SOURCE error handling process.
<br /><br />

## Create Aggregate Datasets using CETAS
In the folder **createaggregateswithcetas** is a stored procedure that when passed a View name, will select * from the view and write back to a new folder in the Data Lake.  It also creates a new view over this data and only selects the current data.
