
--/******************************************

--			DimItem

--******************************************/

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'etl_DimItem')
                    AND type IN ( N'P', N'PC' ) ) 

DROP PROCEDURE  etl_DimItem
GO


CREATE PROCEDURE etl_DimItem

AS

/**************		SET BUSINESS RULES		***************/




/**************		DROP DimItem			***************/

BEGIN Try
    DROP TABLE bluebin.DimItem
END Try

BEGIN Catch
END Catch


/**************		CREATE Temp Tables			*******************/
Declare @UseClinicalDescription int
select @UseClinicalDescription = ConfigValue from bluebin.Config where ConfigName = 'UseClinicalDescription'       

SELECT ITEM,max(ClinicalDescription) as ClinicalDescription
INTO   #ClinicalDescriptions
FROM
(
SELECT 
	a.ITEM,
		case when @UseClinicalDescription = 1 then
		case 
			when b.ClinicalDescription is null or b.ClinicalDescription = ''  then
			case
				when a.USER_FIELD3 is null or a.USER_FIELD3 = ''  then
				case	
					when a.USER_FIELD1 is null or a.USER_FIELD1 = '' then 
					case 
						when c.DESCRIPTION is null or c.DESCRIPTION = '' then '*NEEDS*'
					else c.DESCRIPTION end
				else a.USER_FIELD1 end
			else a.USER_FIELD3 end
		else b.ClinicalDescription end	
	else c.DESCRIPTION
	end as ClinicalDescription

FROM 
(SELECT 
	ITEM,
	USER_FIELD1,
	USER_FIELD3
FROM ITEMLOC a 
INNER JOIN RQLOC b ON a.LOCATION = b.REQ_LOCATION 
WHERE LEFT(REQ_LOCATION, 2) IN (SELECT [ConfigValue] FROM   [bluebin].[Config] WHERE  [ConfigName] = 'REQ_LOCATION' AND Active = 1)) a
LEFT JOIN 
(SELECT 
	distinct ITEM, 
	USER_FIELD3 as ClinicalDescription
FROM ITEMLOC 
WHERE LOCATION IN (SELECT [ConfigValue] FROM [bluebin].[Config] WHERE  [ConfigName] = 'LOCATION' AND Active = 1) AND LEN(LTRIM(USER_FIELD3)) > 0
) b
ON ltrim(rtrim(a.ITEM)) = ltrim(rtrim(b.ITEM))
left join ITEMMAST c on ltrim(rtrim(a.ITEM)) = ltrim(rtrim(c.ITEM))
) a

Group by ITEM
	  

SELECT distinct ITEM,
       Max(PO_DATE) AS LAST_PO_DATE
INTO   #LastPO
FROM   POLINE a
       INNER JOIN PURCHORDER b
              ON a.PO_NUMBER = b.PO_NUMBER
                  AND a.COMPANY = b.COMPANY
                  AND a.PO_CODE = b.PO_CODE
--WHERE ITEM like '%30003%'			   
GROUP  BY ITEM

SELECT 
   il1.ITEM,
   STUFF((SELECT  ', '  + il2.PREFER_BIN + '(' + rtrim(il2.LOCATION) + ')'
          FROM ITEMLOC il2
          WHERE  il2.LOCATION in (Select ConfigValue from bluebin.Config where ConfigName = 'LOCATION')
		  and il2.PREFER_BIN <> '' and il2.ACTIVE_STATUS = 'A' and il2.ITEM = il1.ITEM 
		  order by il2.LOCATION
          FOR XML PATH('')), 1, 1, '') [PREFER_BIN]
INTO   #StockLocations
FROM ITEMLOC il1
WHERE il1.LOCATION in (Select ConfigValue from bluebin.Config where ConfigName = 'LOCATION') and il1.PREFER_BIN <> '' and il1.ACTIVE_STATUS = 'A'

GROUP BY il1.ITEM
ORDER BY 1

--**Old Stock Locations
--SELECT 
--Row_number()
--             OVER(
--               ORDER BY ITEM,LOCATION) as Num,
--	LOCATION,ITEM,
--       PREFER_BIN
--INTO   #StockLocations
--FROM   ITEMLOC
--WHERE  LOCATION in (Select ConfigValue from bluebin.Config where ConfigName = 'LOCATION') 
--and ACTIVE_STATUS = 'A' and ITEM in  ('61830','12296') and PREFER_BIN <> ''


