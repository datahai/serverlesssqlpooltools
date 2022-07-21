/**
this is example usage of the view in sqlcreatequeryviewforstoragelogs
amend the OPENROWSET values accordingly and also the transformation on the column name such as "EventDate" to suit folder partition schema
**/

--aggregate by the source EventMonth and show how many unique files were scanned
SELECT 
    statusText,
    CAST(REPLACE(SUBSTRING(uri,PATINDEX('%EventMonth=%',uri)+11,2),'/','') AS TINYINT) AS URIFolderMonth,
    COUNT(DISTINCT uri) AS FileScanCount
FROM dbo.vwAnalyseLogs
WHERE LogYear = 2022
AND LogMonth = '07'
AND LogDay = '20'
AND LogHour = '20'
AND operationName = 'ReadFile'
AND identity_delegatedResource_resourceId LIKE '%dhsynapsews%' --synapse workspace
GROUP BY
    statusText,
    CAST(REPLACE(SUBSTRING(uri,PATINDEX('%EventMonth=%',uri)+11,2),'/','') AS TINYINT)
ORDER BY 2

--aggregate by the source EventMonth and EventDate folder and show how many unique files were scanned
SELECT 
    statusText,
    CAST(REPLACE(SUBSTRING(uri,PATINDEX('%EventMonth=%',uri)+11,2),'/','') AS TINYINT) AS URIFolderMonth,
    SUBSTRING(uri,PATINDEX('%EventDate=%',uri)+10,10) AS URIFolderDate,
    COUNT(DISTINCT uri) AS FileScanCount
FROM dbo.vwAnalyseLogs
WHERE LogYear = 2022
AND LogMonth = '07'
AND LogDay = '21'
AND LogHour = '12'
AND operationName = 'ReadFile'
AND identity_delegatedResource_resourceId LIKE '%dhsynapsews%'
GROUP BY
    statusText,
    CAST(REPLACE(SUBSTRING(uri,PATINDEX('%EventMonth=%',uri)+11,2),'/','') AS TINYINT),
    SUBSTRING(uri,PATINDEX('%EventDate=%',uri)+10,10)
ORDER BY 3
