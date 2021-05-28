USE <specific_database>;
GO

SELECT et.[name] AS TableName,
et.[location] AS TableLocation,
ef.[name] AS FileFormatName,
ef.[format_type] AS FileFormatType,
es.[name] AS DataSourceName,
es.[location] AS DataSourceLocation
FROM sys.external_tables et
INNER JOIN sys.external_file_formats ef ON ef.file_format_id = et.file_format_id
INNER JOIN sys.external_data_sources es ON es.data_source_id = et.data_source_id
