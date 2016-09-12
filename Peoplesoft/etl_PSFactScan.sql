IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'etl_FactScan')
                    AND type IN ( N'P', N'PC' ) ) 

DROP PROCEDURE  etl_FactScan
GO

CREATE PROCEDURE etl_FactScan

AS

/*****************************		DROP FactScan		*******************************/

BEGIN Try
    DROP TABLE bluebin.FactScan
END Try

BEGIN Catch
END Catch

--/********************************		CREATE Temp Tables			******************************/

SELECT 
ROW_NUMBER()OVER(PARTITION BY BinKey, CART_CT.CART_REPLEN_OPT ORDER BY CART_CT.CART_REPLEN_OPT, CASE
                     WHEN Datediff(HOUR, CART_CT.DEMAND_DATE, CART_CT.LAST_DTTM_UPDATE) < 24 THEN CART_CT.LAST_DTTM_UPDATE
                     ELSE DEMAND_DATE
                   END) as OrderSeq,
	  Bins.BinKey,
       Bins.BinGoLiveDate,
	   CART.LOCATION as LocationID,
       CART_CT.INV_ITEM_ID as ItemID,
       OrderDate = CASE
                     WHEN Datediff(HOUR, CART_CT.DEMAND_DATE, CART_CT.LAST_DTTM_UPDATE) < 24 THEN CART_CT.LAST_DTTM_UPDATE
                     ELSE DEMAND_DATE
                   END,
       CART_CT.CART_COUNT_QTY as OrderQty,
       CART_CT.CART_COUNT_ID as CartCountNum,
       CART_CT.CART_COUNT_STATUS as CartCountStatus,
       CART_CT.CART_REPLEN_OPT as OrderTypeID,
       OrderType = CASE
                     WHEN CART_CT.CART_REPLEN_OPT = '01' THEN 'MSR'
                     WHEN CART_CT.CART_REPLEN_OPT = '02' THEN 'PO'
                     WHEN CART_CT.CART_REPLEN_OPT = '03' THEN 'RQ'
                     WHEN CART_CT.CART_REPLEN_OPT = '04' THEN 'NR'
                     ELSE NULL
                   END
INTO #CartCounts
FROM   dbo.CART_CT_INF_INV CART_CT
       INNER JOIN dbo.CART_ATTRIB_INV CART
              ON CART_CT.INV_CART_ID = CART.INV_CART_ID
       INNER JOIN dbo.LOCATION_TBL LOCATION
              ON CART.LOCATION = LOCATION.LOCATION
       INNER JOIN bluebin.DimBin Bins
              ON CART.LOCATION = Bins.LocationID
                 AND CART_CT.INV_ITEM_ID = Bins.ItemID
WHERE  (LEFT(CART.LOCATION, 2) IN (SELECT [ConfigValue] FROM   [bluebin].[Config] WHERE  [ConfigName] = 'REQ_LOCATION' AND Active = 1) 
		or CART.LOCATION in (Select REQ_LOCATION from bluebin.ALT_REQ_LOCATION))
       AND CART_CT.CART_COUNT_QTY <> 0
ORDER  BY 2,1



--#PickLines
SELECT Bins.BinKey,
       INV_ITEM_ID as ItemID,
       LOCATION as LocationID,
       Picks.ORDER_NO as OrderNum,
       Picks.ORDER_INT_LINE_NO as LineNum,
       Picks.DEMAND_DATE as OrderDate,
       Picks.PICK_CONFIRM_DTTM as CloseDate,
       Cast(Picks.QTY_PICKED AS INT) AS OrderQty,
	   UNIT_OF_MEASURE as OrderUOM
INTO #PickLines
FROM   dbo.IN_DEMAND Picks
       INNER JOIN bluebin.DimBin Bins
               ON Picks.LOCATION = Bins.LocationID
                  AND Picks.INV_ITEM_ID = Bins.ItemID
WHERE  (LEFT(LOCATION, 2) IN (SELECT [ConfigValue] FROM   [bluebin].[Config] WHERE  [ConfigName] = 'REQ_LOCATION' AND Active = 1) 
		or LOCATION in (Select REQ_LOCATION from bluebin.ALT_REQ_LOCATION))
       AND CANCEL_DTTM IS NULL
       AND PICK_BATCH_ID <> 0
       AND IN_FULFILL_STATE = 70
ORDER  BY BinKey,
          Picks.DEMAND_DATE 

		  
