USE AdventureWorks2012
GO

DECLARE @xml XML;

SET @xml = (
    SELECT 
		[BusinessEntityID] AS '@ID', 
		[NationalIDNumber], 
		[JobTitle]
    FROM [HumanResources].[Employee]
    FOR XML PATH ('Employee'), ROOT ('Employees')
);

SELECT @xml;

CREATE TABLE #EmployeeTmp
(
    [BusinessEntityID]	int,
	[NationalIDNumber]	nvarchar(50),
	[JobTitle]			nvarchar(50)
);

INSERT INTO #EmployeeTmp
     SELECT
				node.value('@ID', 'int') as								[BusinessEntityID],
			    node.value('NationalIDNumber[1]', 'NVARCHAR(15)') as	[NationalIDNumber],
				node.value('JobTitle[1]', 'NVARCHAR(50)') as			[JobTitle]
				FROM @xml.nodes('/Employees/Employee') AS xml(node)
GO

SELECT * from #EmployeeTmp;