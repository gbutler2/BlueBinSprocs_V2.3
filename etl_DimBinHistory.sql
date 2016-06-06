if exists (select * from dbo.sysobjects where id = object_id(N'etl_DimBinHistory') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure etl_DimBinHistory
GO

--exec etl_DimBinHistory

CREATE PROCEDURE [dbo].[etl_DimBinHistory] 
	
AS


/*
select * from bluebin.DimBinHistory where LocationID = 'B6183' and ItemID = '700'
select * from bluebin.DimBin where LocationID = 'B6183' and ItemID = '700'  
select * from tableau.Kanban where LocationID = 'B6183' and ItemID = '700' and convert(Date,[Date]) = convert(Date,getdate()-1)
update bluebin.DimBinHistory set LastUpdated = getdate() -3 where DimBinHistoryID = 6161
*/
update bluebin.DimBinHistory set BinQty = a.Q
from (
		select 
			db.FacilityID as fid,
			db.LocationID as lid,
			db.ItemID as iid,
			convert(int,dbh.BinQty) as Q,
			convert(Date,getdate()) as lu
			--into #BinChange
			from (
					select Row_number()
						OVER(Partition BY FacilityID,LocationID,ItemID
							ORDER BY LastUpdated desc) as Num,
						FacilityID,
						LocationID,
						ItemID,
						BinQty,
						LastUpdated
					from
					bluebin.DimBinHistory) db
			inner join bluebin.DimBin dbh on db.FacilityID = dbh.BinFacility and db.LocationID = dbh.LocationID and db.ItemID = dbh.ItemID and db.BinQty <> dbh.BinQty and db.Num = 1
		) as a
where FacilityID = a.fid and LocationID = a.lid and ItemID = a.iid and LastUpdated = a.lu and BinQty <> a.Q


insert into bluebin.DimBinHistory
select 
db.FacilityID,
db.LocationID,
db.ItemID,
convert(int,dbh.BinQty) as BinQty,
getdate()
--into #BinChange
from (
		select Row_number()
            OVER(Partition BY FacilityID,LocationID,ItemID
				ORDER BY LastUpdated desc) as Num,
			FacilityID,
			LocationID,
			ItemID,
			BinQty,
			LastUpdated
		from
		bluebin.DimBinHistory) db
inner join bluebin.DimBin dbh on db.FacilityID = dbh.BinFacility and db.LocationID = dbh.LocationID and db.ItemID = dbh.ItemID and db.BinQty <> dbh.BinQty and db.Num = 1

GO
UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'DimBinHistory'

GO
grant exec on etl_DimBinHistory to public
GO