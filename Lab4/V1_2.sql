USE [AdventureWorks2012]
GO

----a
CREATE VIEW [Production].[vProductCategoryWithSubcategory] (
	[ProductCategoryID],
	[CategoryName],
	[CategoryRowguid],
	[CategoryModifiedDate],
	[ProductSubcategoryID],
	[SubcategoryName],
	[SubcategoryRowguid],
	[SubcategoryModifiedDate]
)
WITH ENCRYPTION, SCHEMABINDING AS
	SELECT
		[category].[ProductCategoryID],
		[category].[Name],
		[category].[rowguid],
		[category].[ModifiedDate],
		[subcategory].[ProductSubcategoryID],
		[subcategory].[Name],
		[subcategory].[rowguid],
		[subcategory].[ModifiedDate]
	FROM [Production].[ProductCategory] [category]
	INNER JOIN [Production].[ProductSubcategory] [subcategory] ON [category].[ProductCategoryID] = [subcategory].[ProductCategoryID];
GO

CREATE UNIQUE CLUSTERED INDEX [CategoryIdx] ON [Production].[vProductCategoryWithSubcategory] (ProductCategoryID, ProductSubCategoryID);
GO

--b
CREATE TRIGGER [Production].[vCategoryInsert] ON [Production].[vProductCategoryWithSubcategory]
INSTEAD OF INSERT AS
BEGIN
	INSERT INTO [Production].[ProductCategory] (
					[Name], 
					[rowguid], 
					[ModifiedDate]
	)
	SELECT			[CategoryName], 
					[CategoryRowguid], 
					[CategoryModifiedDate]
	FROM [INSERTED];

	INSERT INTO [Production].[ProductSubcategory] (
					[ProductCategoryID], 
					[Name], 
					[rowguid], 
					[ModifiedDate]
	)
	SELECT			[category].[ProductCategoryID], 
					[SubcategoryName], 
					[SubcategoryRowguid], 
					[SubcategoryModifiedDate]
	FROM [INSERTED]
	INNER JOIN [Production].[ProductCategory] [category] ON [category].[rowguid] = [INSERTED].[CategoryRowguid];
END;
GO

CREATE TRIGGER [Production].[vCategoryUpdate] ON [Production].[vProductCategoryWithSubcategory]
INSTEAD OF UPDATE AS
BEGIN
	UPDATE [Production].[ProductCategory]
	SET
		[Name]			= [INSERTED].[CategoryName],
		[rowguid]		= [INSERTED].[CategoryRowguid],
		[ModifiedDate]	= [INSERTED].[CategoryModifiedDate]
	FROM [INSERTED]
	WHERE [INSERTED].[ProductCategoryID] = [ProductCategory].[ProductCategoryID];

	UPDATE [Production].[ProductSubcategory]
	SET
		[Name]			= [INSERTED].[SubcategoryName],
		[rowguid]		= [INSERTED].[SubcategoryRowguid],
		[ModifiedDate]	= [INSERTED].[SubcategoryModifiedDate]
	FROM [INSERTED]
	WHERE [INSERTED].[ProductSubCategoryID] = [ProductSubcategory].[ProductSubcategoryID];
END;
GO

CREATE TRIGGER [Production].[vCategoryDelete] ON [Production].[vProductCategoryWithSubcategory]
INSTEAD OF DELETE AS
BEGIN
	DELETE [subcategory]
	FROM [Production].[ProductSubcategory] [subcategory]
	INNER JOIN [DELETED] ON [DELETED].[ProductSubcategoryID] =  [subcategory].[ProductSubcategoryID];

	DELETE [category]
	FROM [Production].[ProductCategory] [category]
	INNER JOIN [DELETED] ON [DELETED].[ProductCategoryID]	= [category].[ProductCategoryID];
END;
GO

INSERT INTO [Production].[vProductCategoryWithSubcategory] (
	[CategoryName],
	[CategoryRowguid],
	[CategoryModifiedDate],
	[SubcategoryName],
	[SubcategoryRowguid],
	[SubcategoryModifiedDate]
	)
VALUES ('test category', NEWID(), CURRENT_TIMESTAMP,'test subcategory', NEWID(), CURRENT_TIMESTAMP);

UPDATE [Production].[vProductCategoryWithSubcategory] 
SET
	[CategoryName]			= 'updated category',
	[SubCategoryRowguid]	= NEWID()
	WHERE [CategoryName]	= 'test category';

DELETE [Production].[vProductCategoryWithSubcategory]  
	WHERE [CategoryName]	= 'updated category';