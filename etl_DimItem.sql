
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

SELECT ITEM,max(ClinicalDescription) as ClinicalDescription
INTO   #ClinicalDescriptions
FROM
(
SELECT 
	a.ITEM,
	case 
		when b.ClinicalDescription is null or b.ClinicalDescription = ''  then
		case
			when a.USER_FIELD3 is null or a.USER_FIELD3 = ''  then
			case	
				when a.USER_FIELD1 is null or a.USER_FIELD1 = '' then '*NEEDS*' 
			else a.USER_FIELD1 end
		else a.USER_FIELD3 end
	else b.ClinicalDescription		
		end	as ClinicalDescription

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
       e.ClinicalDescription               AS ItemClinicalDescription,
       a.ACTIVE_STATUS                     AS ActiveStatus,
       a.MANUF_NBR                         AS ItemManufacturer, --b.DESCRIPTION
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
              ON ltrim(rtrim(a.ITEM)) = ltrim(rtrim(f.ITEM))
       LEFT JOIN #StockLocations g
              ON ltrim(rtrim(c.ITEM)) = ltrim(rtrim(g.ITEM)) 
       LEFT JOIN #ItemContract h
              ON ltrim(rtrim(a.ITEM)) = ltrim(rtrim(h.ITEM)) AND ltrim(rtrim(d.VENDOR)) = ltrim(rtrim(h.VENDOR))
order by a.ITEM



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


