CREATE VIEW dbo.vwViewMetadata
AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY ViewName) AS ViewCreationOrder,
    FileFormat,
    HeaderRow,
    [FieldTerminator],
    ViewName,
    ExternalDataSourceDataLake,
    [Location],
    FolderHierarchyDepth,
    MaxVarcharValue
FROM 
OPENROWSET 
(
    BULK 'metadata/DataLakeMetaData.csv',
    DATA_SOURCE = 'ExternalDataSourceDataLake',
    FORMAT = 'CSV',
    PARSER_VERSION = '2.0',
    HEADER_ROW = TRUE,
    FIELDTERMINATOR ='|'
) rwt
