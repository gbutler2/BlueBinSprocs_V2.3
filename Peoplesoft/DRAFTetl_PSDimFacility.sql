
IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'etl_DimFacility')
                    AND type IN ( N'P', N'PC' ) ) 

DROP PROCEDURE  etl_DimFacility
GO

--drop table bluebin.DimFacility
--delete from bluebin.DimFacility
--select * from bluebin.DimFacility  
--exec etl_DimFacility
CREATE PROCEDURE etl_DimFacility
AS


/*********************		POPULATE/update DimFacility	****************************/
if not exists (select * from sys.tables where name = 'DimFacility')
BEGIN
CREATE TABLE [bluebin].[DimFacility](
	[FacilityID] INT NOT NULL ,
	[FacilityName] varchar (50) NOT NULL
)
;

INSERT INTO bluebin.DimFacility 
	SELECT distinct
	SETID as FacilityID,
	SETID as FacilityName

    FROM   dbo.LOCATION_TBL a
	left join bluebin.DimFacility df on a.SETID = df.FacilityID 
	where df.FacilityID is null
	
END 
;

INSERT INTO bluebin.DimFacility 
	SELECT distinct
	SETID as FacilityID,
	SETID as FacilityName

    FROM   dbo.LOCATION_TBL a
	left join bluebin.DimFacility df on a.SETID = df.FacilityID 
	where df.FacilityID is null
;
update bluebin.DimFacility set FacilityName = a.fn from
(select SETID as fi,SETID as fn from dbo.LOCATION_TBL) as a
where FacilityID = a.fi and FacilityName COLLATE DATABASE_DEFAULT <> a.fn
;

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'DimFacility'
GO