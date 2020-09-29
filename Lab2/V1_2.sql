USE AdventureWorks2012;
GO

--a
CREATE TABLE [dbo].[Person] (
	[BusinessEntityID] INT,
	[PersonType] nchar(2),
	[NameStyle] NameStyle NULL,
	[Title] nvarchar(8),
	[FirstName] Name,
	[MiddleName] Name,
	[LastName] Name,
	[Suffix] nvarchar(10),
	[EmailPromotion] INT,
	[ModifiedDate] datetime
);
GO

--b
ALTER TABLE [dbo].[Person]
ADD [ID] bigint PRIMARY KEY IDENTITY(10, 10);
GO

--c
ALTER TABLE [dbo].[Person]
ADD CONSTRAINT [CHK_Title] CHECK ([Title] IN ('Mr.', 'Ms.'));
GO

--d
ALTER TABLE [dbo].[Person]
ADD CONSTRAINT [DF_Suffix] DEFAULT 'N/A' FOR [Suffix];
GO

--e
INSERT INTO [dbo].[Person] (
	[BusinessEntityID],
	[PersonType],
	[NameStyle],
	[Title],
	[FirstName],
	[MiddleName],
	[LastName],
	[Suffix],
	[EmailPromotion],
	[ModifiedDate]
) SELECT 
	[person].[BusinessEntityID],
	[person].[PersonType],
	[person].[NameStyle],
	[person].[Title],
	[person].[FirstName],
	[person].[MiddleName],
	[person].[LastName],
	[person].[Suffix],
	[person].[EmailPromotion],
	[person].[ModifiedDate]
FROM [Person].[Person] 
INNER JOIN [HumanResources].[Employee] ON [HumanResources].[Employee].[BusinessEntityID] = [Person].[Person].[BusinessEntityID]
LEFT JOIN  [HumanResources].[EmployeeDepartmentHistory] ON [HumanResources].[EmployeeDepartmentHistory].[BusinessEntityID] = [HumanResources].[Employee].[BusinessEntityID] 
LEFT JOIN  [HumanResources].[Department] ON [HumanResources].[Department].[DepartmentID] = [HumanResources].[EmployeeDepartmentHistory].[DepartmentID]
WHERE
	[HumanResources].[EmployeeDepartmentHistory].[EndDate] IS NULL
	AND [HumanResources].[Department].[Name] <> 'Executive';
GO

--f
ALTER TABLE [dbo].[Person]
ALTER COLUMN [Suffix] nvarchar(5);
GO