SELECT distinct  a.ITEM,
       a.VENDOR,
       a.VEN_ITEM,
       a.UOM,
       a.UOM_MULT
INTO #ItemContract
FROM   POVAGRMTLN a
       INNER JOIN (SELECT ITEM,
						  MAX(LINE_NBR)		AS LINE_NBR,
                          Max(EFFECTIVE_DT) AS EFFECTIVE_DT,
                          Max(EXPIRE_DT)    AS EXPIRE_DT
                   FROM   POVAGRMTLN
                   WHERE  HOLD_FLAG = 'N'
                   GROUP  BY ITEM) b
               ON a.ITEM = b.ITEM
                  AND a.EFFECTIVE_DT = b.EFFECTIVE_DT
                  AND a.EXPIRE_DT = b.EXPIRE_DT
				  AND a.LINE_NBR = b.LINE_NBR
WHERE  a.HOLD_FLAG = 'N'  


select distinct a.ITEM,a.VENDOR
into #ItemVendor
from ITEMSRC a
where a.REPLENISH_PRI = 1
        AND a.LOCATION in (Select ConfigValue from bluebin.Config where ConfigName = 'LOCATION')
		and a.REPL_FROM_LOC = '' 


/*********************		CREATE DimItem		**************************************/


SELECT Row_number()
         OVER(
           ORDER BY a.ITEM)                AS ItemKey,
       a.ITEM                              AS ItemID,
       a.DESCRIPTION                       AS ItemDescription,
	   a.DESCRIPTION2					   AS ItemDescription2,
       case 
		when @UseClinicalDescription = 1 
		then 
			case 
				when e.ClinicalDescription is null 
				then rtrim(a.DESCRIPTION) 
				else e.ClinicalDescription end
		else rtrim(a.DESCRIPTION) end             AS ItemClinicalDescription,
       a.ACTIVE_STATUS                     AS ActiveStatus,
       icm.DESCRIPTION                     AS ItemManufacturer, --b.DESCRIPTION
	   --a.MANUF_NBR                         AS ItemManufacturer, --b.DESCRIPTION
       a.MANUF_NBR                         AS ItemManufacturerNumber,
       d.VENDOR_VNAME                      AS ItemVendor,
       c.VENDOR                            AS ItemVendorNumber,
       f.LAST_PO_DATE                      AS LastPODate,
       ltrim(g.PREFER_BIN)                       AS StockLocation,
       h.VEN_ITEM                          AS VendorItemNumber,
	   a.STOCK_UOM							AS StockUOM,
       h.UOM                               AS BuyUOM,
       CONVERT(VARCHAR, Cast(h.UOM_MULT AS INT))
       + ' EA' + '/'+Ltrim(Rtrim(h.UOM)) AS PackageString
INTO   bluebin.DimItem
FROM   ITEMMAST a 
     --  LEFT JOIN ITEMSRC c 
     --         ON ltrim(rtrim(a.ITEM)) = ltrim(rtrim(c.ITEM))
     --            AND c.REPLENISH_PRI = 1
     --            AND c.LOCATION in (Select ConfigValue from bluebin.Config where ConfigName = 'LOCATION')
				 --and c.REPL_FROM_LOC = ''
	   LEFT JOIN #ItemVendor c on ltrim(rtrim(a.ITEM)) = ltrim(rtrim(c.ITEM))
       LEFT JOIN (select distinct VENDOR_GROUP,VENDOR,VENDOR_VNAME from APVENMAST) d 
              ON ltrim(rtrim(c.VENDOR)) = ltrim(rtrim(d.VENDOR))
       LEFT JOIN #ClinicalDescriptions e
              ON ltrim(rtrim(a.ITEM)) = ltrim(rtrim(e.ITEM))
       LEFT JOIN #LastPO f
              ON rtrim(a.ITEM) = rtrim(f.ITEM)
       LEFT JOIN #StockLocations g
              ON ltrim(rtrim(c.ITEM)) = ltrim(rtrim(g.ITEM)) 
       LEFT JOIN #ItemContract h
              ON ltrim(rtrim(a.ITEM)) = ltrim(rtrim(h.ITEM)) AND ltrim(rtrim(d.VENDOR)) = ltrim(rtrim(h.VENDOR))
		LEFT JOIN 
			(select MANUF_CODE,max(DESCRIPTION) as [DESCRIPTION] from ICMANFCODE group by MANUF_CODE) icm
              ON a.MANUF_CODE = icm.MANUF_CODE
--where a.ITEM = '30003'
order by a.ITEM