--#POLines
SELECT Bins.BinKey,
       PO_LN.INV_ITEM_ID   AS ItemID,
       LOCATION            AS LocationID,
       PO_LN.PO_ID         AS OrderNum,
       PO_LN.LINE_NBR      AS LineNum,
       PO_DT               AS OrderDate,
       RECEIPT_DTTM        AS CloseDate,
	   QTY_PO              AS OrderQty,
	   PO_LN.UNIT_OF_MEASURE as OrderUOM
INTO #POLines
FROM   dbo.PO_LINE_DISTRIB PO_LN_DST
       INNER JOIN dbo.PO_LINE PO_LN
               ON PO_LN_DST.PO_ID = PO_LN.PO_ID
                  AND PO_LN_DST.LINE_NBR = PO_LN.LINE_NBR
       INNER JOIN dbo.PO_HDR
               ON PO_LN.PO_ID = PO_HDR.PO_ID
       INNER JOIN bluebin.DimBin Bins
               ON PO_LN.INV_ITEM_ID = Bins.ItemID
                  AND Bins.LocationID = PO_LN_DST.LOCATION
       LEFT JOIN dbo.RECV_LN_SHIP SHIP
              ON PO_LN.PO_ID = SHIP.PO_ID
                 AND PO_LN.LINE_NBR = SHIP.LINE_NBR
WHERE  (LEFT(LOCATION, 2) IN (SELECT [ConfigValue] FROM   [bluebin].[Config] WHERE  [ConfigName] = 'REQ_LOCATION' AND Active = 1) 
		or LOCATION in (Select REQ_LOCATION from bluebin.ALT_REQ_LOCATION))
ORDER  BY Bins.BinKey 


--#Orders
SELECT 
Row_number()
                  OVER(
                    Partition BY BinKey, OrderType
                    ORDER BY OrderType, OrderDate) AS OrderSeq,
*
INTO #Orders
FROM   
(SELECT *,
                'PO'                    AS OrderType
         FROM   #POLines
         UNION ALL
         SELECT *,
                'MSR'                   AS OrderType
         FROM   #PickLines) a 



--#TmpScan
SELECT Row_number()
                  OVER(
                    Partition BY c.BinKey
                    ORDER BY c.OrderDate DESC) AS Scanseq,
					Row_number()
                  OVER(
                    Partition BY c.BinKey
                    ORDER BY c.OrderDate ASC) AS ScanHistseq,
                c.BinKey,
                c.BinGoLiveDate,
				c.LocationID,
                c.ItemID,
                c.OrderTypeID,
                c.OrderType,
                c.CartCountNum,
                o.OrderNum,
                o.LineNum,
				o.OrderUOM,
                o.OrderQty,
                c.OrderDate,
                o.CloseDate
         into #tmpScans
		 FROM   #CartCounts c
                LEFT JOIN #Orders o
                       ON c.BinKey = o.BinKey
                          AND c.OrderSeq = o.OrderSeq
                          AND c.OrderType = o.OrderType
				WHERE OrderNum IS NOT NULL


/***********************************		CREATE FactScan		****************************************/

SELECT 
a.Scanseq,
a.ScanHistseq,
	   a.BinKey,
       c.LocationKey,
       d.ItemKey,
       a.BinGoLiveDate,
	   a.OrderNum,
       a.LineNum,
	   --a.OrderTypeID,
       a.OrderType as ItemType,
	   a.OrderUOM,
	   --a.CartCountNum,
       Cast(a.OrderQty AS INT) AS OrderQty,
       a.OrderDate,
       a.CloseDate as OrderCloseDate,
       b.OrderDate             AS PrevOrderDate,
       b.CloseDate             AS PrevOrderCloseDate,
	   1 as Scan,
       CASE
         WHEN Datediff(Day, b.OrderDate, a.OrderDate) < 3 THEN 1
         ELSE 0
       END                     AS HotScan,
       CASE
         WHEN a.OrderDate < COALESCE(b.CloseDate, GETDATE())
              AND a.ScanHistSeq > 2 THEN 1
         ELSE 0
       END                     AS StockOut
INTO FactScan
FROM   #tmpScans a
       LEFT JOIN #tmpScans b
              ON a.BinKey = b.BinKey
                 AND a.Scanseq = b.Scanseq - 1
       LEFT JOIN bluebin.DimLocation c
              ON a.LocationID = c.LocationID
       LEFT JOIN bluebin.DimItem d
              ON a.ItemID = d.ItemID
WHERE  a.OrderDate >= c.GoLiveDate 

/*****************************************		DROP Temp Tables		*******************************/

DROP TABLE #PickLines
DROP TABLE #POLines
DROP TABLE #CartCounts
DROP TABLE #Orders
DROP TABLE #tmpScans



GO

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'FactScan'
