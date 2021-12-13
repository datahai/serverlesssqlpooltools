CREATE PROC dbo.spGenerateViews 
        @FileFormat NVARCHAR(50),
        @HeaderRow NVARCHAR(5),
        @FieldTerminator NCHAR(1),
        @ViewName NCHAR(50),
        @ExternalDataSourceDataLake NVARCHAR(255),
        @Location NVARCHAR(255),
        @FolderHierarchyDepth TINYINT,
        @DropView BIT,
        @MaxVarcharValue SMALLINT
AS
BEGIN

--System variables
DECLARE @FileFormatString NVARCHAR(255),
         @SchemaSQL NVARCHAR(MAX);

------------------------------------
IF @FileFormat = 'Parquet'
BEGIN
    SET @FileFormatString = 'FORMAT = ''Parquet'''
END
ELSE
BEGIN   

    SET @FileFormatString = '
        FORMAT = '''+ @FileFormat + ''',
        PARSER_VERSION = ''2.0'',
        HEADER_ROW = ' + @HeaderRow + ',
        FIELDTERMINATOR ='''+ @FieldTerminator + ''''
END

CREATE TABLE #t (
    is_hidden bit NOT NULL, 
    column_ordinal int NOT NULL, 
    name sysname NULL, 
    is_nullable bit NOT NULL, 
    system_type_id int NOT NULL, 
    system_type_name nvarchar(256) NULL, 
    max_length smallint NOT NULL, 
    [precision] tinyint NOT NULL, 
    scale tinyint NOT NULL, 
    collation_name sysname NULL, 
    user_type_id int NULL, 
    user_type_database sysname NULL, 
    user_type_schema sysname NULL, 
    user_type_name sysname NULL, 
    assembly_qualified_type_name nvarchar(4000), 
    xml_collection_id int NULL, 
    xml_collection_database sysname NULL, 
    xml_collection_schema sysname NULL, 
    xml_collection_name sysname NULL, 
    is_xml_document bit NOT NULL, 
    is_case_sensitive bit NOT NULL, 
    is_fixed_length_clr_type bit NOT NULL, 
    source_server nvarchar(128), 
    source_database nvarchar(128), 
    source_schema nvarchar(128), 
    source_table nvarchar(128), 
    source_column nvarchar(128), 
    is_identity_column bit NULL, 
    is_part_of_unique_key bit NULL, 
    is_updateable bit NULL, 
    is_computed_column bit NULL, 
    is_sparse_column_set bit NULL, 
    ordinal_in_order_by_list smallint NULL, 
    order_by_list_length smallint NULL, 
    order_by_is_descending smallint NULL, 
    tds_type_id int NOT NULL, 
    tds_length int NOT NULL, 
    tds_collation_id int NULL, 
    tds_collation_sort_id tinyint NULL
)

SET @SchemaSQL = CAST('
   SELECT * FROM 
    OPENROWSET 
    (
        BULK ''' + CAST(@Location AS NVARCHAR(MAX)) + ''',
        DATA_SOURCE = ''' + CAST(@ExternalDataSourceDataLake AS NVARCHAR(MAX)) + ''',' 
        + CAST(@FileFormatString AS NVARCHAR(MAX)) + '
       
    ) AS fct' AS NVARCHAR(MAX))

INSERT INTO #t EXEC sp_describe_first_result_set @tsql = @SchemaSQL

DECLARE @mincol INT,
        @maxcol INT,
        @sqltext NVARCHAR(4000)

SELECT @mincol = MIN(column_ordinal) FROM #t
SELECT @maxcol = MAX(column_ordinal) FROM #t

set @sqltext = 'CREATE VIEW ' + @ViewName + ' AS SELECT '

WHILE @mincol <= @maxcol
BEGIN
    SELECT @sqltext = @sqltext + CONCAT('CAST('
                                        ,[name]
                                        ,' AS '
                                        ,CASE WHEN system_type_name LIKE 'varchar%' THEN 'varchar(' + CAST(@MaxVarcharValue AS NVARCHAR(5)) + ')' ELSE system_type_name END + ') AS '
                                        ,[name]
                                        ,CASE WHEN @mincol = @maxcol THEN '' ELSE ',' END)
    FROM #t
    WHERE column_ordinal = @mincol

    SET @mincol = @mincol +1
END

DECLARE @Loop INT = 1,
        @sqlhierarchytext NVARCHAR(500) = ''

WHILE @Loop <= @FolderHierarchyDepth
BEGIN
    SET @sqlhierarchytext = @sqlhierarchytext + ', fct.filepath('+ CAST(@Loop AS VARCHAR(10)) + ') AS FilePath' + CAST(@Loop AS VARCHAR(10))

    SET @Loop = @Loop + 1
END

SET @sqltext = @sqltext + @sqlhierarchytext + ' FROM 
  OPENROWSET 
    (
        BULK ''' + @Location + ''',
        DATA_SOURCE = ''' + @ExternalDataSourceDataLake + ''',' 
        + @FileFormatString + '
       
    ) AS fct'

--DROP VIEW
IF @DropView = 1
BEGIN

    IF OBJECT_ID (@ViewName, N'V') IS NOT NULL  
    BEGIN
        DECLARE @DropSQL NVARCHAR(255)

        SET @DropSQL = 'DROP VIEW ' + @ViewName

        EXEC sp_executesql @tsl = @DropSQL
    END
END

--CREATE VIEW
EXEC sp_executesql @tsl = @sqltext

END

GO
