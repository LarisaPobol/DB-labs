USE AdventureWorks2012;
GO

--a
ALTER TABLE [dbo].[Person]
ADD [FullName] nvarchar(100);
GO

--b
DECLARE @Person TABLE (
	[BusinessEntityID]	int,
	[PersonType]		nchar(2),
	[NameStyle]			NameStyle NULL,
	[Title]				nvarchar(8),
	[FirstName]			Name,
	[MiddleName]		Name,
	[LastName]			Name,
	[Suffix]			nvarchar(5),
	[EmailPromotion]	int,
	[ModifiedDate]		datetime,
	[ID]				bigint,
	[FullName]			nvarchar(100)
);

INSERT INTO @Person (
	[BusinessEntityID], [PersonType], [NameStyle],
	[Title],
	[FirstName], [MiddleName], [LastName],
	[Suffix], [EmailPromotion], [ModifiedDate],
	[ID],
	[FullName]
)
SELECT
	[person].[BusinessEntityID], [person].[PersonType], [person].[NameStyle],
	CASE [employee].[Gender]
		WHEN 'M' THEN 'Mr.'
		WHEN 'F' THEN 'Ms.'
		ELSE NULL
	END as [Title],
	[person].[FirstName], [person].[MiddleName], [person].[LastName],
	[person].[Suffix], [person].[EmailPromotion], [person].[ModifiedDate],
	[person].[ID], [person].[FullName]
FROM [dbo].[Person] [person]
LEFT JOIN [HumanResources].[Employee] [employee] ON [employee].[BusinessEntityID] = [person].[BusinessEntityID];

--c
UPDATE [dbo].[Person]
SET		
		[FullName] = CONCAT([Person].[Title], ' ', [Person].[FirstName], ' ', [Person].[LastName])
FROM	[dbo].[Person] [personTable]
LEFT JOIN  @Person as [Person] on [Person].[BusinessEntityID] = [personTable].[BusinessEntityID]

--d
DELETE FROM [dbo].[Person] 
	WHERE LEN([FullName]) > 20;

--e
DECLARE @Sql NVARCHAR(200) = N'';

SELECT  @Sql += N'ALTER TABLE ' + 'dbo' + '.[' + 'Person' + '] DROP CONSTRAINT ' + [CONSTRAINTS].[CONSTRAINT_NAME] + ';'
	FROM [AdventureWorks2012].[INFORMATION_SCHEMA].[CONSTRAINT_TABLE_USAGE] as [CONSTRAINTS]
	WHERE [TABLE_SCHEMA] = 'dbo' AND [TABLE_NAME] = 'Person';

PRINT(@Sql)
EXECUTE(@Sql)

ALTER TABLE [dbo].[Person]
DROP COLUMN [ID];

--f
DROP TABLE [dbo].[Person];