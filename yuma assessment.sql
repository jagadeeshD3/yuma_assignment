Exploring the data:

select * from yuma_sales_data;

describe yuma_sales_data;

select count(*) from yuma_sales_data;

SELECT 
    COUNT(CASE WHEN TransactionID IS NULL THEN 1 END) AS TransactionID_Null_Count,
    COUNT(CASE WHEN CustomerID IS NULL THEN 1 END) AS CustomerID_Null_Count,
    COUNT(CASE WHEN TransactionDate IS NULL THEN 1 END) AS TransactionDate_Null_Count,
    COUNT(CASE WHEN ProductID IS NULL THEN 1 END) AS ProductID_Null_Count,
    COUNT(CASE WHEN ProductCategory IS NULL THEN 1 END) AS ProductCategory_Null_Count,
    COUNT(CASE WHEN Quantity IS NULL THEN 1 END) AS Quantity_Null_Count,
    COUNT(CASE WHEN PricePerUnit IS NULL THEN 1 END) AS PricePerUnit_Null_Count,
    COUNT(CASE WHEN TotalAmount IS NULL THEN 1 END) AS TotalAmount_Null_Count,
    COUNT(CASE WHEN TrustPointsUsed IS NULL THEN 1 END) AS TrustPointsUsed_Null_Count,
    COUNT(CASE WHEN PaymentMethod IS NULL THEN 1 END) AS PaymentMethod_Null_Count,
    COUNT(CASE WHEN DiscountApplied IS NULL THEN 1 END) AS DiscountApplied_Null_Count
FROM 
    yuma_sales_data;
	

Data preprocessing
Clean null values ( fill or remove )

UPDATE yuma_sales_data
SET CustomerID = 0
WHERE CustomerID IS NULL;

ALTER TABLE yuma_sales_data
ALTER COLUMN CustomerID INT;

ALTER TABLE yuma_sales_data
ALTER COLUMN TransactionDate DATETIME;

ALTER TABLE yuma_sales_data
ADD Date DATE;

UPDATE yuma_sales_data
SET Date = CAST(TransactionDate AS DATE);

UPDATE yuma_sales_data
SET Quantity = ABS(Quantity);

UPDATE yuma_sales_data
SET PaymentMethod = 'Unknown'
WHERE PaymentMethod IS NULL;

WITH FilteredData AS (
    SELECT *
    FROM yuma_sales_data
    WHERE TransactionDate IS NOT NULL
      AND PricePerUnit IS NOT NULL
      AND TotalAmount IS NOT NULL
);

SELECT *
FROM FilteredData;

create table new_table as
SELECT 
    ProductID,
    ProductCategory,
    AVG(PricePerUnit) AS MeanPricePerUnit
FROM 
    FilteredData
GROUP BY 
    ProductID,
    ProductCategory;


SELECT 
    a.*, 
    b.MeanPricePerUnit
INTO 
    yuma_sales_data_1 a
FROM 
    yuma_sales_data
LEFT JOIN 
    new_table b
ON 
    a.ProductID = b.ProductID
    AND a.ProductCategory = b.ProductCategory;

UPDATE yuma_sales_data_1
SET PricePerUnit = MeanPricePerUnit
where PricePerUnit is null;


ALTER TABLE yuma_sales_data_1
DROP COLUMN MeanPricePerUnit;

UPDATE yuma_sales_data_1
SET TotalAmount = Quantity * PricePerUnit,
TrustPointsUsed = ABS(TrustPointsUsed);


