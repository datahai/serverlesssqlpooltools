CREATE PROCEDURE LDW.GeneratePreComputedDatasets 
@SourceView NVARCHAR(200),
@Location NVARCHAR(1000),
@DataSource NVARCHAR(100),
@FileFormat NVARCHAR(100)
AS

BEGIN

--declare variables,set the process date for the folder name, and set the locations
DECLARE @LocationFull NVARCHAR(1100),
        @LocationTopLevel NVARCHAR(1100),
        @ProcessDate NCHAR(16),
        @SQLDrop NVARCHAR(2000),
        @CreateExternalTableString NVARCHAR(2000),
        @CreateCurrentAggregateView NVARCHAR(2000)

SET @ProcessDate = FORMAT(GETDATE(),'yyyyMMddHHmmss')

SET @LocationFull = CONCAT(@Location,REPLACE(@SourceView,'.',''),'/',@ProcessDate)
SET @LocationTopLevel = CONCAT(@Location,REPLACE(@SourceView,'.',''))

--Check for existence of an external table and drop if found
SET @SQLDrop = 'IF OBJECT_ID(''' + REPLACE(@SourceView,'.vw','') + '_PreComputeTable'') IS NOT NULL BEGIN DROP EXTERNAL TABLE ' + REPLACE(@SourceView,'.vw','') + '_PreComputeTable END'

EXEC sp_executesql @SQLDrop

--generate the SQL script to create the external table and export the View data
SET @CreateExternalTableString = 
'CREATE EXTERNAL TABLE ' + REPLACE(@SourceView,'.vw','') + '_PreComputeTable
WITH 
(
  LOCATION = ''' + @LocationFull + ''',                                      
  DATA_SOURCE = ' + @DataSource + ',
  FILE_FORMAT = ' + @FileFormat + '
)
AS
SELECT 
   *
FROM ' + @SourceView

EXEC sp_executesql @CreateExternalTableString


--drop the external table as we do not need it, it is only being used to generate the data.  We'll use a View to select the data
SET @SQLDrop = 
'IF OBJECT_ID(''' + REPLACE(@SourceView,'.vw','') + '_PreComputeTable'') IS NOT NULL BEGIN DROP EXTERNAL TABLE ' + REPLACE(@SourceView,'.vw','') + '_PreComputeTable END'

EXEC sp_executesql @SQLDrop


--drop the existing precompute View, we will re-create it
SET @SQLDrop = 
'IF OBJECT_ID(''' + @SourceView + '_PreComputeCurrent'') IS NOT NULL BEGIN DROP VIEW ' + @SourceView + '_PreComputeCurrent END'

EXEC sp_executesql @SQLDrop

--create a view to show the current data
SET @CreateCurrentAggregateView = 
'CREATE VIEW ' + @SourceView + '_PreComputeCurrent
AS
WITH CurrentFolder
AS
(
    SELECT MAX(fct.filepath(1)) AS CurrentAggregates
    FROM 
    OPENROWSET
    (
        BULK ''' + @LocationTopLevel + '/*/*.parquet'',     
        DATA_SOURCE = ''' + @DataSource + ''',
        FORMAT = ''Parquet''
    ) AS fct
)
SELECT fct.filepath(1) AS CurrentAggregateFolder,
*    
FROM
 OPENROWSET
(
    BULK ''' + @LocationTopLevel + '/*/*.parquet'',     
    DATA_SOURCE = ''' + @DataSource + ''',
    FORMAT = ''Parquet''
) AS fct
WHERE fct.filepath(1) IN (SELECT CurrentAggregates FROM CurrentFolder)'

EXEC sp_executesql @CreateCurrentAggregateView

END;
