USE AdventureWorks2012
GO

-- =============================================
-- Author:		Larisa Pobol
-- Create date: 11/6/2020
-- Description:	returns a pivot table showing the total number of products sold for a specific year
-- =============================================
CREATE PROCEDURE [dbo].[uspOrdersByYear]
	@yearStr nvarchar(255)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @query AS NVARCHAR(1024);
    SET @query = 
		'SELECT Name, ' + @yearStr + ' FROM (
			SELECT
				[product].[Name],
				YEAR([header].[OrderDate]) as [year],
				[detail].[OrderQty]
			FROM [Sales].[SalesOrderDetail] [detail]
			INNER JOIN [Sales].[SalesOrderHeader] [header]	ON [detail].[SalesOrderID]	= [header].[SalesOrderID]
			INNER JOIN [Production].[Product] [product]		ON [product].[ProductID]	= [detail].[ProductID]
		) as [data]
		PIVOT (
			SUM([data].[OrderQty]) FOR [data].[year] IN(' + @yearStr + ')
		) as [history]
	';
	EXECUTE sp_executesql @query;
END
GO

EXECUTE  [dbo].[uspOrdersByYear] '[2008], [2007], [2006]';