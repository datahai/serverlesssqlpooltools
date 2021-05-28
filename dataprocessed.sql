;WITH DataUsage
AS
(
    SELECT [type] AS DataUsageWindow,
    data_processed_mb AS DataProcessedMB,
    CAST(data_processed_mb AS DECIMAL(10,3)) / 1024 AS DataProcessedGB,
    (CAST(data_processed_mb AS DECIMAL(10,3)) / 1024) / 1024 AS DataProcessedTB
    FROM sys.dm_external_data_processed
),
DataLimit
AS
(
    SELECT [name] AS DataLimitWindow,
    CASE 
        WHEN [name] LIKE '%daily%' THEN 'daily'
        WHEN [name] LIKE '%weekly%' THEN 'weekly'
        WHEN [name] LIKE '%monthly%' THEN 'monthly'
    END AS DataUsageWindow,
    value AS TBValue,
    CAST(value_in_use AS INT) AS TBValueInUse
    FROM sys.configurations
    WHERE [name] LIKE 'Data processed %'
)
SELECT DL.DataUsageWindow,
    DL.TBValueInUse,
    DU.DataProcessedMB,
    DU.DataProcessedGB,
    DU.DataProcessedTB,
    (100 / DL.TBValueInUse) * DU.DataProcessedTB AS PercentTBUsed
FROM DataLimit DL
INNER JOIN DataUsage DU ON DL.DataUsageWindow = DU.DataUsageWindow
