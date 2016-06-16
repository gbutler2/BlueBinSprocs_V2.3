BEGIN TRY
DROP TABLE DimBin
END TRY
BEGIN CATCH
END CATCH

/**********************************************************
FIELDS REQUIRED:
					BinKey
					BinItemKey
					BinLocationKey
					BinSequence
					BinCart
					BinRow
					BinPosition
					BinSize
					BinUOM
					BinQty
					BinLeadTime
					BinAddedDate
**********************************************************/
SELECT Row_number()
         OVER(
           ORDER BY Bins.INV_CART_ID, Bins.INV_ITEM_ID) AS BinKey,
       Bins.INV_CART_ID                                 AS CartId,
       Bins.INV_ITEM_ID                                 AS ItemId,
       Locations.LOCATION                               AS LocationId,
       Bins.COMPARTMENT                                 AS BinSequence,
       LEFT(Bins.COMPARTMENT, 1)                        AS BinCart,
       Substring(Bins.COMPARTMENT, 2, 1)                AS BinRow,
       Substring(Bins.COMPARTMENT, 3, 2)                AS BinPosition,
       RIGHT(Bins.COMPARTMENT, 3)                       AS BinSize,
       Bins.UNIT_OF_MEASURE                             AS Binuom,
       Cast(Bins.QTY_OPTIMAL AS INT)                    AS Binqty,
       3                                                AS BinLeadTime,
	   Locations.EFFDT									AS BinGoLiveDate
INTO   DimBin
FROM   ps.CART_TEMPL_INV Bins
       LEFT JOIN ps.CART_ATTRIB_INV Carts
              ON Bins.INV_CART_ID = Carts.INV_CART_ID
       LEFT JOIN ps.LOCATION_TBL Locations
              ON Carts.LOCATION = Locations.LOCATION
WHERE  Carts.LOCATION LIKE 'B%' 

GO

BEGIN TRY
DROP TABLE DimBinStatus
END TRY

BEGIN CATCH
END CATCH
GO

CREATE TABLE [dbo].[DimBinStatus](
	[BinStatusKey] [int] NULL,
	[BinStatus] [varchar](50) NULL
) ON [PRIMARY]

GO



INSERT INTO dbo.DimBinStatus (	BinStatusKey,	BinStatus	) VALUES( 1, 'Healthy')
INSERT INTO dbo.DimBinStatus (	BinStatusKey,	BinStatus	) VALUES( 2, 'Hot')
INSERT INTO dbo.DimBinStatus (	BinStatusKey,	BinStatus	) VALUES( 3, 'Very Hot' )
INSERT INTO dbo.DimBinStatus (	BinStatusKey,	BinStatus	) VALUES( 4, 'Extremely Hot' )
INSERT INTO dbo.DimBinStatus (	BinStatusKey,	BinStatus	) VALUES( 5, 'Slow' )
INSERT INTO dbo.DimBinStatus (	BinStatusKey,	BinStatus	) VALUES( 6, 'Stale')
INSERT INTO dbo.DimBinStatus (	BinStatusKey,	BinStatus	) VALUES( 7, 'Never Scanned')

GO

BEGIN TRY
	DROP TABLE [dbo].[DimDate]
END TRY

BEGIN CATCH
	/*No Action*/
END CATCH

/**********************************************************************************/

CREATE TABLE	[dbo].[DimDate]
	(	[DateKey] INT primary key, 
		[Date] DATETIME,
		[FullDateUK] CHAR(10), -- Date in dd-MM-yyyy format
		[FullDateUSA] CHAR(10),-- Date in MM-dd-yyyy format
		[DayOfMonth] VARCHAR(2), -- Field will hold day number of Month
		[DaySuffix] VARCHAR(4), -- Apply suffix as 1st, 2nd ,3rd etc
		[DayName] VARCHAR(9), -- Contains name of the day, Sunday, Monday 
		[DayOfWeekUSA] CHAR(1),-- First Day Sunday=1 and Saturday=7
		[DayOfWeekUK] CHAR(1),-- First Day Monday=1 and Sunday=7
		[DayOfWeekInMonth] VARCHAR(2), --1st Monday or 2nd Monday in Month
		[DayOfWeekInYear] VARCHAR(2),
		[DayOfQuarter] VARCHAR(3),
		[DayOfYear] VARCHAR(3),
		[WeekOfMonth] VARCHAR(1),-- Week Number of Month 
		[WeekOfQuarter] VARCHAR(2), --Week Number of the Quarter
		[WeekOfYear] VARCHAR(2),--Week Number of the Year
		[Month] VARCHAR(2), --Number of the Month 1 to 12
		[MonthName] VARCHAR(9),--January, February etc
		[MonthOfQuarter] VARCHAR(2),-- Month Number belongs to Quarter
		[Quarter] CHAR(1),
		[QuarterName] VARCHAR(9),--First,Second..
		[Year] CHAR(4),-- Year value of Date stored in Row
		[YearName] CHAR(7), --CY 2012,CY 2013
		[MonthYear] CHAR(10), --Jan-2013,Feb-2013
		[MMYYYY] CHAR(6),
		[FirstDayOfMonth] DATE,
		[LastDayOfMonth] DATE,
		[FirstDayOfQuarter] DATE,
		[LastDayOfQuarter] DATE,
		[FirstDayOfYear] DATE,
		[LastDayOfYear] DATE,
		[IsHolidayUSA] BIT,-- Flag 1=National Holiday, 0-No National Holiday
		[IsWeekday] BIT,-- 0=Week End ,1=Week Day
		[HolidayUSA] VARCHAR(50),--Name of Holiday in US
		[IsHolidayUK] BIT Null,-- Flag 1=National Holiday, 0-No National Holiday
		[HolidayUK] VARCHAR(50) Null --Name of Holiday in UK
	)
GO

/********************************************************************************************/
--Specify Start Date and End date here
--Value of Start Date Must be Less than Your End Date 

DECLARE @StartDate DATETIME = DATEADD(DAY, -90, CONVERT(varchar, GETDATE(), 101)) --Starting value of Date Range
DECLARE @EndDate DATETIME = CONVERT(varchar, GETDATE(), 101) --End Value of Date Range

