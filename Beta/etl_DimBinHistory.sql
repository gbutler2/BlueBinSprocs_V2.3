if exists (select * from dbo.sysobjects where id = object_id(N'etl_DimBinHistory') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure etl_DimBinHistory
GO

--exec etl_DimBinHistory

CREATE PROCEDURE [dbo].[etl_DimBinHistory] 
	
AS

BEGIN

if not exists (select * from bluebin.DimBinHistory where LastUpdated = convert(date,getdate()))
BEGIN
insert into bluebin.DimBinHistory 
select BinFacility,LocationID,ItemID,BinQty,getdate() from bluebin.DimBin
END
ELSE	
	BEGIN
	update bluebin.DimBinHistory set BinQty = a.Q, LastUpdated = getdate()
		from (select BinFacility as bf,LocationID as lid,ItemID as iid,BinQty as Q from bluebin.DimBin) as a
	where FacilityID = a.bf and LocationID = a.lid and ItemID = a.iid and LastUpdated = convert(date,getdate()) and BinQty <> a.Q
	END
END


GO
grant exec on etl_DimBinHistory to public
GO