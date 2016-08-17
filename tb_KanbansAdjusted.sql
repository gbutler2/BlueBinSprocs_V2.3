if exists (select * from dbo.sysobjects where id = object_id(N'tb_KanbansAdjusted') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_KanbansAdjusted
GO

--exec tb_KanbansAdjusted

CREATE PROCEDURE [dbo].[tb_KanbansAdjusted] 
	
AS

BEGIN
select max(Date) from tableau.Kanban

select 
DATEPART(WEEK,dbh.[Date]) as [Week]
,dbh.[Date]
--,dbh.[Date]-1 as Yesterday
,dbh.FacilityID
,df.FacilityName
,dbh.LocationID
,dl.LocationName
,dbh.ItemID
,di.ItemDescription
,dbh.BinQty as BinQty
,dbh.LastBinQty as YestBinQty
,dbh.BinUOM
,dbh.LastBinUOM as YestBinUOM
,dbh.Sequence
,dbh.LastSequence as YestSequence
,a.OrderQty
,a.OrderUOM
,case when (dbh.BinQty <> dbh.LastBinQty or dbh.Sequence <> dbh.LastSequence) and dbh.LastBinQty > 0 then 1 else 0 end as BinChange
,case when a.OrderQty is not null and a.OrderQty <> a.BinQty and a.OrderUOM = a.BinUOM then 1 else 0 end as BinOrderChange
,a.BinCurrentStatus

from bluebin.DimBinHistory dbh
inner join tableau.Kanban a on dbh.FacilityID = a.FacilityID and dbh.LocationID = a.LocationID and dbh.ItemID = a.ItemID and dbh.[Date] = a.[Date]
inner join bluebin.DimFacility df on a.FacilityID = df.FacilityID
inner join bluebin.DimLocation dl on a.LocationID = dl.LocationID
inner join bluebin.DimItem di on a.ItemID = di.ItemID


where dbh.[Date] >= getdate() -7 
--and a.LocationID = 'B7435' and a.ItemID = '30003' 
order by dbh.FacilityID,dbh.LocationID,dbh.ItemID


END
GO
grant exec on tb_KanbansAdjusted to public
GO
