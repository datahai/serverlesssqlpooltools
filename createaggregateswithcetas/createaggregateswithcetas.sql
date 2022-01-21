CREATE PROCEDURE LDW.GeneratePreComputedDatasets @SourceView VARCHAR(100)
AS

BEGIN

DECLARE @Location VARCHAR(100),
        @LocationTopLevel VARCHAR(100),
        @ProcessDate CHAR(16),
        @SQLDrop NVARCHAR(2000),
        @CreateExternalTableString NVARCHAR(2000),
        @CreateCurrentAggregateView NVARCHAR(2000)

SET @ProcessDate = FORMAT(GETDATE(),'yyyyMMddHHmmss')

SET @SQLDrop = 
'IF OBJECT_ID(''' + REPLACE(@SourceView,'.vw','') + '_PreComputeTable'') IS NOT NULL BEGIN DROP EXTERNAL TABLE ' + REPLACE(@SourceView,'.vw','') + '_PreComputeTable END'

EXEC sp_executesql @SQLDrop

SET @Location = CONCAT('precomputeddatasets/dataminutes2/',REPLACE(@SourceView,'.',''),'/',@ProcessDate)
SET @LocationTopLevel = CONCAT('precomputeddatasets/dataminutes2/',REPLACE(@SourceView,'.',''))

SET @CreateExternalTableString = 
'CREATE EXTERNAL TABLE ' + REPLACE(@SourceView,'.vw','') + '_PreComputeTable
WITH 
(
  LOCATION = ''' + @location + ''',                                      
  DATA_SOURCE = ExternalDataSourceDataLakeMI,
  FILE_FORMAT = SynapseParquetFormat
)
AS
SELECT 
   *
FROM ' + @SourceView

EXEC sp_executesql @CreateExternalTableString

SET @SQLDrop = 
'IF OBJECT_ID(''' + REPLACE(@SourceView,'.vw','') + '_PreComputeTable'') IS NOT NULL BEGIN DROP EXTERNAL TABLE ' + REPLACE(@SourceView,'.vw','') + '_PreComputeTable END'

EXEC sp_executesql @SQLDrop

SET @SQLDrop = 
'IF OBJECT_ID(''' + @SourceView + '_PreComputeCurrent'') IS NOT NULL BEGIN DROP VIEW ' + @SourceView + '_PreComputeCurrent END'

EXEC sp_executesql @SQLDrop

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
        DATA_SOURCE = ''ExternalDataSourceDataLakeMI'',
        FORMAT = ''Parquet''
    ) AS fct
)
SELECT fct.filepath(1) AS CurrentAggregateFolder,
*    
FROM
 OPENROWSET
(
    BULK ''' + @LocationTopLevel + '/*/*.parquet'',     
    DATA_SOURCE = ''ExternalDataSourceDataLakeMI'',
    FORMAT = ''Parquet''
) AS fct
WHERE fct.filepath(1) IN (SELECT CurrentAggregates FROM CurrentFolder)'

EXEC sp_executesql @CreateCurrentAggregateView

END;
