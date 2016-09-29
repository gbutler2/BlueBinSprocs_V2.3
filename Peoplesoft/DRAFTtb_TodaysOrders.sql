USE [OSUMC]
GO

/****** Object:  StoredProcedure [dbo].[tb_TodaysOrders]    Script Date: 9/26/2016 1:16:02 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE	[dbo].[tb_TodaysOrders]
--exec tb_TodaysOrders  
AS

SET NOCOUNT on
;

DECLARE @EndDateConfig varchar(20), @TodayDate Datetime
	select @EndDateConfig = ConfigValue from bluebin.Config where ConfigName = 'ReportDateEnd'
	select @TodayDate = case when @EndDateConfig = 'Current' then getdate() -1 else convert(date,getdate()-1,112) end
;	

With list as 
(
			select distinct
			db.BinFacility as COMPANY,
			db.LocationID as REQ_LOCATION,
			dl.LocationName
			from bluebin.FactScan fs
			inner join bluebin.DimBin db on fs.BinKey = db.BinKey
			inner join bluebin.DimLocation dl on db.LocationID = dl.LocationID and dl.BlueBinFlag = 1
			where fs.OrderDate > getdate() -32
			)


select 
convert(datetime,(convert(DATE,getdate()-1)),112) as CREATION_DATE,
[list].COMPANY,
df.FacilityName as FacilityName,
[list].REQ_LOCATION,
[list].LocationName,
ISNULL([current].Lines,0) as TodayLines,
--ISNULL([past].Lines,0) as YestLines,
--CAST([past].Lines as decimal(6,2))/30,
--ROUND(CAST([past].Lines as decimal(6,2))/30,0),
CAST(ISNULL(ROUND(CAST([past].Lines as decimal(6,2))/30,0),0)as int) as YestLines,
case 
	when ISNULL([current].Lines,0) > CAST(ISNULL(ROUND(CAST([past].Lines as decimal(6,2))/30,0),0)as int) then 'UP' 
	when ISNULL([current].Lines,0) < CAST(ISNULL(ROUND(CAST([past].Lines as decimal(6,2))/30,0),0)as int) then 'DOWN'
	else 'EVEN' end as Trend

from 

list
inner join bluebin.DimFacility df on list.COMPANY = df.FacilityID		

left join(
			select
			db.BinFacility as COMPANY,
			db.LocationID as REQ_LOCATION,
			count(*) as Lines
			from bluebin.FactScan fs
			inner join bluebin.DimBin db on fs.BinKey = db.BinKey
			inner join bluebin.DimLocation dl on db.LocationID = dl.LocationID and dl.BlueBinFlag = 1
			where fs.OrderDate > getdate() -32 and fs.OrderDate < getdate() -2
			group by
			db.BinFacility,
			db.LocationID
			)
			[past] on list.COMPANY = past.COMPANY and list.REQ_LOCATION = past.REQ_LOCATION
			
--Todays Data
left join (

select
			db.BinFacility as COMPANY,
			db.LocationID as REQ_LOCATION,
			count(*) as Lines
			from bluebin.FactScan fs
			inner join bluebin.DimBin db on fs.BinKey = db.BinKey
			inner join bluebin.DimLocation dl on db.LocationID = dl.LocationID and dl.BlueBinFlag = 1
			where fs.OrderDate > @TodayDate
			group by
			db.BinFacility,
			db.LocationID

			) [current] on list.COMPANY = [current].COMPANY and list.REQ_LOCATION = [current].REQ_LOCATION
 
order by [list].REQ_LOCATION



GO


