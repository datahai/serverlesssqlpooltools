CREATE VIEW dbo.ShowFileErrors
AS
SELECT
    [Error],
    [Row],
    [Column],
    ColumnName,
    Value,
    [File],   
    rowdata.filepath(1) AS ErrorFolderName
FROM OPENROWSET(
        BULK '<path_to_your_error_folder>/_rejectedrows/*/error.json',
        DATA_SOURCE = '<your_external_data_source>',
        FORMAT = 'CSV',
        FIELDTERMINATOR ='0x0b',
        FIELDQUOTE = '0x0b',
        ROWTERMINATOR = '0x0b'
    ) WITH (doc NVARCHAR(MAX)) AS rowdata
   CROSS APPLY openjson (doc)
        WITH (  [Error] VARCHAR(1000) '$.Error',
                [Row] INT '$.Row',
                [Column] INT '$.Column',
                ColumnName VARCHAR(1000) '$.ColumnName',
                Value VARCHAR(1000) '$.Value',
                [File] VARCHAR(1000) '$.File')
