USE [AdventureWorks2012]
GO

--a
ALTER TABLE [dbo].[Person]
ADD
	[SalesYTD]		MONEY,
	[SalesLastYear] MONEY,
	[OrdersNum]		INT;
GO

ALTER TABLE [dbo].[Person]
ADD
	[SalesDiff] AS ([SalesLastYear] - [SalesYTD]);
GO

--b
CREATE TABLE #Person (
	[BusinessEntityID]	INT,
	[PersonType]		NCHAR(2),
	[NameStyle]			BIT,
	[Title]				NVARCHAR(8),
	[FirstName]			NVARCHAR(50),
	[MiddleName]		NVARCHAR(50),
	[LastName]			NVARCHAR(50),
	[Suffix]			NVARCHAR(5),
	[EmailPromotion]	INT,
	[ModifiedDate]		DATETIME,
	[ID]				BIGINT,
	[SalesYTD]			MONEY,
	[SalesLastYear]		MONEY,
	[OrdersNum]			INT
);
GO

--c
WITH [OrdersNum_CTE] AS (
	SELECT
		[SalesPersonID]			AS [BusinessEntityID],
		COUNT([SalesOrderID])	AS Count
	FROM [Sales].[SalesOrderHeader]
	WHERE [SalesPersonID] IS NOT NULL
	GROUP BY [SalesPersonID]
)
INSERT INTO #Person (
	[BusinessEntityID],
	[PersonType],
	[NameStyle],
	[Title],
	[FirstName],
	[MiddleName],
	[LastName],
	[Suffix],
	[EmailPromotion],
	[ModifiedDate],
	[ID],
	[SalesYTD],
	[SalesLastYear],
	[OrdersNum]
)
SELECT
	[person].[BusinessEntityID],
	[person].[PersonType],
	[person].[NameStyle],
	[person].[Title],
	[person].[FirstName],
	[person].[MiddleName],
	[person].[LastName],
	[person].[Suffix],
	[person].[EmailPromotion],
	[person].[ModifiedDate],
	[person].[ID],
	[sales].[SalesYTD],
	[sales].[SalesLastYear],
	[OrdersNum_CTE].Count
FROM [dbo].[Person] [person]
LEFT JOIN [Sales].[SalesPerson] [sales] ON [sales].[BusinessEntityID]	= [person].[BusinessEntityID]
LEFT JOIN [OrdersNum_CTE] ON [OrdersNum_CTE].[BusinessEntityID]	= [person].[BusinessEntityID];

--d
DELETE FROM [dbo].[Person] 
	WHERE [BusinessEntityID] = 290;

--e
MERGE INTO [dbo].[Person] AS [target_t]
USING #Person AS [source_t] ON [target_t].[BusinessEntityID] = [source_t].[BusinessEntityID]
WHEN MATCHED THEN
	UPDATE SET
		[target_t].[SalesYTD]		= [source_t].[SalesYTD],
		[target_t].[SalesLastYear]	= [source_t].[SalesLastYear],
		[target_t].[OrdersNum]		= [source_t].[OrdersNum]
WHEN NOT MATCHED BY TARGET THEN
	INSERT (
		[BusinessEntityID],
		[PersonType],
		[NameStyle],
		[Title],
		[FirstName],
		[MiddleName],
		[LastName],
		[Suffix],
		[EmailPromotion],
		[ModifiedDate],
		[SalesYTD],
		[SalesLastYear],
		[OrdersNum]
	)
	VALUES (
		[source_t].[BusinessEntityID],
		[source_t].[PersonType],
		[source_t].[NameStyle],
		[source_t].[Title],
		[source_t].[FirstName],
		[source_t].[MiddleName],
		[source_t].[LastName],
		[source_t].[Suffix],
		[source_t].[EmailPromotion],
		[source_t].[ModifiedDate],
		[source_t].[SalesYTD],
		[source_t].[SalesLastYear],
		[source_t].[OrdersNum]
	)
WHEN NOT MATCHED BY SOURCE THEN
	DELETE;