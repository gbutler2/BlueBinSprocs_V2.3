if exists (select * from dbo.sysobjects where id = object_id(N'tb_KanbansAdjusted') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_KanbansAdjusted
GO

--exec tb_KanbansAdjusted

CREATE PROCEDURE [dbo].[tb_KanbansAdjusted] 
	
AS

BEGIN


select 
DATEPART(WEEK,a.[Date]) as [Week]
,a.[Date]
,a.[Date]-1 as Yesterday
,a.FacilityID
,df.FacilityName
,a.LocationID
,dl.LocationName
,a.ItemID
,di.ItemDescription
,convert(int,a.BinQty) as BinQty
,convert(int,dbh2.BinQty) as YestBinQty
,a.BinUOM
,a.OrderQty
,a.OrderUOM
,case when dbh2.BinQty is not null then 1 else 0 end as BinChange
,case when a.OrderQty is not null and a.OrderQty <> a.BinQty and a.OrderUOM = a.BinUOM then 1 else 0 end as BinOrderChange
,a.BinCurrentStatus

from tableau.Kanban a
inner join bluebin.DimFacility df on a.FacilityID = df.FacilityID
inner join bluebin.DimLocation dl on a.LocationID = dl.LocationID
inner join bluebin.DimItem di on a.ItemID = di.ItemID

left join 
	(select FacilityID, LocationID,ItemID,BinQty,LastUpdated from
		(select ROW_NUMBER() 
					OVER(Partition by d.FacilityID,d.LocationID,d.ItemID order by d.LastUpdated desc) as Num,
					d.FacilityID, d.LocationID,d.ItemID,d.BinQty,d.LastUpdated 
					from bluebin.DimBinHistory d 
						 inner join (select FacilityID, LocationID,ItemID,count(*) as Ct from bluebin.DimBinHistory group by FacilityID, LocationID,ItemID) changed on d.FacilityID = changed.FacilityID and d.LocationID = changed.LocationID and d.ItemID = changed.ItemID and changed.Ct > 1
						group by d.FacilityID, d.LocationID,d.ItemID,d.BinQty,d.LastUpdated) as a where Num = 1) dbh on a.FacilityID = dbh.FacilityID and a.LocationID = dbh.LocationID and a.ItemID = dbh.ItemID and convert(Date,a.[Date]+1) = convert(date,(dbh.[LastUpdated])) 
left join 
	(select FacilityID, LocationID,ItemID,BinQty from
		(select ROW_NUMBER() 
					OVER(Partition by d2.FacilityID,d2.LocationID,d2.ItemID order by d2.LastUpdated desc) as Num,
					d2.FacilityID, d2.LocationID,d2.ItemID,d2.BinQty,d2.LastUpdated 
					from bluebin.DimBinHistory d2
						 inner join (select FacilityID, LocationID,ItemID,count(*) as Ct from bluebin.DimBinHistory group by FacilityID, LocationID,ItemID) changed on d2.FacilityID = changed.FacilityID and d2.LocationID = changed.LocationID and d2.ItemID = changed.ItemID and changed.Ct > 1
						group by d2.FacilityID, d2.LocationID,d2.ItemID,d2.BinQty,d2.LastUpdated) as a where Num = 2) dbh2 on dbh.FacilityID = dbh2.FacilityID and dbh.LocationID = dbh2.LocationID and dbh.ItemID = dbh2.ItemID

where a.[Date] >= getdate() -7 and ((a.OrderQty<>a.BinQty and a.OrderQty is not null) or dbh2.BinQty is not null) and ScanHistseq > (select ConfigValue from bluebin.Config where ConfigName = 'ScanThreshold')
--and a.LocationID = 'B7435' and a.ItemID = '30003' 
order by FacilityID,LocationID,ItemID


END
GO
grant exec on tb_KanbansAdjusted to public
GO

--select * from ITEMLOC where ITEM = '700' and LOCATION = 'B6183'

--select * from bluebin.DimBin where ItemID= '0008733' and LocationID= 'BB009'
--select * from bluebin.BlueBinParMaster  where ItemID= '700' and LocationID= 'B6183'

--update bluebin.BlueBinParMaster set BinQuantity = BinQuantity -5 where ItemID= '700' and LocationID= 'B6183'

--select * from etl.JobSteps