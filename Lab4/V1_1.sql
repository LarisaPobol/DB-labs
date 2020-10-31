USE AdventureWorks2012;
GO

--a
CREATE TABLE [Production].[ProductCategoryHst](
	[ID] INT IDENTITY(1, 1) PRIMARY KEY,
	[Action] CHAR(6) NOT NULL CHECK (Action IN('INSERT', 'UPDATE', 'DELETE')),
	[ModifiedDate] DATETIME NOT NULL DEFAULT GETDATE(),
	[SourceID] INT NOT NULL,
	[UserName] VARCHAR(40) NOT NULL
);

--b
CREATE TRIGGER [Production].[ProductCategoryActionTrg] ON [Production].[ProductCategory]
AFTER INSERT, UPDATE, DELETE AS
	DECLARE @datetime DATETIME;
	SET		@datetime = CURRENT_TIMESTAMP;

INSERT INTO [Production].[ProductCategoryHst] (
			[Action],
			[ModifiedDate],
			[SourceID],
			[UserName]
	)
	SELECT
		'UPDATE',
		@datetime,
		[INSERTED].[ProductCategoryID],
		CURRENT_USER
	FROM [INSERTED]
	INNER JOIN [DELETED] ON [INSERTED].[ProductCategoryID] = [DELETED].[ProductCategoryID]
	UNION ALL
		SELECT
			'INSERT',
			@datetime,
			[INSERTED].[ProductCategoryID],
			CURRENT_USER
		FROM [INSERTED]
		LEFT JOIN [DELETED] ON [INSERTED].[ProductCategoryID] = [DELETED].[ProductCategoryID]
		WHERE [DELETED].[ProductCategoryID] IS NULL
	UNION ALL
		SELECT
			'DELETE',
			@datetime,
			[DELETED].[ProductCategoryID],
			CURRENT_USER
		FROM [DELETED]
		LEFT JOIN [INSERTED] ON [INSERTED].[ProductCategoryID] = [DELETED].[ProductCategoryID]
		WHERE INSERTED.ProductCategoryID IS NULL;
INSERT INTO [Production].[ProductCategory]
           ([Name]
           ,[rowguid]
           ,[ModifiedDate])
     VALUES
           ('TestName'
           ,NEWID()
           ,CURRENT_TIMESTAMP)
GO

UPDATE [Production].[ProductCategory]
   SET [Name]			= 'updatedName'
      ,[ModifiedDate]	= CURRENT_TIMESTAMP
 WHERE [Name] = 'TestName'
GO

DELETE FROM [Production].[ProductCategory]
      WHERE [Name] = 'updatedName'
GO

--c
CREATE VIEW [Production].[vProductCategory]
WITH ENCRYPTION
AS
	SELECT * FROM [Production].[ProductCategory];
GO

--d
INSERT INTO [Production].[vProductCategory]
     VALUES
           ('TestName'
           ,NEWID()
           ,CURRENT_TIMESTAMP)
GO

UPDATE [Production].[vProductCategory]
   SET [Name]			= 'updatedName'
      ,[ModifiedDate]	= CURRENT_TIMESTAMP
 WHERE [Name] = 'TestName'
GO

DELETE [Production].[vProductCategory]
      WHERE [Name] = 'updatedName'
GO

SELECT * FROM [Production].[ProductCategoryHst];