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



/*********************		CREATE DimItem		**************************************/

SELECT ItemMasterID AS ItemKey,
       a.[ItemID]                        AS ItemID,
       a.[ItemDescription]                  AS ItemDescription,
	   a.[ItemDescription2] 						AS ItemDescription2,
       a.[ItemDescription]               AS ItemClinicalDescription,
       'A'                     AS ActiveStatus,
       ''                        AS ItemManufacturer,
       ''                         AS ItemManufacturerNumber,
       ''                      AS ItemVendor,
       ''                           AS ItemVendorNumber,
       ''                      AS LastPODate,
       ''                        AS StockLocation,
       ''                         AS VendorItemNumber,
	   ''						AS StockUOM,
       ''                              AS BuyUOM,
       '' AS PackageString

INTO   bluebin.DimItem
FROM   bluebin.BlueBinItemMaster a
	
order by a.ItemID
GO

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'DimItem'

