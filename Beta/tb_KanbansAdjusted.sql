if exists (select * from dbo.sysobjects where id = object_id(N'tb_KanbansAdjusted') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_KanbansAdjusted
GO

--exec tb_KanbansAdjusted

CREATE PROCEDURE [dbo].[tb_KanbansAdjusted] 
	
AS

BEGIN

with C as
(select 
[LastUpdated] 
,FacilityID
,LocationID
,ItemID
,BinQty as YestBinQty
--,OrderQty as YestOrderQty
--,OrderUOM as YestOrderUOM
from bluebin.DimBinHistory dbh
where LastUpdated >= getdate() -8 )--and LocationID = 'B6183' and ItemID = '700')
,
D as
(
select 
DATEPART(WEEK,a.[Date]) as [Week]
,a.[Date]
,C.[LastUpdated] as Yesterday
,a.FacilityID
,a.LocationID
,dl.LocationName
,a.ItemID
,di.ItemDescription
,convert(int,a.BinQty) as BinQty
,a.BinUOM
,convert(int,C.YestBinQty) as YestBinQty
--,C.YesBinUOM
,a.OrderQty
,isnull(a.OrderUOM,a.BinUOM) as OrderUOM
--,C.YestOrderQty
--,C.YestOrderUOM
,convert(int,a.BinQty) - convert(int,C.YestBinQty) as BinChange
,isnull(a.OrderQty,C.YestBinQty) - convert(int,C.YestBinQty) as BinOrderChange
,a.BinCurrentStatus

from tableau.Kanban a
left join C on a.FacilityID = C.FacilityID and a.LocationID = C.LocationID and a.ItemID = C.ItemID and convert(Date,a.[Date]) = convert(date,C.[LastUpdated])
inner join bluebin.DimLocation dl on a.LocationID = dl.LocationID
inner join bluebin.DimItem di on a.ItemID = di.ItemID
where a.[Date] >= getdate() -7


)

--select * from D  where LocationID = 'B6183' and ItemID = '700'


select 
[Week]
,[Date],Yesterday
,FacilityID
,LocationID
,LocationName
,ItemID
,ItemDescription
,BinQty
,YestBinQty
,BinUOM
,OrderQty
,OrderUOM
, case when BinChange != 0 then 1 else BinChange end as BinChange
, case when BinOrderChange != 0 then 1 else BinOrderChange end as BinOrderChange
,BinCurrentStatus 
from D 
where 
(BinOrderChange != 0 or BinChange != 0)
	and BinUOM = OrderUOM 	
			and [Date] >= getdate() -7
order by LocationName,ItemDescription,[Date]
END
GO
grant exec on tb_KanbansAdjusted to public
GO

--select * from ITEMLOC where ITEM = '700' and LOCATION = 'B6183'

--select * from bluebin.DimBin where ItemID= '700' and LocationID= 'B6183'
--select * from bluebin.BlueBinParMaster  where ItemID= '700' and LocationID= 'B6183'

--update bluebin.BlueBinParMaster set BinQuantity = BinQuantity -5 where ItemID= '700' and LocationID= 'B6183'

--select * from etl.JobSteps