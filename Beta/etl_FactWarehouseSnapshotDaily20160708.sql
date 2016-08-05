IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'etl_FactWarehouseSnapshotDaily')
                    AND type IN ( N'P', N'PC' ) ) 

DROP PROCEDURE  etl_FactWarehouseSnapshotDaily
GO

CREATE PROCEDURE etl_FactWarehouseSnapshotDaily
AS
--exec etl_FactWarehouseSnapshotDaily  

/*********************		DROP FactWarehouseSnapshot		***************************/

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
	   convert(DATE,getdate()) as TransDate,ACTIVE_STATUS
into ItemList# 
from ITEMLOC 
where 
	LOCATION in (Select ConfigValue from bluebin.Config where ConfigName = 'LOCATION')
	and SOH_QTY > 0 and ACTIVE_STATUS = 'A'
	OR 
	LOCATION in (Select ConfigValue from bluebin.Config where ConfigName = 'LOCATION') and 
	ITEM in (select distinct ITEM from ICTRANS where TRANS_DATE > getdate() -30 and LOCATION in (Select ConfigValue from bluebin.Config where ConfigName = 'LOCATION'))
	 and ACTIVE_STATUS = 'A'
	--AND ITEM in ('0000013','0000018')
	

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
		Date AS TransDate,
		ITEM
		FROM   bluebin.DimDate,ItemList#
		where Date > getdate() -30) a
		LEFT JOIN
		(select 
			ITEM,
			convert(DATE, TRANS_DATE) as TransDate,
			SUM((QUANTITY)) as QUANTITY 
			FROM   ICTRANS 
			where 
				LOCATION in (Select ConfigValue from bluebin.Config where ConfigName = 'LOCATION')
				and TRANS_DATE > getdate() -30
			group by ITEM,
			convert(DATE, TRANS_DATE)) b on a.TransDate = b.TransDate and a.ITEM = b.ITEM 
		LEFT JOIN
		(select 
			ITEM,
			convert(DATE, REC_ACT_DATE) as TransDate,
			SUM((REC_QTY*EBUY_UOM_MULT)) as QUANTITY 
			FROM   POLINE 
			where 
				LOCATION in (Select ConfigValue from bluebin.Config where ConfigName = 'LOCATION')
				and REC_ACT_DATE > getdate() -30
				and CXL_QTY = 0 and REC_QTY > 0 and ITEM_TYPE = 'I'
			group by ITEM,
			convert(DATE, REC_ACT_DATE)) c on a.TransDate = c.TransDate and a.ITEM = c.ITEM 
		left join ItemList# on a.TransDate = ItemList#.TransDate and a.ITEM = ItemList#.ITEM
    WHERE  a.TransDate < Getdate() 

	

select 
ic.COMPANY AS FacilityKey,
df.FacilityName,
ic.LOCATION as LocationID,
TransList#.TransDate as SnapshotDate,
TransList#.ITEM,
SUM(TransList#.QUANTITY+TransList#.QUANTITYIN) OVER (PARTITION BY TransList#.ITEM ORDER BY TransList#.[Sequence]) as SOH,
ic.LAST_ISS_COST  AS UnitCost  
--,SUM(TransList#.QUANTITY+TransList#.QUANTITYIN) OVER (PARTITION BY TransList#.ITEM ORDER BY TransList#.[Sequence])*ic.LAST_ISS_COST as B
into TotalData#--into bluebin.FactWarehouseSnapshotDaily
from TransList# 
inner join ITEMLOC ic on TransList#.ITEM = ic.ITEM
inner join bluebin.DimFacility df on ic.COMPANY = df.FacilityID
where ic.LOCATION in (Select ConfigValue from bluebin.Config where ConfigName = 'LOCATION')


select 
FacilityKey,
FacilityName,
LocationID,
SnapshotDate,
sum(case when SOH > 0 then 1 else 0 end) as SOH,
sum(SOH*UnitCost) as TotalCost
 from TotalData#
group by 
FacilityKey,
FacilityName,
LocationID,
SnapshotDate
order by SnapshotDate,LocationID desc

select 
SnapshotDate,sum(SOH) from
(select LocationID,SnapshotDate,case when SOH > 0 then 1 else 0 end as SOH from TotalData# ) a
group by SnapshotDate
order by SnapshotDate

drop table ItemList#
drop table TransList#
drop table TotalData#

/*********************	END		******************************/

GO

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'FactWarehouseSnapshotDaily'

GO
