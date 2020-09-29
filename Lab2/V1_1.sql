USE [AdventureWorks2012]
GO
--1
SELECT [Employee].[BusinessEntityID],
       [Employee].[JobTitle],
	   MAX([HumanResources].[EmployeePayHistory].[Rate]) AS MAXRATE
  FROM [HumanResources].[Employee]
LEFT JOIN [HumanResources].[EmployeePayHistory] ON [Employee].[BusinessEntityID] = [EmployeePayHistory].[BusinessEntityID]
  GROUP BY [employee].[BusinessEntityID], [employee].[JobTitle];

--2
SELECT	[EmployeePayHistory].[BusinessEntityID],
		[Employee].[JobTitle],
		[EmployeePayHistory].[Rate],
		DENSE_RANK() OVER (ORDER BY [EmployeePayHistory].[Rate]) AS [RankRate]
	FROM [HumanResources].[EmployeePayHistory] 
LEFT JOIN [HumanResources].[Employee] ON [Employee].[BusinessEntityID] = [EmployeePayHistory].[BusinessEntityID]
	ORDER BY [EmployeePayHistory].[Rate];

--3
SELECT	[Department].[Name] as [DepName],
		[Employee].[BusinessEntityID],
		[Employee].[JobTitle],
		[EmployeeDepartmentHistory].[ShiftID]
	FROM [HumanResources].[Department]
LEFT JOIN [HumanResources].[EmployeeDepartmentHistory] ON [EmployeeDepartmentHistory].[DepartmentID] = [Department].[DepartmentID]
LEFT JOIN [HumanResources].[Employee]  ON [Employee].[BusinessEntityID]	= [EmployeeDepartmentHistory].[BusinessEntityID]
	WHERE [EmployeeDepartmentHistory].[EndDate] IS NULL
ORDER BY [Department].[Name],
CASE WHEN [Department].[Name] = 'Document Control' THEN [EmployeeDepartmentHistory].[ShiftID] ELSE [Employee].[BusinessEntityID] END;