--select * from bluebin.DimItem where ItemClinicalDescription is not null

/*********************		DROP Temp Tables	*********************************/


DROP TABLE #ClinicalDescriptions

DROP TABLE #LastPO

DROP TABLE #StockLocations

DROP TABLE #ItemContract

DROP TABLE #ItemVendor

GO

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'DimItem'
GO


if exists (select * from dbo.sysobjects where id = object_id(N'tb_ItemLocator') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_ItemLocator
GO

--exec tb_ItemLocator

CREATE PROCEDURE tb_ItemLocator

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
Declare @UseClinicalDescription int
select @UseClinicalDescription = ConfigValue from bluebin.Config where ConfigName = 'UseClinicalDescription'         
	
SELECT 
	a.COMPANY,
	df.FacilityName,
	a.ITEM as LawsonItemNumber,
	ISNULL(c.MANUF_NBR,'N/A') as ItemManufacturerNumber,
	case when @UseClinicalDescription = 1 then
		case 
			when b.ClinicalDescription is null or b.ClinicalDescription = ''  then
			case
				when a.USER_FIELD3 is null or a.USER_FIELD3 = ''  then
				case	
					when a.USER_FIELD1 is null or a.USER_FIELD1 = '' then 
					case 
						when c.DESCRIPTION is null or c.DESCRIPTION = '' then '*NEEDS*'
					else c.DESCRIPTION end 
				else a.USER_FIELD1 end
			else a.USER_FIELD3 end
		else b.ClinicalDescription end	
	else c.DESCRIPTION
	end as ClinicalDescription,
	a.LOCATION as LocationCode,
	a.NAME as LocationName,
	a.Cart,
	a.Row,
	a.Position
FROM 
(SELECT 
	a.COMPANY,
	ITEM,
	LOCATION,
	b.NAME,
	USER_FIELD1,
	USER_FIELD3,
	CASE WHEN ISNUMERIC(left(PREFER_BIN,1))=1 then LEFT(PREFER_BIN,2) 
		else CASE WHEN PREFER_BIN LIKE '[A-Z][A-Z]%' THEN LEFT(PREFER_BIN, 2) ELSE LEFT(PREFER_BIN, 1) END END as Cart,
	CASE WHEN ISNUMERIC(left(PREFER_BIN,1))=1 then SUBSTRING(PREFER_BIN, 3, 1) 
		else CASE WHEN PREFER_BIN LIKE '[A-Z][A-Z]%' THEN SUBSTRING(PREFER_BIN, 3, 1) ELSE SUBSTRING(PREFER_BIN, 2,1) END END as Row,
	CASE WHEN ISNUMERIC(left(PREFER_BIN,1))=1 then SUBSTRING(PREFER_BIN, 4, 2)
		else CASE WHEN PREFER_BIN LIKE '[A-Z][A-Z]%' THEN SUBSTRING (PREFER_BIN,4,2) ELSE SUBSTRING(PREFER_BIN, 3,2) END END as Position	
FROM ITEMLOC a 
INNER JOIN RQLOC b ON a.LOCATION = b.REQ_LOCATION and a.COMPANY = b.COMPANY
WHERE LEFT(REQ_LOCATION, 2) IN (SELECT [ConfigValue] FROM   [bluebin].[Config] WHERE  [ConfigName] = 'REQ_LOCATION' AND Active = 1)) a
LEFT JOIN 
(SELECT 
	ITEM, 
	max(USER_FIELD3) as ClinicalDescription
FROM ITEMLOC 
WHERE LOCATION IN (SELECT [ConfigValue] FROM [bluebin].[Config] WHERE  [ConfigName] = 'LOCATION' AND Active = 1) AND LEN(LTRIM(USER_FIELD3) ) > 0 group by ITEM
) b
ON a.ITEM = b.ITEM

left join ITEMMAST c on a.ITEM = c.ITEM
left join bluebin.DimFacility df on a.COMPANY = df.FacilityID



END
GO
grant exec on tb_ItemLocator to public
GO


IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'etl_FactWarehouseSnapshot')
                    AND type IN ( N'P', N'PC' ) ) 

DROP PROCEDURE  etl_FactWarehouseSnapshot
GO

CREATE PROCEDURE etl_FactWarehouseSnapshot
AS
--exec etl_FactWarehouseSnapshot  

/*********************		DROP FactWarehouseSnapshot		***************************/

  BEGIN TRY
      drop table bluebin.FactWarehouseSnapshot 
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
	   convert(DATE,getdate()) as MonthEnd
