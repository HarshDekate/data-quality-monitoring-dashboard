-- SQL Server (T-SQL). Import CSV as dbo.PropertyData first.
SELECT COUNT(*) AS TotalRecords FROM dbo.PropertyData;

-- Duplicate IDs
SELECT RecordID, COUNT(*) AS Occurrences
FROM dbo.PropertyData GROUP BY RecordID HAVING COUNT(*) > 1;

-- Missing required fields
SELECT
 SUM(CASE WHEN City IS NULL OR LTRIM(RTRIM(City))='' THEN 1 ELSE 0 END) AS MissingCity,
 SUM(CASE WHEN RoofType IS NULL OR LTRIM(RTRIM(RoofType))='' THEN 1 ELSE 0 END) AS MissingRoofType,
 SUM(CASE WHEN SidingType IS NULL OR LTRIM(RTRIM(SidingType))='' THEN 1 ELSE 0 END) AS MissingSiding,
 SUM(CASE WHEN HazardType IS NULL OR LTRIM(RTRIM(HazardType))='' THEN 1 ELSE 0 END) AS MissingHazard
FROM dbo.PropertyData;

-- Invalid stories
SELECT * FROM dbo.PropertyData WHERE Stories IS NULL OR Stories < 1 OR Stories > 5;

-- Invalid status
SELECT * FROM dbo.PropertyData
WHERE ReviewStatus NOT IN ('Approved','Needs Review','Rejected');

-- Invalid order value
SELECT * FROM dbo.PropertyData WHERE OrderValue IS NULL OR OrderValue < 0;

-- Row-level quality flags
SELECT *,
 CASE WHEN City IS NULL OR LTRIM(RTRIM(City))='' THEN 1 ELSE 0 END AS MissingCityFlag,
 CASE WHEN RoofType IS NULL OR LTRIM(RTRIM(RoofType))='' THEN 1 ELSE 0 END AS MissingRoofFlag,
 CASE WHEN SidingType IS NULL OR LTRIM(RTRIM(SidingType))='' THEN 1 ELSE 0 END AS MissingSidingFlag,
 CASE WHEN HazardType IS NULL OR LTRIM(RTRIM(HazardType))='' THEN 1 ELSE 0 END AS MissingHazardFlag,
 CASE WHEN Stories IS NULL OR Stories < 1 OR Stories > 5 THEN 1 ELSE 0 END AS InvalidStoriesFlag,
 CASE WHEN ReviewStatus NOT IN ('Approved','Needs Review','Rejected') THEN 1 ELSE 0 END AS InvalidStatusFlag,
 CASE WHEN OrderValue IS NULL OR OrderValue < 0 THEN 1 ELSE 0 END AS InvalidOrderValueFlag
FROM dbo.PropertyData;

-- Issues by city
SELECT COALESCE(City,'Missing City') AS CityGroup, COUNT(*) AS TotalRecords,
 SUM(CASE WHEN City IS NULL OR LTRIM(RTRIM(City))=''
   OR RoofType IS NULL OR LTRIM(RTRIM(RoofType))=''
   OR SidingType IS NULL OR LTRIM(RTRIM(SidingType))=''
   OR HazardType IS NULL OR LTRIM(RTRIM(HazardType))=''
   OR Stories IS NULL OR Stories < 1 OR Stories > 5
   OR ReviewStatus NOT IN ('Approved','Needs Review','Rejected')
   OR OrderValue IS NULL OR OrderValue < 0 THEN 1 ELSE 0 END) AS RecordsWithIssues
FROM dbo.PropertyData
GROUP BY COALESCE(City,'Missing City')
ORDER BY RecordsWithIssues DESC;
