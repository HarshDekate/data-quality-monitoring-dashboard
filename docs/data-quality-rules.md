# Data Quality Validation Rules

**Project:** Data Quality Monitoring & Validation Dashboard  
**Domain:** Synthetic residential property data  
**Tools:** SQL Server / SSMS, Excel, Power BI, DAX  
**Dataset size:** 203 records

## 1. Purpose

This document defines the validation rules used to identify potential data-quality issues in the sample property dataset. The rules cover completeness, validity, consistency, and uniqueness.

The dataset is synthetic and intended for learning and portfolio demonstration. The results do not represent production or customer data.

## 2. Data Quality Dimensions

| Dimension | Meaning | Example |
|---|---|---|
| Completeness | Required fields have values | City is not blank |
| Validity | Values follow defined rules | Stories is between 1 and 5 |
| Consistency | Values follow an allowed format or category | ReviewStatus uses an approved value |
| Uniqueness | Identifiers do not unintentionally repeat | RecordID is unique |
| Accuracy | Values match a reliable real-world source | RoofType matches verified property information |

This project directly checks completeness, validity, consistency, and uniqueness. Accuracy cannot be confirmed from synthetic data alone.

## 3. Dataset Fields

The dataset contains these 11 fields:

| Column | Expected type | Validation purpose |
|---|---|---|
| `RecordID` | Text | Check missing and duplicate identifiers |
| `InspectionDate` | Date | Check missing or invalid dates |
| `PropertyType` | Text | Property category |
| `City` | Text | Check missing city values |
| `RoofType` | Text | Check missing roof classification |
| `SidingType` | Text | Check missing siding classification |
| `Stories` | Whole number | Check missing and out-of-range values |
| `HazardType` | Text | Check missing hazard information |
| `ReviewStatus` | Text | Check allowed status values |
| `ReviewerID` | Text | Identify the reviewer |
| `OrderValue` | Decimal number | Check negative or missing values |

> **SQL table-name note:** The SQL examples use `dbo.PropertyData` as a placeholder. Replace it with the actual table name in your database before running the queries.

## 4. Validation Rules

### DQ001 — Missing City

- **Dimension:** Completeness
- **Severity:** High
- **Rule:** City must not be NULL, empty, or whitespace-only.
- **Observed result:** 11 records identified.

```sql
SELECT RecordID, City
FROM dbo.PropertyData
WHERE City IS NULL
   OR LTRIM(RTRIM(City)) = '';
```

**Recommended action:** Verify the city from an approved source before correcting the record. Do not infer missing values without evidence.

### DQ002 — Missing RoofType

- **Dimension:** Completeness
- **Severity:** High
- **Rule:** RoofType must not be NULL, empty, or whitespace-only.
- **Observed result:** 10 records identified.

```sql
SELECT RecordID, RoofType
FROM dbo.PropertyData
WHERE RoofType IS NULL
   OR LTRIM(RTRIM(RoofType)) = '';
```

**Recommended action:** Review the source information and populate the classification only when it can be verified.

### DQ003 — Missing SidingType

- **Dimension:** Completeness
- **Severity:** Medium
- **Rule:** SidingType must not be NULL, empty, or whitespace-only when required.
- **Observed result:** 0 records identified.

```sql
SELECT RecordID, SidingType
FROM dbo.PropertyData
WHERE SidingType IS NULL
   OR LTRIM(RTRIM(SidingType)) = '';
```

**Recommended action:** Continue checking this field on future data refreshes.

### DQ004 — Missing HazardType

- **Dimension:** Completeness
- **Severity:** High
- **Rule:** HazardType must be populated when required by the dataset specification.
- **Observed result:** 5 records identified.

```sql
SELECT RecordID, HazardType, City
FROM dbo.PropertyData
WHERE HazardType IS NULL
   OR LTRIM(RTRIM(HazardType)) = '';
```

**Recommended action:** Investigate whether the field is missing, unavailable, or needs clarification. A value such as `None` is not the same as a blank value; confirm its business meaning before treating it as valid.

### DQ005 — Invalid Stories

- **Dimension:** Validity
- **Severity:** High
- **Rule:** Stories must be a whole number from 1 through 5, inclusive. This is a project-specific practice rule, not a universal property standard.
- **Failure conditions:** NULL, less than 1, or greater than 5.
- **Observed result:** 8 records identified.

```sql
SELECT RecordID, Stories
FROM dbo.PropertyData
WHERE Stories IS NULL
   OR Stories < 1
   OR Stories > 5;
```

**Recommended action:** Verify the value against source information and correct it only when supported by evidence.

### DQ006 — Invalid ReviewStatus

- **Dimension:** Validity and consistency
- **Severity:** High
- **Allowed values:** `Approved`, `Needs Review`, `Rejected`
- **Observed result:** 6 records identified.

