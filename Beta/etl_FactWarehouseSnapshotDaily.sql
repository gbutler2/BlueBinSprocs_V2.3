IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'etl_FactWarehouseSnapshotDaily')
                    AND type IN ( N'P', N'PC' ) ) 

DROP PROCEDURE  etl_FactWarehouseSnapshotDaily
GO

CREATE PROCEDURE etl_FactWarehouseSnapshotDaily
AS
--exec etl_FactWarehouseSnapshotDaily  

/*********************		DROP FactWarehouseSnapshotDaily		***************************/

  BEGIN TRY
      drop table bluebin.FactWarehouseSnapshotDaily 
  END TRY

  BEGIN CATCH
  END CATCH

/******************		QUERY				****************************/
;
	
select 
	LOCATION,
	ITEM,
       SOH_QTY       AS SOHQty,
	   LAST_ISS_COST	AS UnitCost,
	   convert(DATE,getdate()) as CurrentDate
into ItemList# 
from ITEMLOC 
where 
	LOCATION in (Select ConfigValue from bluebin.Config where ConfigName = 'LOCATION')
	and SOH_QTY > 0 
	OR 
	LOCATION in (Select ConfigValue from bluebin.Config where ConfigName = 'LOCATION') and 
	ITEM in (select distinct ITEM from ICTRANS where TRANS_DATE > getdate() -90 and LOCATION in (Select ConfigValue from bluebin.Config where ConfigName = 'LOCATION'))

SELECT 
		Row_number()
             OVER(
               PARTITION BY a.ITEM
               ORDER BY a.TransDate DESC) as [Sequence],
		a.TransDate,
		a.ITEM,
		case when a.TransDate = convert(DATE,getdate()) then ItemList#.SOHQty else (ISNULL(b.QUANTITY,0)*-1) end as QUANTITY,
		(ISNULL(c.QUANTITY,0)*-1) as QUANTITYIN

    into TransList#
	FROM   
	(SELECT DISTINCT 
		convert(DATE,dd.Date) as TransDate,
		ItemList#.ITEM
		FROM   bluebin.DimDate dd,ItemList#) a

		LEFT JOIN--ICTRANS
			(select 
			LOCATION,
			ITEM,
			convert(DATE,TRANS_DATE) as TransDate,
			SUM((QUANTITY)) as QUANTITY 
			--into TransList#
			FROM   ICTRANS 
			where 
				LOCATION in (Select ConfigValue from bluebin.Config where ConfigName = 'LOCATION')
				and TRANS_DATE > getdate() -90
			group by LOCATION,ITEM,convert(DATE,TRANS_DATE)) b on a.ITEM = b.ITEM and a.TransDate = b.TransDate

		LEFT JOIN--POLINE
			(select 
			LOCATION,
			ITEM,
			convert(DATE,REC_ACT_DATE) as TransDate,
			SUM((REC_QTY*EBUY_UOM_MULT)) as QUANTITY 
			--Into TempC#
			FROM   POLINE 
			where 
				LOCATION in (Select ConfigValue from bluebin.Config where ConfigName = 'LOCATION')
				and CXL_QTY = 0 and REC_QTY > 0 and ITEM_TYPE = 'I'
				and REC_ACT_DATE > getdate() -90
			group by LOCATION,ITEM,convert(DATE,REC_ACT_DATE)) c on a.ITEM = c.ITEM and a.TransDate = c.TransDate
		left join ItemList# on a.TransDate = ItemList#.CurrentDate and a.ITEM = ItemList#.ITEM
		WHERE  a.TransDate <= Getdate() 


select 
ic.COMPANY AS FacilityKey,
df.FacilityName,
ic.LOCATION as LocationID,
TransList#.TransDate as SnapshotDate,
--TransList#.ITEM,
ic.LAST_ISS_COST  AS UnitCost,
SUM(TransList#.QUANTITY+TransList#.QUANTITYIN) OVER (PARTITION BY ic.LOCATION ORDER BY TransList#.[Sequence]) as SOH
--SUM(TransList#.QUANTITY+TransList#.QUANTITYIN) OVER (PARTITION BY TransList#.ITEM ORDER BY TransList#.[Sequence]) as SOH
--into bluebin.FactWarehouseSnapshotDaily
into TotalData#
from TransList# 
inner join ITEMLOC ic on TransList#.ITEM = ic.ITEM
inner join bluebin.DimFacility df on ic.COMPANY = df.FacilityID
where ic.LOCATION in (Select ConfigValue from bluebin.Config where ConfigName = 'LOCATION')


select 
FacilityKey,
FacilityName,
LocationID,
SnapshotDate,
SOH,
sum(UnitCost) as TotalCost
from TotalData#
group by
FacilityKey,
FacilityName,
LocationID,
SnapshotDate,
SOH
order by SnapshotDate,LocationID

drop table ItemList#
drop table TransList#
drop table TotalData#


GO

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'FactWarehouseSnapshotDaily'

GO