into TempA# 
from ITEMLOC 
where 
	LOCATION in (Select ConfigValue from bluebin.Config where ConfigName = 'LOCATION')
	and SOH_QTY > 0 
	OR 
	LOCATION in (Select ConfigValue from bluebin.Config where ConfigName = 'LOCATION') and 
	ITEM in (select distinct ITEM from ICTRANS where LOCATION in (Select ConfigValue from bluebin.Config where ConfigName = 'LOCATION'))
	--AND ITEM in ('0000013','0000018')


    SELECT 
		Row_number()
             OVER(
               PARTITION BY a.ITEM
               ORDER BY a.MonthEnd DESC) as [Sequence],
		a.MonthEnd,
		a.ITEM,
		case when a.MonthEnd = convert(DATE,getdate()) then TempA#.SOHQty else (ISNULL(b.QUANTITY,0)*-1) end as QUANTITY,
		(ISNULL(c.QUANTITY,0)*-1) as QUANTITYIN

    into TempB#
	FROM   
	(SELECT DISTINCT 
		case when left(Date,11) = left(getdate(),11) then Date else Eomonth(Date) end AS MonthEnd,
		ITEM
		FROM   bluebin.DimDate,TempA#) a
		LEFT JOIN
		(select 
			ITEM,
			EOMONTH(DATEADD(MONTH, -1, case when TRANS_DATE < '1900-01-01' then '1900-02-01' else TRANS_DATE end)) as MonthEnd,
			SUM((QUANTITY)) as QUANTITY 
			FROM   ICTRANS 
			where 
				LOCATION in (Select ConfigValue from bluebin.Config where ConfigName = 'LOCATION')
			group by ITEM,
			EOMONTH(DATEADD(MONTH, -1, case when TRANS_DATE < '1900-01-01' then '1900-02-01' else TRANS_DATE end))) b on a.MonthEnd = b.MonthEnd and a.ITEM = b.ITEM 
		LEFT JOIN
		(select 
			ITEM,
			EOMONTH(DATEADD(MONTH, -1, REC_ACT_DATE)) as MonthEnd,
			SUM((REC_QTY*EBUY_UOM_MULT)) as QUANTITY 
			FROM   POLINE 
			where 
				LOCATION in (Select ConfigValue from bluebin.Config where ConfigName = 'LOCATION')
				and CXL_QTY = 0 and REC_QTY > 0 and ITEM_TYPE = 'I'
			group by ITEM,
			EOMONTH(DATEADD(MONTH, -1, REC_ACT_DATE))) c on a.MonthEnd = c.MonthEnd and a.ITEM = c.ITEM 
		left join TempA# on a.MonthEnd = TempA#.MonthEnd and a.ITEM = TempA#.ITEM
    WHERE  a.MonthEnd <= Getdate() 



select 
ic.COMPANY AS FacilityKey,
df.FacilityName,
ic.LOCATION as LocationID,
TempB#.MonthEnd as SnapshotDate,
TempB#.ITEM,
SUM(TempB#.QUANTITY+TempB#.QUANTITYIN) OVER (PARTITION BY TempB#.ITEM ORDER BY TempB#.[Sequence]) as SOH,
ic.LAST_ISS_COST  AS UnitCost  
--,SUM(TempB#.QUANTITY+TempB#.QUANTITYIN) OVER (PARTITION BY TempB#.ITEM ORDER BY TempB#.[Sequence])*ic.LAST_ISS_COST as B
into bluebin.FactWarehouseSnapshot
from TempB# 
inner join ITEMLOC ic on TempB#.ITEM = ic.ITEM
inner join bluebin.DimFacility df on ic.COMPANY = df.FacilityID
where ic.LOCATION in (Select ConfigValue from bluebin.Config where ConfigName = 'LOCATION')

drop table TempA#
drop table TempB#

/*********************	END		******************************/

GO

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'FactWarehouseSnapshot'

GO


















declare @version varchar(50) = '2.3.20160701' --Update Version Number here


if not exists (select * from bluebin.Config where ConfigName = 'Version')
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,ConfigType,Active,LastUpdated) VALUES ('Version',@version,'DMS',1,getdate())
END
ELSE
Update bluebin.Config set ConfigValue = @version where ConfigName = 'Version'

Print 'Version Updated to ' + @version
Print 'DB: ' + DB_NAME() + ' updated'
GO