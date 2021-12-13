CREATE PROC dbo.spTriggerGenerateViews @DropView BIT
AS
BEGIN

DECLARE @LoopCountMax INT = (SELECT COUNT(*) FROM LDW.vwViewMetadata),
        @LoopCount INT = 1,
        @ExternalDataSourceDataLake NVARCHAR(255),
        @FileFormat NVARCHAR(50),
        @Location NVARCHAR(255),
        @HeaderRow NVARCHAR(5),
        @FieldTerminator NCHAR(1),
        @ViewName NCHAR(50),
        @FolderHierarchyDepth TINYINT,
        @MaxVarcharValue SMALLINT

WHILE @LoopCount <= @LoopCountMax
BEGIN

    SELECT @FileFormat = FileFormat,
            @HeaderRow = ISNULL(HeaderRow,''),
            @FieldTerminator = ISNULL([FieldTerminator],''),
            @ViewName = ViewName,
            @ExternalDataSourceDataLake = ExternalDataSourceDataLake,
            @Location = [Location],
            @FolderHierarchyDepth = FolderHierarchyDepth,
            @MaxVarcharValue = MaxVarcharValue
    FROM LDW.vwViewMetadata
    WHERE ViewCreationOrder = @LoopCount
    
    EXEC LDW.GenerateViews 
        @FileFormat,
        @HeaderRow,
        @FieldTerminator,
        @ViewName,
        @ExternalDataSourceDataLake,
        @Location,
        @FolderHierarchyDepth,
        @DropView,
        @MaxVarcharValue
        
    SET @LoopCount = @LoopCount + 1

END

END
