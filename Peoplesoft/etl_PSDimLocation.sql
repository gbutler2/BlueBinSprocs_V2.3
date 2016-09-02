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
   SELECT Row_number()
         OVER(
           ORDER BY a.LOCATION) AS LocationKey,
       a.LOCATION            AS LocationID,
       UPPER(DESCR)          AS LocationName,
	   df.FacilityID		 AS LocationFacility,
		CASE
             WHEN a.EFF_STATUS = 'A' and (
											LEFT(a.LOCATION, 2) COLLATE DATABASE_DEFAULT IN (SELECT [ConfigValue] 
                                            FROM   [bluebin].[Config]
                                            WHERE  [ConfigName] = 'REQ_LOCATION'
                                                   AND Active = 1) 
										or a.LOCATION COLLATE DATABASE_DEFAULT in (Select REQ_LOCATION from bluebin.ALT_REQ_LOCATION)
											)		   
												   
										THEN 1
             ELSE 0
           END                        AS BlueBinFlag,
		   a.EFF_STATUS as ACTIVE_STATUS
INTO bluebin.DimLocation
FROM   dbo.LOCATION_TBL a 
INNER JOIN (SELECT LOCATION, MIN(EFFDT) AS EFFDT FROM dbo.LOCATION_TBL GROUP BY LOCATION) b ON a.LOCATION  = b.LOCATION AND a.EFFDT = b.EFFDT 
INNER JOIN bluebin.DimFacility df on a.BUILDING COLLATE DATABASE_DEFAULT = df.FacilityName

--WHERE  a.EFF_STATUS = 'A'


GO

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'DimLocation'