--Temporary Variables To Hold the Values During Processing of Each Date of Year
DECLARE
	@DayOfWeekInMonth INT,
	@DayOfWeekInYear INT,
	@DayOfQuarter INT,
	@WeekOfMonth INT,
	@CurrentYear INT,
	@CurrentMonth INT,
	@CurrentQuarter INT

--/*Table Data type to store the day of week count for the month and year*/
DECLARE @DayOfWeek TABLE (DOW INT, MonthCount INT, QuarterCount INT, YearCount INT)

INSERT INTO @DayOfWeek VALUES (1, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (2, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (3, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (4, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (5, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (6, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (7, 0, 0, 0)

--Extract and assign various parts of Values from Current Date to Variable

DECLARE @CurrentDate AS DATETIME = @StartDate
SET @CurrentMonth = DATEPART(MM, @CurrentDate)
SET @CurrentYear = DATEPART(YY, @CurrentDate)
SET @CurrentQuarter = DATEPART(QQ, @CurrentDate)

/********************************************************************************************/
--Proceed only if Start Date(Current date ) is less than End date you specified above

WHILE @CurrentDate < @EndDate
BEGIN
 
/*Begin day of week logic*/

         /*Check for Change in Month of the Current date if Month changed then 
          Change variable value*/
	IF @CurrentMonth != DATEPART(MM, @CurrentDate) 
	BEGIN
		UPDATE @DayOfWeek
		SET MonthCount = 0
		SET @CurrentMonth = DATEPART(MM, @CurrentDate)
	END

        /* Check for Change in Quarter of the Current date if Quarter changed then change 
         Variable value*/

	IF @CurrentQuarter != DATEPART(QQ, @CurrentDate)
	BEGIN
		UPDATE @DayOfWeek
		SET QuarterCount = 0
		SET @CurrentQuarter = DATEPART(QQ, @CurrentDate)
	END
       
        /* Check for Change in Year of the Current date if Year changed then change 
         Variable value*/
	

	IF @CurrentYear != DATEPART(YY, @CurrentDate)
	BEGIN
		UPDATE @DayOfWeek
		SET YearCount = 0
		SET @CurrentYear = DATEPART(YY, @CurrentDate)
	END
	
         --Set values in table data type created above from variables 

	UPDATE @DayOfWeek
	SET 
		MonthCount = MonthCount + 1,
		QuarterCount = QuarterCount + 1,
		YearCount = YearCount + 1
	WHERE DOW = DATEPART(DW, @CurrentDate)

	SELECT
		@DayOfWeekInMonth = MonthCount,
		@DayOfQuarter = QuarterCount,
		@DayOfWeekInYear = YearCount
	FROM @DayOfWeek
	WHERE DOW = DATEPART(DW, @CurrentDate)
	
/*End day of week logic*/


/* Populate Your Dimension Table with values*/
	
	INSERT INTO [dbo].[DimDate]
	SELECT
		
		CONVERT (char(8),@CurrentDate,112) as DateKey,
		@CurrentDate AS Date,
		CONVERT (char(10),@CurrentDate,103) as FullDateUK,
		CONVERT (char(10),@CurrentDate,101) as FullDateUSA,
		DATEPART(DD, @CurrentDate) AS DayOfMonth,
		--Apply Suffix values like 1st, 2nd 3rd etc..
		CASE 
			WHEN DATEPART(DD,@CurrentDate) IN (11,12,13) THEN CAST(DATEPART(DD,@CurrentDate) AS VARCHAR) + 'th'
			WHEN RIGHT(DATEPART(DD,@CurrentDate),1) = 1	THEN CAST(DATEPART(DD,@CurrentDate) AS VARCHAR) + 'st'
			WHEN RIGHT(DATEPART(DD,@CurrentDate),1) = 2 THEN CAST(DATEPART(DD,@CurrentDate) AS VARCHAR) + 'nd'
			WHEN RIGHT(DATEPART(DD,@CurrentDate),1) = 3 THEN CAST(DATEPART(DD,@CurrentDate) AS VARCHAR) + 'rd'
			ELSE CAST(DATEPART(DD,@CurrentDate) AS VARCHAR) + 'th' 
			END AS DaySuffix,
		
		DATENAME(DW, @CurrentDate) AS DayName,
		DATEPART(DW, @CurrentDate) AS DayOfWeekUSA,

		 --check for day of week as Per US and change it as per UK format 
		CASE DATEPART(DW, @CurrentDate)
			WHEN 1 THEN 7
			WHEN 2 THEN 1
			WHEN 3 THEN 2
			WHEN 4 THEN 3
			WHEN 5 THEN 4
			WHEN 6 THEN 5
			WHEN 7 THEN 6
			END 
			AS DayOfWeekUK,
		
		@DayOfWeekInMonth AS DayOfWeekInMonth,
		@DayOfWeekInYear AS DayOfWeekInYear,
		@DayOfQuarter AS DayOfQuarter,
		DATEPART(DY, @CurrentDate) AS DayOfYear,
		DATEPART(WW, @CurrentDate) + 1 - DATEPART(WW, CONVERT(VARCHAR, 
		DATEPART(MM, @CurrentDate)) + '/1/' + CONVERT(VARCHAR,
		DATEPART(YY, @CurrentDate))) AS WeekOfMonth,
		(DATEDIFF(DD, DATEADD(QQ, DATEDIFF(QQ, 0, @CurrentDate), 0),@CurrentDate) / 7) + 1 AS WeekOfQuarter,
		DATEPART(WW, @CurrentDate) AS WeekOfYear,
		DATEPART(MM, @CurrentDate) AS Month,
		DATENAME(MM, @CurrentDate) AS MonthName,
		CASE
			WHEN DATEPART(MM, @CurrentDate) IN (1, 4, 7, 10) THEN 1
			WHEN DATEPART(MM, @CurrentDate) IN (2, 5, 8, 11) THEN 2
			WHEN DATEPART(MM, @CurrentDate) IN (3, 6, 9, 12) THEN 3
			END AS MonthOfQuarter,
		DATEPART(QQ, @CurrentDate) AS Quarter,
		CASE DATEPART(QQ, @CurrentDate)
			WHEN 1 THEN 'First'
			WHEN 2 THEN 'Second'
			WHEN 3 THEN 'Third'
			WHEN 4 THEN 'Fourth'
			END AS QuarterName,
		DATEPART(YEAR, @CurrentDate) AS Year,
		'CY ' + CONVERT(VARCHAR, DATEPART(YEAR, @CurrentDate)) AS YearName,
		LEFT(DATENAME(MM, @CurrentDate), 3) + '-' + CONVERT(VARCHAR, DATEPART(YY, @CurrentDate)) AS MonthYear,
		RIGHT('0' + CONVERT(VARCHAR, DATEPART(MM, @CurrentDate)),2) + CONVERT(VARCHAR, DATEPART(YY, @CurrentDate)) AS MMYYYY,
		CONVERT(DATETIME, CONVERT(DATE, DATEADD(DD, - (DATEPART(DD, @CurrentDate) - 1), @CurrentDate))) AS FirstDayOfMonth,
		CONVERT(DATETIME, CONVERT(DATE, DATEADD(DD, - (DATEPART(DD, (DATEADD(MM, 1, @CurrentDate)))), DATEADD(MM, 1, @CurrentDate)))) AS LastDayOfMonth,
		DATEADD(QQ, DATEDIFF(QQ, 0, @CurrentDate), 0) AS FirstDayOfQuarter,
		DATEADD(QQ, DATEDIFF(QQ, -1, @CurrentDate), -1) AS LastDayOfQuarter,
		CONVERT(DATETIME, '01/01/' + CONVERT(VARCHAR, DATEPART(YY, @CurrentDate))) AS FirstDayOfYear,
		CONVERT(DATETIME, '12/31/' + CONVERT(VARCHAR, DATEPART(YY, @CurrentDate))) AS LastDayOfYear,
		NULL AS IsHolidayUSA,
		CASE DATEPART(DW, @CurrentDate)
			WHEN 1 THEN 0
			WHEN 2 THEN 1
			WHEN 3 THEN 1
			WHEN 4 THEN 1
			WHEN 5 THEN 1
			WHEN 6 THEN 1
			WHEN 7 THEN 0
			END AS IsWeekday,
		NULL AS HolidayUSA, Null, Null

	SET @CurrentDate = DATEADD(DD, 1, @CurrentDate)
END

/*******************************************************************************************
 
Step 3.
Update Values of Holiday as per UK Government Declaration for National Holiday.

Update HOLIDAY fields of UK as per Govt. Declaration of National Holiday*/
	
 --Good Friday  April 18 
	UPDATE [dbo].[DimDate]
		SET HolidayUK = 'Good Friday'
	WHERE [Month] = 4 AND [DayOfMonth]  = 18

 --Easter Monday  April 21 
	UPDATE [dbo].[DimDate]
		SET HolidayUK = 'Easter Monday'
	WHERE [Month] = 4 AND [DayOfMonth]  = 21

 --Early May Bank Holiday   May 5 
   UPDATE [dbo].[DimDate]
		SET HolidayUK = 'Early May Bank Holiday'
	WHERE [Month] = 5 AND [DayOfMonth]  = 5

 --Spring Bank Holiday  May 26 
	UPDATE [dbo].[DimDate]
		SET HolidayUK = 'Spring Bank Holiday'
	WHERE [Month] = 5 AND [DayOfMonth]  = 26

 --Summer Bank Holiday  August 25 
    UPDATE [dbo].[DimDate]
		SET HolidayUK = 'Summer Bank Holiday'
	WHERE [Month] = 8 AND [DayOfMonth]  = 25

 --Boxing Day  December 26  	
    UPDATE [dbo].[DimDate]
		SET HolidayUK = 'Boxing Day'
	WHERE [Month] = 12 AND [DayOfMonth]  = 26	

--CHRISTMAS
	UPDATE [dbo].[DimDate]
		SET HolidayUK = 'Christmas Day'
	WHERE [Month] = 12 AND [DayOfMonth]  = 25

--New Years Day
	UPDATE [dbo].[DimDate]
		SET HolidayUK  = 'New Year''s Day'
	WHERE [Month] = 1 AND [DayOfMonth] = 1

--Update flag for UK Holidays 1= Holiday, 0=No Holiday
	
	UPDATE [dbo].[DimDate]
		SET IsHolidayUK  = CASE WHEN HolidayUK   IS NULL THEN 0 WHEN HolidayUK   IS NOT NULL THEN 1 END
		
 
--Step 4.
--Update Values of Holiday as per USA Govt. Declaration for National Holiday.

/*Update HOLIDAY Field of USA In dimension*/
	
 	/*THANKSGIVING - Fourth THURSDAY in November*/
	UPDATE [dbo].[DimDate]
		SET HolidayUSA = 'Thanksgiving Day'
	WHERE
		[Month] = 11 
		AND [DayOfWeekUSA] = 'Thursday' 
		AND DayOfWeekInMonth = 4

	/*CHRISTMAS*/
	UPDATE [dbo].[DimDate]
		SET HolidayUSA = 'Christmas Day'
		
	WHERE [Month] = 12 AND [DayOfMonth]  = 25

	/*4th of July*/
	UPDATE [dbo].[DimDate]
		SET HolidayUSA = 'Independance Day'
	WHERE [Month] = 7 AND [DayOfMonth] = 4

	/*New Years Day*/
	UPDATE [dbo].[DimDate]
		SET HolidayUSA = 'New Year''s Day'
	WHERE [Month] = 1 AND [DayOfMonth] = 1

	/*Memorial Day - Last Monday in May*/
	UPDATE [dbo].[DimDate]
		SET HolidayUSA = 'Memorial Day'
	FROM [dbo].[DimDate]
	WHERE DateKey IN 
		(
		SELECT
			MAX(DateKey)
		FROM [dbo].[DimDate]
		WHERE
			[MonthName] = 'May'
			AND [DayOfWeekUSA]  = 'Monday'
		GROUP BY
			[Year],
			[Month]
		)

	/*Labor Day - First Monday in September*/
	UPDATE [dbo].[DimDate]
		SET HolidayUSA = 'Labor Day'
	FROM [dbo].[DimDate]
	WHERE DateKey IN 
		(
		SELECT
			MIN(DateKey)
		FROM [dbo].[DimDate]
		WHERE
			[MonthName] = 'September'
			AND [DayOfWeekUSA] = 'Monday'
		GROUP BY
			[Year],
			[Month]
		)

	/*Valentine's Day*/
	UPDATE [dbo].[DimDate]
		SET HolidayUSA = 'Valentine''s Day'
	WHERE
		[Month] = 2 
		AND [DayOfMonth] = 14

	/*Saint Patrick's Day*/
	UPDATE [dbo].[DimDate]
		SET HolidayUSA = 'Saint Patrick''s Day'
	WHERE
		[Month] = 3
		AND [DayOfMonth] = 17

	/*Martin Luthor King Day - Third Monday in January starting in 1983*/
	UPDATE [dbo].[DimDate]
		SET HolidayUSA = 'Martin Luthor King Jr Day'
	WHERE
		[Month] = 1
		AND [DayOfWeekUSA]  = 'Monday'
		AND [Year] >= 1983
		AND DayOfWeekInMonth = 3

	/*President's Day - Third Monday in February*/
	UPDATE [dbo].[DimDate]
		SET HolidayUSA = 'President''s Day'
	WHERE
		[Month] = 2
		AND [DayOfWeekUSA] = 'Monday'
		AND DayOfWeekInMonth = 3

	/*Mother's Day - Second Sunday of May*/
	UPDATE [dbo].[DimDate]
		SET HolidayUSA = 'Mother''s Day'
	WHERE
		[Month] = 5
		AND [DayOfWeekUSA] = 'Sunday'
		AND DayOfWeekInMonth = 2

	/*Father's Day - Third Sunday of June*/
	UPDATE [dbo].[DimDate]
		SET HolidayUSA = 'Father''s Day'
	WHERE
		[Month] = 6
		AND [DayOfWeekUSA] = 'Sunday'
		AND DayOfWeekInMonth = 3

	/*Halloween 10/31*/
	UPDATE [dbo].[DimDate]
		SET HolidayUSA = 'Halloween'
	WHERE
		[Month] = 10
		AND [DayOfMonth] = 31

	/*Election Day - The first Tuesday after the first Monday in November*/
	BEGIN
	DECLARE @Holidays TABLE (ID INT IDENTITY(1,1), DateID int, Week TINYINT, YEAR CHAR(4), DAY CHAR(2))

		INSERT INTO @Holidays(DateID, [Year],[Day])
		SELECT
			DateKey,
			[Year],
			[DayOfMonth] 
		FROM [dbo].[DimDate]
		WHERE
			[Month] = 11
			AND [DayOfWeekUSA] = 'Monday'
		ORDER BY
			YEAR,
			DayOfMonth 

		DECLARE @CNTR INT, @POS INT, @STARTYEAR INT, @ENDYEAR INT, @MINDAY INT

		SELECT
			@CURRENTYEAR = MIN([Year])
			, @STARTYEAR = MIN([Year])
			, @ENDYEAR = MAX([Year])
		FROM @Holidays

		WHILE @CURRENTYEAR <= @ENDYEAR
		BEGIN
			SELECT @CNTR = COUNT([Year])
			FROM @Holidays
			WHERE [Year] = @CURRENTYEAR

			SET @POS = 1

			WHILE @POS <= @CNTR
			BEGIN
				SELECT @MINDAY = MIN(DAY)
				FROM @Holidays
				WHERE
					[Year] = @CURRENTYEAR
					AND [Week] IS NULL

				UPDATE @Holidays
					SET [Week] = @POS
				WHERE
					[Year] = @CURRENTYEAR
					AND [Day] = @MINDAY

				SELECT @POS = @POS + 1
			END

			SELECT @CURRENTYEAR = @CURRENTYEAR + 1
		END

		UPDATE [dbo].[DimDate]
			SET HolidayUSA  = 'Election Day'				
		FROM [dbo].[DimDate] DT
			JOIN @Holidays HL ON (HL.DateID + 1) = DT.DateKey
		WHERE
			[Week] = 1
	END
	--set flag for USA holidays in Dimension
	UPDATE [dbo].[DimDate]
SET IsHolidayUSA = CASE WHEN HolidayUSA  IS NULL THEN 0 WHEN HolidayUSA  IS NOT NULL THEN 1 END
/*****************************************************************************************/

GO

BEGIN Try
    DROP TABLE DimItem
END Try

BEGIN Catch
END Catch

SELECT Row_number()
         OVER(
           ORDER BY a.INV_ITEM_ID) AS ItemKey,
       a.INV_ITEM_ID               AS ItemId,
       DESCR                       AS ItemDescription,
       UNIT_MEASURE_STD            AS stDuom,
       b.MFG_ID                    AS ItemManufacturer,
       b.MFG_ITM_ID                AS ItemManufacturerNumber,
       d.NAME1                     AS ItemVendor,
       c.ITM_ID_VNDR               AS ItemVendorNumber
INTO   DimItem
FROM   ps.MASTER_ITEM_TBL a
       LEFT JOIN ps.ITEM_MFG b
              ON a.INV_ITEM_ID = b.INV_ITEM_ID
                 AND b.PREFERRED_MFG = 'Y'
       LEFT JOIN ps.ITM_VENDOR c
              ON a.INV_ITEM_ID = c.INV_ITEM_ID
                 AND c.ITM_VNDR_PRIORITY = 1
       LEFT JOIN ps.VENDOR d
              ON c.VENDOR_ID = d.VENDOR_ID 
GO

BEGIN TRY
DROP TABLE DimLocation
END TRY
BEGIN CATCH
END CATCH
SELECT Row_number()
         OVER(
           ORDER BY a.EFFDT) AS LocationKey,
       a.LOCATION            AS LocationId,
       UPPER(DESCR)               AS LocationName,
       a.EFFDT               AS GoLiveDate
	   INTO DimLocation
FROM   ps.LOCATION_TBL a INNER JOIN
(SELECT LOCATION, MIN(EFFDT) AS EFFDT FROM PS.LOCATION_TBL GROUP BY LOCATION) b ON a.LOCATION = b.LOCATION AND a.EFFDT = b.EFFDT
WHERE  a.EFF_STATUS = 'A'

GO

BEGIN TRY
DROP TABLE tmpCartCounts
END TRY
BEGIN CATCH END CATCH
SELECT 
ROW_NUMBER()OVER(PARTITION BY BinKey, CART_CT.CART_REPLEN_OPT ORDER BY CART_CT.CART_REPLEN_OPT, CASE
                     WHEN Datediff(HOUR, CART_CT.DEMAND_DATE, CART_CT.LAST_DTTM_UPDATE) < 24 THEN CART_CT.LAST_DTTM_UPDATE
                     ELSE DEMAND_DATE
                   END) as OrderSeq,
Bins.BinKey,
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
INTO tmpCartCounts
FROM   PS.CART_CT_INF_INV CART_CT
       INNER JOIN PS.CART_ATTRIB_INV CART
              ON CART_CT.INV_CART_ID = CART.INV_CART_ID
       INNER JOIN PS.LOCATION_TBL LOCATION
              ON CART.LOCATION = LOCATION.LOCATION
       INNER JOIN DimBin Bins
              ON CART.LOCATION = Bins.LocationID
                 AND CART_CT.INV_ITEM_ID = Bins.ItemID
WHERE  CART.LOCATION LIKE 'B%'
       AND CART_CT.CART_COUNT_QTY <> 0
ORDER  BY 2,1

GO

BEGIN TRY
DROP TABLE tmpPickLines
END TRY
BEGIN CATCH END CATCH
SELECT Bins.BinKey,
       INV_ITEM_ID as ItemID,
       LOCATION as LocationID,
       Picks.ORDER_NO as OrderNum,
       Picks.ORDER_INT_LINE_NO as LineNum,
       Picks.DEMAND_DATE as OrderDate,
       Picks.PICK_CONFIRM_DTTM as CloseDate,
       Cast(Picks.QTY_PICKED AS INT) AS OrderQty,
	   UNIT_OF_MEASURE as OrderUOM
INTO tmpPickLines
FROM   ps.IN_DEMAND Picks
       INNER JOIN DimBin Bins
               ON Picks.LOCATION = Bins.LocationID
                  AND Picks.INV_ITEM_ID = Bins.ItemID
WHERE  LOCATION LIKE 'B%'
       AND CANCEL_DTTM IS NULL
       AND PICK_BATCH_ID <> 0
       AND IN_FULFILL_STATE = 70
ORDER  BY BinKey,
          Picks.DEMAND_DATE 


		  GO
		  
BEGIN TRY
DROP TABLE tmpPOLines
END TRY
BEGIN CATCH
END CATCH
SELECT Bins.BinKey,
       PO_LN.INV_ITEM_ID   AS ItemID,
       LOCATION            AS LocationID,
       PO_LN.PO_ID         AS OrderNum,
       PO_LN.LINE_NBR      AS LineNum,
       PO_DT               AS OrderDate,
       RECEIPT_DTTM        AS CloseDate,
	   QTY_PO              AS OrderQty,
	   PO_LN.UNIT_OF_MEASURE as OrderUOM
INTO tmpPOLines
FROM   PS.PO_LINE_DISTRIB PO_LN_DST
       INNER JOIN PS.PO_LINE PO_LN
               ON PO_LN_DST.PO_ID = PO_LN.PO_ID
                  AND PO_LN_DST.LINE_NBR = PO_LN.LINE_NBR
       INNER JOIN PS.PO_HDR
               ON PO_LN.PO_ID = PO_HDR.PO_ID
       INNER JOIN DimBin Bins
               ON PO_LN.INV_ITEM_ID = Bins.ItemID
                  AND Bins.LocationID = PO_LN_DST.LOCATION
       LEFT JOIN PS.RECV_LN_SHIP SHIP
              ON PO_LN.PO_ID = SHIP.PO_ID
                 AND PO_LN.LINE_NBR = SHIP.LINE_NBR
WHERE  LOCATION LIKE 'B%'
ORDER  BY Bins.BinKey 

GO

BEGIN TRY
DROP TABLE tmpOrders
END TRY
BEGIN CATCH
END CATCH
GO
WITH AllOrders
     AS (SELECT *,
                'PO'                    AS OrderType
         FROM   tmpPOLines
         UNION ALL
         SELECT *,
                'MSR'                   AS OrderType
         FROM   tmpPickLines)
SELECT 
Row_number()
                  OVER(
                    Partition BY BinKey, OrderType
                    ORDER BY OrderType, OrderDate) AS OrderSeq,
*
INTO tmpOrders
FROM   AllOrders 

GO

BEGIN Try
    DROP TABLE FactScan
END Try

BEGIN Catch
END Catch

Go

WITH Scans
     AS (SELECT Row_number()
                  OVER(
                    Partition BY c.BinKey
                    ORDER BY c.OrderDate DESC) AS Scanseq,
					Row_number()
                  OVER(
                    Partition BY c.BinKey
                    ORDER BY c.OrderDate ASC) AS ScanHistseq,
                c.BinKey,
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
         FROM   tmpCartCounts c
                LEFT JOIN tmpOrders o
                       ON c.BinKey = o.BinKey
                          AND c.OrderSeq = o.OrderSeq
                          AND c.OrderType = o.OrderType
				WHERE OrderNum IS NOT NULL)
SELECT a.Scanseq,
	   a.BinKey,
       c.LocationKey,
       d.ItemKey,
       a.OrderTypeID,
       a.OrderType,
       a.CartCountNum,
       a.OrderNum,
       a.LineNum,
	   a.OrderUOM,
       Cast(a.OrderQty AS INT) AS OrderQty,
       a.OrderDate,
       a.CloseDate,
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
FROM   Scans a
       LEFT JOIN Scans b
              ON a.BinKey = b.BinKey
                 AND a.Scanseq = b.Scanseq - 1
       LEFT JOIN DimLocation c
              ON a.LocationID = c.LocationID
       LEFT JOIN DimItem d
              ON a.ItemID = d.ItemID
WHERE  a.OrderDate >= c.GoLiveDate 

GO

BEGIN Try
    DROP TABLE FactBinSnapshot
END Try

BEGIN Catch
END Catch

Go

WITH LastScans
     AS (SELECT Row_number()
                  OVER(
                    Partition BY BinKey, DimDate.Date
                    ORDER BY OrderDate DESC) AS Scanseq,
                BinKey,
                OrderDate                    AS LastScannedDate,
                DimDate.Date
         FROM   FactScan
                LEFT JOIN DimDate
                       ON OrderDate <= DimDate.Date),
     ThresholdScans
     AS (SELECT DimBin.BinKey,
                DimDate.Date,
                Sum(Coalesce(Scan,0))     AS ScansInThreshold,
                Sum(Coalesce(HotScan,0))  AS HotScansInThreshold,
                Sum(Coalesce(StockOut,0)) AS StockOutsInThreshold,
                Sum(CASE
                      WHEN Cast(OrderDate AS DATE) = Cast(Dateadd(Day, -1, DimDate.Date) AS DATE) THEN StockOut
                      ELSE 0
                    END)      AS StockOutsDaily
         FROM   
		 DimBin 
		 CROSS JOIN
		 DimDate
                LEFT JOIN FactScan
                       ON Cast(DimDate.Date as date) >= Cast(OrderDate as Date) AND DATEADD(DAY, -15, DimDate.Date) <= Cast(OrderDate as Date)
					   AND DimBin.BinKey = FactScan.BinKey
         WHERE DimDate.Date >= DimBin.BinGoLiveDate
		 GROUP  BY DimBin.BinKey,
                   DimDate.Date
),
     LastTwoScans
     AS (SELECT BinKey,
                Date,
                [1] AS FirstScan,
                [2] AS SecondScan
         FROM   (SELECT BinKey,
                        Row_number()
                          OVER(
                            Partition BY BinKey, b.Date
                            ORDER BY OrderDate DESC) AS Scanseq,
                        b.Date,
                        ( HotScan + StockOut )       AS HotScan
                 FROM   FactScan a
                        INNER JOIN DimDate b
                                ON Cast(a.OrderDate AS DATE) <= Cast(b.Date AS DATE)) p
                PIVOT ( Sum(HotScan)
                      FOR ScanSeq IN ([1],
                                      [2]) ) AS pvt)
SELECT DimBin.BinKey,
       DimLocation.LocationKey,
       DimItem.ItemKey,
       DimDate.Date                                                                 AS BinSnapshotDate,
       COALESCE(LastScannedDate, DimBin.BinGoLiveDate)                              AS LastScannedDate,
       Datediff(Day, COALESCE(LastScannedDate, DimBin.BinGoLiveDate), DimDate.Date) AS DaysSinceLastScan,
       COALESCE(ScansInThreshold, 0)                                                AS ScanSinThreshold,
       COALESCE(HotScansInThreshold, 0)                                             AS HotScanSinThreshold,
       COALESCE(StockOutsInThreshold, 0)                                            AS StockOutSinThreshold,
       COALESCE(StockOutsDaily, 0)                                                  AS StockOutsDaily,
       CASE
         WHEN (( COALESCE(LastTwoScans.FirstScan, 0) = 0
                AND COALESCE(LastTwoScans.SecondScan, 0) = 0 )
				OR ThresholdScans.HotScansInThreshold < 2)
              AND Datediff(Day, LastScannedDate, DimDate.Date) BETWEEN 0 AND 90 THEN 1
         WHEN ThresholdScans.HotScansInThreshold >= 8 THEN 4
         WHEN ThresholdScans.HotScansInThreshold >= 4
              AND ThresholdScans.HotScansInThreshold < 8 THEN 3
         WHEN ThresholdScans.HotScansInThreshold >= 2
              AND ThresholdScans.HotScansInThreshold < 4 THEN 2
         WHEN Datediff(Day, COALESCE(LastScannedDate, DimBin.BinGoLiveDate), DimDate.Date) BETWEEN 90 AND 180 THEN 5
         WHEN Datediff(Day, COALESCE(LastScannedDate, DimBin.BinGoLiveDate), DimDate.Date) >= 180 THEN 6
         WHEN DimBin.BinKey NOT IN (SELECT DISTINCT BinKey
                                    FROM   FactScan
                                    WHERE  OrderDate <= DimDate.Date) THEN 7
         ELSE 0
       END                                                                          AS BinStatusKey,
       DimBinStatus.BinStatus,
       CASE
         WHEN (( COALESCE(LastTwoScans.FirstScan, 0) = 0
                AND COALESCE(LastTwoScans.SecondScan, 0) = 0 )
				OR ThresholdScans.HotScansInThreshold < 2)
              AND Datediff(Day, LastScannedDate, DimDate.Date) BETWEEN 0 AND 90 THEN 1
         WHEN ThresholdScans.HotScansInThreshold >= 8 THEN 0
         WHEN ThresholdScans.HotScansInThreshold >= 4
              AND ThresholdScans.HotScansInThreshold < 8 THEN 0
         WHEN ThresholdScans.HotScansInThreshold >= 2
              AND ThresholdScans.HotScansInThreshold < 4 THEN 0
         WHEN Datediff(Day, COALESCE(LastScannedDate, DimBin.BinGoLiveDate), DimDate.Date) BETWEEN 90 AND 180 THEN 0
         WHEN Datediff(Day, COALESCE(LastScannedDate, DimBin.BinGoLiveDate), DimDate.Date) >= 180 THEN 0
         ELSE 0
       END                                                                          AS HealthyBins,
       CASE
         WHEN (( COALESCE(LastTwoScans.FirstScan, 0) = 0
                AND COALESCE(LastTwoScans.SecondScan, 0) = 0 )
				OR ThresholdScans.HotScansInThreshold < 2)
              AND Datediff(Day, LastScannedDate, DimDate.Date) BETWEEN 0 AND 90 THEN 0
         WHEN ThresholdScans.HotScansInThreshold >= 8 THEN 0
         WHEN ThresholdScans.HotScansInThreshold >= 4
              AND ThresholdScans.HotScansInThreshold < 8 THEN 0
         WHEN ThresholdScans.HotScansInThreshold >= 2
              AND ThresholdScans.HotScansInThreshold < 4 THEN 1
         WHEN Datediff(Day, COALESCE(LastScannedDate, DimBin.BinGoLiveDate), DimDate.Date) BETWEEN 90 AND 180 THEN 0
         WHEN Datediff(Day, COALESCE(LastScannedDate, DimBin.BinGoLiveDate), DimDate.Date) >= 180 THEN 0
         ELSE 0
       END                                                                          AS HotBins,
       CASE
                  WHEN (( COALESCE(LastTwoScans.FirstScan, 0) = 0
                AND COALESCE(LastTwoScans.SecondScan, 0) = 0 )
				OR ThresholdScans.HotScansInThreshold < 2)
              AND Datediff(Day, LastScannedDate, DimDate.Date) BETWEEN 0 AND 90 THEN 0
         WHEN ThresholdScans.HotScansInThreshold >= 8 THEN 0
         WHEN ThresholdScans.HotScansInThreshold >= 4
              AND ThresholdScans.HotScansInThreshold < 8 THEN 1
         WHEN ThresholdScans.HotScansInThreshold >= 2
              AND ThresholdScans.HotScansInThreshold < 4 THEN 0
         WHEN Datediff(Day, COALESCE(LastScannedDate, DimBin.BinGoLiveDate), DimDate.Date) BETWEEN 90 AND 180 THEN 0
         WHEN Datediff(Day, COALESCE(LastScannedDate, DimBin.BinGoLiveDate), DimDate.Date) >= 180 THEN 0
         ELSE 0
       END                                                                          AS VeryHotBins,
       CASE
                  WHEN (( COALESCE(LastTwoScans.FirstScan, 0) = 0
                AND COALESCE(LastTwoScans.SecondScan, 0) = 0 )
				OR ThresholdScans.HotScansInThreshold < 2)
              AND Datediff(Day, LastScannedDate, DimDate.Date) BETWEEN 0 AND 90 THEN 0
         WHEN ThresholdScans.HotScansInThreshold >= 8 THEN 1
         WHEN ThresholdScans.HotScansInThreshold >= 4
              AND ThresholdScans.HotScansInThreshold < 8 THEN 0
         WHEN ThresholdScans.HotScansInThreshold >= 2
              AND ThresholdScans.HotScansInThreshold < 4 THEN 0
         WHEN Datediff(Day, COALESCE(LastScannedDate, DimBin.BinGoLiveDate), DimDate.Date) BETWEEN 90 AND 180 THEN 0
         WHEN Datediff(Day, COALESCE(LastScannedDate, DimBin.BinGoLiveDate), DimDate.Date) >= 180 THEN 0
         ELSE 0
       END                                                                          AS ExtremelyHotBins,
       CASE
                  WHEN (( COALESCE(LastTwoScans.FirstScan, 0) = 0
                AND COALESCE(LastTwoScans.SecondScan, 0) = 0 )
				OR ThresholdScans.HotScansInThreshold < 2)
              AND Datediff(Day, LastScannedDate, DimDate.Date) BETWEEN 0 AND 90 THEN 0
         WHEN ThresholdScans.HotScansInThreshold >= 8 THEN 0
         WHEN ThresholdScans.HotScansInThreshold >= 4
              AND ThresholdScans.HotScansInThreshold < 8 THEN 0
         WHEN ThresholdScans.HotScansInThreshold >= 2
              AND ThresholdScans.HotScansInThreshold < 4 THEN 0
         WHEN Datediff(Day, COALESCE(LastScannedDate, DimBin.BinGoLiveDate), DimDate.Date) BETWEEN 90 AND 180 THEN 1
         WHEN Datediff(Day, COALESCE(LastScannedDate, DimBin.BinGoLiveDate), DimDate.Date) >= 180 THEN 0
         ELSE 0
       END                                                                          AS SlowBins,
       CASE
        WHEN (( COALESCE(LastTwoScans.FirstScan, 0) = 0
                AND COALESCE(LastTwoScans.SecondScan, 0) = 0 )
				OR ThresholdScans.HotScansInThreshold < 2)
              AND Datediff(Day, LastScannedDate, DimDate.Date) BETWEEN 0 AND 90 THEN 0
         WHEN ThresholdScans.HotScansInThreshold >= 8 THEN 0
         WHEN ThresholdScans.HotScansInThreshold >= 4
              AND ThresholdScans.HotScansInThreshold < 8 THEN 0
         WHEN ThresholdScans.HotScansInThreshold >= 2
              AND ThresholdScans.HotScansInThreshold < 4 THEN 0
         WHEN Datediff(Day, COALESCE(LastScannedDate, DimBin.BinGoLiveDate), DimDate.Date) BETWEEN 90 AND 180 THEN 0
         WHEN Datediff(Day, COALESCE(LastScannedDate, DimBin.BinGoLiveDate), DimDate.Date) >= 180 THEN 1
         ELSE 0
       END                                                                          AS StaleBins,
       CASE
         WHEN DimBin.BinKey NOT IN (SELECT DISTINCT BinKey
                                    FROM   FactScan
                                    WHERE  OrderDate <= DimDate.Date) THEN 1
         ELSE 0
       END                                                                          AS NeverScannedBins
INTO FactBinSnapshot
FROM   dbo.DimBin
       CROSS JOIN dbo.DimDate
       LEFT JOIN LastScans
              ON DimBin.BinKey = LastScans.BinKey
                 AND DimDate.Date = LastScans.Date
                 AND LastScans.ScanSeq = 1
       LEFT JOIN ThresholdScans
              ON DimBin.BinKey = ThresholdScans.BinKey
                 AND DimDate.Date = ThresholdScans.Date
       LEFT JOIN LastTwoScans
              ON DimBin.BinKey = LastTwoScans.BinKey AND DimDate.Date = LastTwoScans.Date
       LEFT JOIN DimBinStatus
              ON BinStatusKey = CASE
                                  WHEN (( COALESCE(LastTwoScans.FirstScan, 0) = 0
                AND COALESCE(LastTwoScans.SecondScan, 0) = 0 )
				OR ThresholdScans.HotScansInThreshold < 2)
              AND Datediff(Day, LastScannedDate, DimDate.Date) BETWEEN 0 AND 90 THEN 1
                                  WHEN ThresholdScans.HotScansInThreshold >= 8 THEN 4
                                  WHEN ThresholdScans.HotScansInThreshold >= 4
                                       AND ThresholdScans.HotScansInThreshold < 8 THEN 3
                                  WHEN ThresholdScans.HotScansInThreshold >= 2
                                       AND ThresholdScans.HotScansInThreshold < 4 THEN 2
                                  WHEN Datediff(Day, COALESCE(LastScannedDate, DimBin.BinGoLiveDate), DimDate.Date) BETWEEN 90 AND 180 THEN 5
                                  WHEN Datediff(Day, COALESCE(LastScannedDate, DimBin.BinGoLiveDate), DimDate.Date) >= 180 THEN 6
                                  WHEN DimBin.BinKey NOT IN (SELECT DISTINCT BinKey
                                                             FROM   FactScan
                                                             WHERE  OrderDate <= DimDate.Date) THEN 7
                                  ELSE 0
                                END
       LEFT JOIN DimLocation
              ON DimBin.LocationID = DimLocation.LocationID
       LEFT JOIN DimItem
              ON DimBin.ItemID = DimItem.ItemID
WHERE  BinGoLiveDate <= DimDate.Date
       AND DimDate.Date >= Dateadd(Day, -90, Getdate())
       --AND DimBin.BinKey = 2
ORDER  BY 1,
          4 

		  GO
		  
BEGIN TRY
DROP TABLE tableau.SCMDashboard
END TRY
BEGIN CATCH
END CATCH

SELECT 
DimBin.BinKey,
DimBin.CartId,
DimBin.ItemId,
DimBin.LocationId,
DimBin.BinSequence,
DimBin.BinCart,
DimBin.BinRow,
DimBin.BinPosition,
DimBin.BinSize,
DimBin.Binuom,
DimBin.Binqty,
DimBin.BinLeadTime,
DimBin.BinGoLiveDate,
DimDate.Date,
DimDate.FullDateUK,
DimDate.FullDateUSA,
DimDate.DayOfMonth,
DimDate.DaySuffix,
DimDate.DayName,
DimDate.DayOfWeekUSA,
DimDate.DayOfWeekUK,
DimDate.DayOfWeekInMonth,
DimDate.DayOfWeekInYear,
DimDate.DayOfQuarter,
DimDate.DayOfYear,
DimDate.WeekOfMonth,
DimDate.WeekOfQuarter,
DimDate.WeekOfYear,
DimDate.Month,
DimDate.MonthName,
DimDate.MonthOfQuarter,
DimDate.Quarter,
DimDate.QuarterName,
DimDate.Year,
DimDate.YearName,
DimDate.MonthYear,
DimDate.MMYYYY,
DimDate.FirstDayOfMonth,
DimDate.LastDayOfMonth,
DimDate.FirstDayOfQuarter,
DimDate.LastDayOfQuarter,
DimDate.FirstDayOfYear,
DimDate.LastDayOfYear,
DimDate.IsHolidayUSA,
DimDate.IsWeekday,
DimDate.HolidayUSA,
DimDate.IsHolidayUK,
DimDate.HolidayUK,
FactScan.Scanseq,
FactScan.OrderTypeID,
FactScan.OrderType,
FactScan.CartCountNum,
FactScan.OrderNum,
FactScan.LineNum,
FactScan.OrderUOM,
FactScan.OrderQty,
FactScan.OrderDate,
FactScan.CloseDate,
FactScan.PrevOrderDate,
FactScan.PrevOrderCloseDate,
FactScan.Scan,
FactScan.HotScan,
FactScan.StockOut,
FactBinSnapshot.BinSnapshotDate,
FactBinSnapshot.LastScannedDate,
FactBinSnapshot.DaysSinceLastScan,
FactBinSnapshot.ScanSinThreshold,
FactBinSnapshot.HotScanSinThreshold,
FactBinSnapshot.StockOutSinThreshold,
FactBinSnapshot.StockOutsDaily,
FactBinSnapshot.BinStatus,
FactBinSnapshot.HealthyBins,
FactBinSnapshot.HotBins,
FactBinSnapshot.VeryHotBins,
FactBinSnapshot.ExtremelyHotBins,
FactBinSnapshot.SlowBins,
FactBinSnapshot.StaleBins,
FactBinSnapshot.NeverScannedBins,
DimItem.ItemDescription,
DimItem.StdUOM,
DimItem.ItemManufacturer,
DimItem.ItemManufacturerNumber,
DimItem.ItemVendor,
DimItem.ItemVendorNumber,
DimLocation.LocationName,
1 as TotalBins
INTO tableau.SCMDashboard
FROM   DimBin
       CROSS JOIN DimDate
       LEFT JOIN FactScan
              ON Cast(OrderDate AS DATE) = Cast(Date AS DATE)
                 AND DimBin.BinKey = FactScan.BinKey
       LEFT JOIN FactBinSnapshot
              ON Date = BinSnapshotDate
                 AND DimBin.BinKey = FactBinSnapshot.BinKey
       LEFT JOIN DimItem
              ON DimBin.ItemId = DimItem.ItemId
       LEFT JOIN DimLocation
              ON DimBin.LocationId = DimLocation.LocationId
WHERE  Date >= BinGoLiveDate

ORDER  BY Date 


