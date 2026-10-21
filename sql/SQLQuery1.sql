USE DataQualityProject;
GO

SELECT TOP 10 *
FROM dbo.PropertyData;

SELECT COUNT(*) AS TotalRecords
FROM dbo.PropertyData;

SELECT COUNT(*) AS MissingCityCount
FROM dbo.PropertyData
WHERE City IS NULL
   OR LTRIM(RTRIM(City)) = '';

   SELECT COUNT(*) AS MissingRoofTypeCount
FROM dbo.PropertyData
WHERE RoofType IS NULL
   OR LTRIM(RTRIM(RoofType)) = '';

   USE DataQualityProject;
GO

-- 1. Missing SidingType
SELECT COUNT(*) AS MissingSidingType
FROM dbo.PropertyData
WHERE SidingType IS NULL
   OR LTRIM(RTRIM(SidingType)) = '';

-- 2. Missing HazardType
SELECT COUNT(*) AS MissingHazardType
FROM dbo.PropertyData
WHERE HazardType IS NULL
   OR LTRIM(RTRIM(HazardType)) = '';

-- 3. Invalid Stories
SELECT COUNT(*) AS InvalidStories
FROM dbo.PropertyData
WHERE Stories IS NULL
   OR Stories < 1
   OR Stories > 5;

-- 4. Invalid ReviewStatus
SELECT COUNT(*) AS InvalidReviewStatus
FROM dbo.PropertyData
WHERE ReviewStatus NOT IN
      ('Approved', 'Needs Review', 'Rejected')
   OR ReviewStatus IS NULL;

-- 5. Negative OrderValue
SELECT COUNT(*) AS NegativeOrderValue
FROM dbo.PropertyData
WHERE OrderValue < 0
   OR OrderValue IS NULL;

   SELECT RecordID, COUNT(*) AS Occurrences
FROM dbo.PropertyData
GROUP BY RecordID
HAVING COUNT(*) > 1;

SELECT RecordID, HazardType, City, RoofType
FROM dbo.PropertyData
WHERE HazardType IS NULL
   OR LTRIM(RTRIM(HazardType)) = '';