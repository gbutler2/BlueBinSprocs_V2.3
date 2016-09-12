

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'tb_Sourcing')
                    AND type IN ( N'P', N'PC' ) ) 

DROP PROCEDURE  tb_Sourcing
GO

CREATE PROCEDURE	tb_Sourcing
--exec tb_Sourcing  select count(*) from tableau.Sourcing where PODate >= (select ConfigValue from bluebin.Config where ConfigName = 'PO_DATE')
AS

/********************************		DROP Sourcing		**********************************/

BEGIN TRY
    DROP TABLE tableau.Sourcing
END TRY

BEGIN CATCH
END CATCH

/**********************************		CREATE Temp Tables		***************************/

-- #tmpPOLines

SELECT a.COMPANY,
       a.PO_NUMBER,
       a.PO_RELEASE,
       a.PO_CODE,
       a.LINE_NBR,
       a.ITEM,
       a.ITEM_TYPE,
       a.DESCRIPTION AS PO_DESCRIPTION,
       a.QUANTITY,
       a.REC_QTY,
       a.AGREEMENT_REF,
       a.ENT_UNIT_CST,
       a.ENT_BUY_UOM,
       a.EBUY_UOM_MULT,
       b.PO_DATE,
       a.EARLY_DL_DATE,
       a.LATE_DL_DATE,
       a.REC_ACT_DATE,
       a.CLOSE_DATE,
       a.LOCATION,
       a.BUYER_CODE,
       a.VENDOR,
       d.OPER_COMPANY,
	   d.REQ_LOCATION,
       a.VEN_ITEM,
       a.CLOSED_FL,
       a.CXL_QTY,
       c.INVOICE_AMT
INTO   #tmpPOLines
FROM   POLINE a
       INNER JOIN PURCHORDER b
              ON a.PO_NUMBER = b.PO_NUMBER
                 AND a.COMPANY = b.COMPANY
                 AND a.PO_CODE = b.PO_CODE
				 AND a.PO_RELEASE = b.PO_RELEASE
       LEFT JOIN (SELECT PO_NUMBER,
                         LINE_NBR,
                         Sum(TOT_DIST_AMT) AS INVOICE_AMT
                  FROM   MAINVDTL
                  GROUP  BY PO_NUMBER,
                            LINE_NBR) c
              ON a.PO_NUMBER = c.PO_NUMBER
                 AND a.LINE_NBR = c.LINE_NBR
       LEFT JOIN POLINESRC d
              ON a.COMPANY = d.COMPANY
                 AND a.PO_NUMBER = d.PO_NUMBER
                 AND a.LINE_NBR = d.LINE_NBR
                 AND a.PO_CODE = d.PO_CODE
				 AND a.PO_RELEASE = d.PO_RELEASE
WHERE  b.PO_DATE >= (select ConfigValue from bluebin.Config where ConfigName = 'PO_DATE') 
		--AND b.PO_RELEASE = 0
       AND a.CXL_QTY = 0
	   
	   --and a.PO_NUMBER like '%380479%'


--#tmpMMDIST
SELECT a.DOC_NUMBER    AS PO_NUMBER,
       a.LINE_NBR,
       a.ACCT_UNIT,
       b.DESCRIPTION AS ACCT_UNIT_NAME
INTO #tmpMMDIST
FROM   MMDIST a
inner join (select COMPANY,DOC_NUMBER,LINE_NBR,max(LINE_SEQ) as LINE_SEQ from MMDIST WHERE  SYSTEM_CD = 'PO' AND DOC_TYPE = 'PT' group by COMPANY,DOC_NUMBER,LINE_NBR) sq on a.COMPANY = sq.COMPANY and a.DOC_NUMBER = sq.DOC_NUMBER and a.LINE_NBR = sq.LINE_NBR and a.LINE_SEQ = sq.LINE_SEQ
       LEFT JOIN GLNAMES b
              ON a.COMPANY = b.COMPANY
                 AND a.ACCT_UNIT = b.ACCT_UNIT
WHERE  SYSTEM_CD = 'PO'
       AND DOC_TYPE = 'PT'
       AND a.DOC_NUMBER IN (SELECT PO_NUMBER
                          FROM   PURCHORDER
                          WHERE  PO_DATE >= (select ConfigValue from bluebin.Config where ConfigName = 'PO_DATE'))
						  --and a.DOC_NUMBER like '%380479%'
						  --and a.DOC_NUMBER like '%389266%' order by 2


