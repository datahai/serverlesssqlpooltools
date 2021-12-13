This process assumes that an existing Serverless SQL Pools database exists with data sources and file formats created.

This process currently supports Parquet and Delimited files.

To run the process:

1. Populate the metadata file with the relevant information and upload to a folder in an Azure Data lake Gen2 container
2. Run the vwViewMetadata SQL script to create the View.  Ensure the BULK and DATA_SOURCE reference the relevant location and data source for the metadata file
3. Run the spGenerateViews SQL script to create the stored procedure
4. Run the spTriggerGenerateViews SQL script to create the stored procedure
5. Execute the spTriggerGenerateViews stored procedure to generate the views
