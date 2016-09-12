IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'etl_DimBin')
                    AND type IN ( N'P', N'PC' ) ) 

DROP PROCEDURE  etl_DimBin
GO

CREATE PROCEDURE etl_DimBin

AS

--exec etl_DimBin
/***************************		DROP DimBin		********************************/
BEGIN TRY
    DROP TABLE bluebin.DimBin
END TRY

BEGIN CATCH
END CATCH


--/***************************		CREATE Temp Tables		*************************/


/***********************************		CREATE	DimBin		***********************************/
SELECT Row_number()
         OVER(
           ORDER BY Bins.INV_CART_ID, Bins.INV_ITEM_ID) AS BinKey,
       --Bins.INV_CART_ID                                 AS CartID,
	   ''												as BinFacility,
       Bins.INV_ITEM_ID                                 AS ItemID,
       Locations.LOCATION                               AS LocationID,
       Bins.COMPARTMENT                                 AS BinSequence,
		   	CASE WHEN Bins.COMPARTMENT LIKE '[A-Z][A-Z]%' THEN LEFT(Bins.COMPARTMENT, 2) ELSE LEFT(Bins.COMPARTMENT, 1) END as BinCart,
			CASE WHEN Bins.COMPARTMENT LIKE '[A-Z][A-Z]%' THEN SUBSTRING(Bins.COMPARTMENT, 3, 1) ELSE SUBSTRING(Bins.COMPARTMENT, 2,1) END as BinRow,
			CASE WHEN Bins.COMPARTMENT LIKE '[A-Z][A-Z]%' THEN SUBSTRING (Bins.COMPARTMENT,4,2) ELSE SUBSTRING(Bins.COMPARTMENT, 3,2) END as BinPosition,
           CASE
             WHEN Bins.COMPARTMENT LIKE 'CARD%' THEN 'WALL'
             ELSE RIGHT(Bins.COMPARTMENT, 3)
           END                                           AS BinSize,
       Bins.UNIT_OF_MEASURE                             AS BinUOM,
       Cast(Bins.QTY_OPTIMAL AS INT)                    AS BinQty,
       (Select max(ConfigValue) from bluebin.Config where ConfigName = 'DefaultLeadTime')         AS BinLeadTime,
	   Locations.EFFDT									AS BinGoLiveDate,
	   '' AS BinCurrentCost,
       '' AS BinConsignmentFlag,
       '' AS BinGLAccount,
	   'Awaiting Updated Status'						 AS BinCurrentStatus


--INTO   bluebin.DimBin
FROM   dbo.CART_TEMPL_INV Bins
	   --INNER JOIN bluebin.DimLocation dl
    --               ON Bins.LOCATION COLLATE DATABASE_DEFAULT = dl.LocationID
				   --AND ITEMLOC.COMPANY = dl.LocationFacility
       LEFT JOIN dbo.CART_ATTRIB_INV Carts
              ON Bins.INV_CART_ID COLLATE DATABASE_DEFAULT = Carts.INV_CART_ID
       LEFT JOIN dbo.LOCATION_TBL Locations
              ON Carts.LOCATION COLLATE DATABASE_DEFAULT = Locations.LOCATION
	   INNER JOIN bluebin.DimLocation dl
              ON Locations.LOCATION COLLATE DATABASE_DEFAULT = dl.LocationID
WHERE  
		dl.BlueBinFlag = 1
		and
		(LEFT(Carts.LOCATION, 2) COLLATE DATABASE_DEFAULT IN (SELECT [ConfigValue] FROM   [bluebin].[Config] WHERE  [ConfigName] = 'REQ_LOCATION' AND Active = 1) 
		or Carts.LOCATION COLLATE DATABASE_DEFAULT in (Select REQ_LOCATION from bluebin.ALT_REQ_LOCATION))




/*****************************************		DROP Temp Tables	**************************************/


GO

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'DimBin'


