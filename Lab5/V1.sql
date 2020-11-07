USE AdventureWorks2012
GO
--a
-- =============================================
-- Author:		Larisa Pobol
-- Create date: 11/6/2020
-- Description:	returns number of departments included in group with name @groupName
-- =============================================
CREATE FUNCTION [dbo].[ufnGetDepartmentsNumberByGroupName]
(
	@GroupName		nvarchar(50)
)
RETURNS int
AS
BEGIN
	DECLARE @ret	int;
	SELECT  @ret	=  COUNT([DepartmentID]) FROM [HumanResources].[Department]
								WHERE [Department].[GroupName] = @GroupName;

	RETURN @ret;

END
GO

 SELECT [dbo].[ufnGetDepartmentsNumberByGroupName]('Sales and Marketing');
 GO

 --b
 -- =============================================
-- Author:		Larisa Pobol
-- Create date: 11/6/2020
-- Description:	returns three oldest employees who have started working in the department since 2005
-- =============================================
CREATE FUNCTION [dbo].[ufnGetThreeOldestEmployee]
(	
	@DepartmentID	int
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT TOP(3) [employee].* FROM [HumanResources].[Employee] [employee]
	INNER JOIN [HumanResources].[EmployeeDepartmentHistory] [history] 
		ON  [employee].[BusinessEntityID]	= [history].[BusinessEntityID]
	WHERE	[history].[DepartmentID]		= @DepartmentID 
		AND [history].[StartDate]	BETWEEN '2005' and '2006'
		AND [history].[EndDate]	IS NULL
	ORDER BY [employee].[BirthDate] ASC
)
GO

--c
SELECT * FROM [HumanResources].[Department] [department]
CROSS APPLY [dbo].[ufnGetThreeOldestEmployee]([department].[DepartmentID]);

--d
SELECT * FROM [HumanResources].[Department] [department]
OUTER APPLY [dbo].[ufnGetThreeOldestEmployee]([department].[DepartmentID]);

--e
DROP FUNCTION [dbo].[ufnGetThreeOldestEmployee];
GO

CREATE FUNCTION [dbo].[ufnGetThreeOldestEmployee]
(	
	@DepartmentID	int
)
RETURNS @ret TABLE (
	[BusinessEntityID]	[int] NOT NULL,
	[NationalIDNumber]	[nvarchar](15) NOT NULL,
	[LoginID]			[nvarchar](256) NOT NULL,
	[OrganizationNode]	[hierarchyid] NULL,
	[OrganizationLevel] [smallint] NULL,
	[JobTitle]			[nvarchar](50) NOT NULL,
	[BirthDate]			[date] NOT NULL,
	[MaritalStatus]		[nchar](1) NOT NULL,
	[Gender]			[nchar](1) NOT NULL,
	[HireDate]			[date] NOT NULL,
	[SalariedFlag]		[dbo].[Flag] NOT NULL,
	[VacationHours]		[smallint] NOT NULL,
	[SickLeaveHours]	[smallint] NOT NULL,
	[CurrentFlag]		[dbo].[Flag] NOT NULL,
	[rowguid]			[uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[ModifiedDate]		[datetime] NOT NULL
)
BEGIN
INSERT INTO @ret
	SELECT TOP(3) [employee].* FROM [HumanResources].[Employee] [employee]
	INNER JOIN [HumanResources].[EmployeeDepartmentHistory] [history] 
		ON  [employee].[BusinessEntityID]	= [history].[BusinessEntityID]
	WHERE	[history].[DepartmentID]		= @DepartmentID 
		AND [history].[StartDate]	BETWEEN '2005' and '2006'
		AND [history].[EndDate]	IS NULL
	ORDER BY [employee].[BirthDate] ASC
	RETURN
END;
GO

--f
SELECT * FROM [HumanResources].[Department] [department]
CROSS APPLY [dbo].[ufnGetThreeOldestEmployee]([department].[DepartmentID]);

SELECT * FROM [HumanResources].[Department] [department]
OUTER APPLY [dbo].[ufnGetThreeOldestEmployee]([department].[DepartmentID]);