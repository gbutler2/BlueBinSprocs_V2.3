IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'etl_DimLocation')
                    AND type IN ( N'P', N'PC' ) ) 

DROP PROCEDURE  etl_DimLocation
GO


CREATE PROCEDURE etl_DimLocation
AS

/********************		DROP DimLocation	***************************/
  BEGIN TRY
      DROP TABLE bluebin.DimLocation
  END TRY

  BEGIN CATCH
  END CATCH

/*********************		CREATE DimLocation	****************************/
SELECT DISTINCT
LocationMasterID AS LocationKey,
       [LocationID]               AS LocationID,
--       [LocationId]             AS LocationName,
       [LocationName]             AS LocationName,
       'Caldwell'                   AS LocationFacility,
       CASE
         WHEN LEFT([LocationID], 2) IN (SELECT [ConfigValue]
                                        FROM   [bluebin].[Config]
                                        WHERE  [ConfigName] = 'REQ_LOCATION'
                                               AND Active = 1) THEN 1
         ELSE 0
       END                        AS BlueBinFlag
INTO   bluebin.DimLocation
FROM   [bluebin].[BlueBinLocationMaster]
group by LocationMasterID,[LocationID],[LocationName]
GO

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'DimLocation'