```sql
SELECT RecordID, ReviewStatus
FROM dbo.PropertyData
WHERE ReviewStatus IS NULL
   OR LTRIM(RTRIM(ReviewStatus)) NOT IN
      ('Approved', 'Needs Review', 'Rejected');
```

**Example:** `Pending??` is invalid under this project's allowed-value list.

**Recommended action:** Confirm the intended status with the source or business owner. Do not automatically change an unexpected value to `Approved` or another allowed category.

**Implementation note:** If the database uses a case-sensitive collation, differences in capitalization may also fail this check. Apply trimming and case normalization if the project requirements allow it.

### DQ007 — Negative or Missing OrderValue

- **Dimension:** Validity and completeness
- **Severity:** Medium
- **Rule:** OrderValue must not be negative and must be present when required.
- **Observed result:** 6 records identified by the combined negative-or-missing check.

```sql
SELECT RecordID, OrderValue
FROM dbo.PropertyData
WHERE OrderValue < 0
   OR OrderValue IS NULL;
```

**Recommended action:** Inspect the records to determine whether the value is missing, incorrectly entered, or legitimately negative under a documented rule.

**Note:** The combined count does not show how many records are negative versus missing. Run separate checks if those counts need to be reported independently.

### DQ008 — Duplicate RecordID

- **Dimension:** Uniqueness
- **Severity:** High
- **Rule:** RecordID should identify one unique record.
- **Observed result:** 3 distinct duplicated IDs.

```sql
SELECT
    RecordID,
    COUNT(*) AS Occurrences
FROM dbo.PropertyData
GROUP BY RecordID
HAVING COUNT(*) > 1;
```

The duplicated IDs found were:

| RecordID | Occurrences |
|---|---:|
| `REC0011` | 2 |
| `REC0036` | 2 |
| `REC0071` | 2 |

These are 3 distinct duplicated identifiers and 6 rows associated with them. There are 3 extra occurrences beyond one row per identifier.

**Recommended action:** Compare the rows to determine whether they are accidental duplicates or legitimate separate records. Do not delete rows based only on a repeated ID.

### DQ009 — Missing InspectionDate

- **Dimension:** Completeness
- **Severity:** Medium
- **Rule:** InspectionDate should be populated.

```sql
SELECT RecordID, InspectionDate
FROM dbo.PropertyData
WHERE InspectionDate IS NULL;
```

**Status:** A result count has not been verified for this rule.

If the source column is text rather than a date type, separately validate whether each nonblank value can be converted to a date.

### DQ010 — Missing RecordID

- **Dimension:** Completeness and uniqueness
- **Severity:** High
- **Rule:** RecordID must not be NULL, empty, or whitespace-only.

```sql
SELECT *
FROM dbo.PropertyData
WHERE RecordID IS NULL
   OR LTRIM(RTRIM(RecordID)) = '';
```

**Status:** A result count has not been verified for this rule.

## 5. Current Validation Summary

| Validation check | Observed count |
|---|---:|
| Total records | 203 |
| Missing City | 11 |
| Missing RoofType | 10 |
| Missing SidingType | 0 |
| Missing HazardType | 5 |
| Invalid Stories | 8 |
| Invalid ReviewStatus | 6 |
| Negative or missing OrderValue | 6 |
| Distinct duplicated RecordIDs | 3 |

These counts are validation findings, not necessarily unique affected records. A single record can fail more than one rule. Do not add the issue counts together to estimate unique affected records.

## 6. Validation Workflow

1. Inspect the source CSV and confirm its columns.
2. Import the dataset into SQL Server.
3. Check and set appropriate column data types.
4. Run each validation query.
5. Record results and investigate exceptions.
6. Cross-check selected counts in Excel.
7. Create DAX measures for selected checks in Power BI.
8. Display the results in KPI cards, a city bar chart, slicers, and a detail table.
9. Re-run checks after data corrections or refreshes.
10. Update this document when rules or counts change.

## 7. Limitations

- The dataset is synthetic and intended for portfolio use.
- Counts depend on the current dataset and the rules defined here.
- A populated field does not prove that its value is accurate.
- The Stories range of 1–5 is specific to this practice project.
- The OrderValue result combines negative and missing values.
- The InspectionDate and missing RecordID checks are documented, but their result counts have not been verified.
- SQL examples must use the actual table name and compatible data types in the user's database.

## 8. Future Enhancements

- Report negative and missing OrderValue separately.
- Add checks for missing `ReviewerID` and `PropertyType`.
- Add validation for invalid `PropertyType` and `RoofType` categories using a confirmed allowed-value list.
- Track data-quality findings across refreshes.
- Build a configurable validation-rule table.
- Define a transparent data-quality score.
- Automate exception summaries and alerts.

## Disclaimer

This is a learning and portfolio project using synthetic practice data. It demonstrates data-validation and dashboard-development techniques and does not claim verified production-business performance.