--#tmpPOStatus
SELECT Row_number()
         OVER(
           ORDER BY a.PO_NUMBER, a.LINE_NBR) AS POKey,
       COMPANY                           AS Company,
       a.PO_NUMBER                         AS PONumber,
       a.LINE_NBR                          AS POLineNumber,
       PO_RELEASE                        AS PORelease,
       PO_CODE                           AS POCode,
       ITEM                              AS ItemNumber,
	   a.VENDOR                            AS VendorCode,
	   d.VENDOR_VNAME					AS VendorName,
       a.BUYER_CODE                        AS Buyer,
	   c.NAME							AS BuyerName,
       LOCATION                          AS ShipLocation,
       ACCT_UNIT                         AS AcctUnit,
       ACCT_UNIT_NAME                    AS AcctUnitName,
       PO_DESCRIPTION                    AS PODescr,
       QUANTITY                          AS QtyOrdered,
       REC_QTY                           AS QtyReceived,
       AGREEMENT_REF                     AS AgrmtRef,
       ENT_UNIT_CST                      AS UnitCost,
       ENT_BUY_UOM                       AS BuyUOM,
       EBUY_UOM_MULT                     AS BuyUOMMult,
	   ENT_UNIT_CST/EBUY_UOM_MULT		 AS IndividualCost,
       PO_DATE                           AS PODate,
       EARLY_DL_DATE                     AS ExpectedDeliveryDate,
       LATE_DL_DATE                      AS LateDeliveryDate,
       REC_ACT_DATE                      AS ReceivedDate,
       CLOSE_DATE                        AS CloseDate,
       REQ_LOCATION                      AS PurchaseLocation,
       OPER_COMPANY                      AS PurchaseFacility,
	   VEN_ITEM                          AS VendorItemNbr,
       CLOSED_FL                         AS ClosedFlag,
       CXL_QTY                           AS QtyCancelled,
       QUANTITY * ENT_UNIT_CST           AS POAmt,
       INVOICE_AMT                       AS InvoiceAmt,
       ITEM_TYPE                         AS POItemType,
       CASE
         WHEN ITEM_TYPE = 'S' THEN 0
         ELSE
           CASE
             WHEN REC_QTY = 0 THEN 0
             ELSE INVOICE_AMT - ( REC_QTY * ENT_UNIT_CST )
           END
       END                               AS PPV,
       1                                 AS POLine
INTO #tmpPOStatus
FROM   #tmpPOLines a
       LEFT JOIN #tmpMMDist b
              ON a.PO_NUMBER = b.PO_NUMBER
                 AND a.LINE_NBR = b.LINE_NBR 
		LEFT JOIN (select distinct BUYER_CODE,NAME from BUYER) c
		ON a.BUYER_CODE = c.BUYER_CODE
		LEFT JOIN APVENMAST d ON a.VENDOR = d.VENDOR


--#tmpPOs

SELECT *,
CASE WHEN ClosedFlag = 'Y' THEN 'Closed' ELSE
	CASE WHEN QtyReceived + QtyCancelled = QtyOrdered THEN 'Closed' ELSE 'Open' END
	END 																as POStatus,
CASE WHEN POItemType = 'S' THEN 'N/A' ELSE
	CASE WHEN Dateadd(day, 3, ExpectedDeliveryDate) <= GETDATE() AND (QtyReceived+QtyCancelled < QtyOrdered) THEN 'Late' ELSE
		CASE WHEN Dateadd(day, 3, ExpectedDeliveryDate) > GETDATE() THEN 'In-Progress' ELSE
			CASE WHEN ReceivedDate <= Dateadd(day, 3, ExpectedDeliveryDate) AND (QtyReceived + QtyCancelled) = QtyOrdered THEN 'On-Time' ELSE 'Late' END
		END	
	
	END

END as PODeliveryStatus
INTO #tmpPOs
FROM #tmpPOStatus


/*************************		CREATE Sourcing		****************************/

SELECT a.*,
       CASE
         WHEN a.PODeliveryStatus = 'In-Progress' THEN 1
         ELSE 0
       END AS InProgress,
       CASE
         WHEN a.PODeliveryStatus = 'On-Time' THEN 1
         ELSE 0
       END AS OnTime,
       CASE
         WHEN a.PODeliveryStatus = 'Late' THEN 1
         ELSE 0
       END AS Late,
	   case when dl.BlueBinFlag = 1 then 'Yes' else 'No' end as BlueBinFlag,
	   df.FacilityName

INTO   tableau.Sourcing 
FROM   #tmpPOs a
LEFT JOIN bluebin.DimLocation dl on ltrim(rtrim(a.PurchaseLocation)) = ltrim(rtrim(dl.LocationID)) and ltrim(rtrim(a.PurchaseFacility)) = ltrim(rtrim(dl.LocationFacility))
LEFT JOIN bluebin.DimFacility df on ltrim(rtrim(a.PurchaseFacility)) = ltrim(rtrim(df.FacilityID))
/***********************		DROP Temp Tables	**************************/

DROP TABLE #tmpPOLines
DROP TABLE #tmpMMDIST
DROP TABLE #tmpPOStatus
DROP TABLE #tmpPOs

GO

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'Sourcing'

GO
grant exec on tb_Sourcing to public
GO




