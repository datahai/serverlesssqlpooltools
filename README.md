# serverlesssqlpooltools (sspt)
SQL scripts for Azure Synapse Analytics Serverless SQL Pools

These are utility scripts for various operations in Azure Synapse Analytics Serverless SQL Pools.

---

## createviewsdynamically.sql 
Can use source metadata to construct a CREATE VIEW statement dynamically.

## dataprocessed.sql 
Shows how much data has been processed vs the daily/weekly/monthly limits set.

## externaltablemetadata.sql 
Shows the metadata attached to an External Table such as file formats and data source.

## showerrorfiles.sql
Creates a view to show errors logged as part of the OPENROWSET ERRORFILE_LOCATION and ERRORFILE_DATA_SOURCE error handling process.
