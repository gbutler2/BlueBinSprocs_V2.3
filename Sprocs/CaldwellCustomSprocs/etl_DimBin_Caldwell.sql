
/****** Object:  StoredProcedure [dbo].[etl_DimBin]    Script Date: 2/3/2016 9:25:05 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'etl_DimBin')
                    AND type IN ( N'P', N'PC' ) ) 

DROP PROCEDURE  [dbo].[etl_DimBin]


GO
CREATE PROCEDURE [dbo].[etl_DimBin]

AS


/***************************		DROP DimBin		********************************/
BEGIN TRY
    DROP TABLE bluebin.DimBin
END TRY

BEGIN CATCH
END CATCH


/***************************		CREATE Temp Tables		*************************/


;

/***********************************		CREATE	DimBin		***********************************/

SELECT 

		ParMasterID AS BinKey,
			bbf.FacilityName AS BinFacility,
           rtrim(pm.ItemID) AS ItemID,
           rtrim(pm.LocationID)  AS LocationID,
           pm.BinSequence AS BinSequence,
		   	CASE WHEN pm.BinSequence LIKE '[A-Z][A-Z]%' THEN LEFT(pm.BinSequence, 2) ELSE LEFT(pm.BinSequence, 1) END as BinCart,
			CASE WHEN pm.BinSequence LIKE '[A-Z][A-Z]%' THEN SUBSTRING(pm.BinSequence, 3, 1) ELSE SUBSTRING(pm.BinSequence, 2,1) END as BinRow,
			CASE WHEN pm.BinSequence LIKE '[A-Z][A-Z]%' THEN SUBSTRING (pm.BinSequence,4,2) ELSE SUBSTRING(pm.BinSequence, 3,2) END as BinPosition,
           CASE
             WHEN pm.BinSequence LIKE 'CARD%' THEN 'WALL'
             ELSE RIGHT(pm.BinSequence, 3)
           END AS BinSize,
           pm.BinUOM  AS BinUOM,
           isnull(pm.BinQuantity,'0') AS BinQty,
		   pm.LeadTime AS BinLeadTime,
           '2015-12-01 00:00:00'   AS BinGoLiveDate,
           '' AS BinCurrentCost,
           '' AS BinConsignmentFlag,
           '' AS BinGLAccount,
		   'Awaiting Updated Status' AS BinCurrentStatus
    INTO   bluebin.DimBin
    FROM   [bluebin].[BlueBinParMaster] pm
		inner join bluebin.BlueBinFacility bbf on pm.FacilityID = bbf.FacilityID
/*****************************************		DROP Temp Tables	**************************************/




GO


