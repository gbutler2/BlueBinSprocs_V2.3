
/********************************************************************

					Warehouse History

********************************************************************/


if exists (select * from dbo.sysobjects where id = object_id(N'etl_FactWHHistory') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure etl_FactWHHistory
GO

--exec etl_FactWHHistory
CREATE PROCEDURE etl_FactWHHistory

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

if not exists(select * from sys.tables where name = 'FactWHHistory')
BEGIN
SELECT 
	convert(Date,getdate()) as [Date],
	FacilityName,
	SUM(SOHQty * UnitCost) as DollarsOnHand,
	LocationID,
	LocationID as LocationName
into bluebin.FactWHHistory
FROM bluebin.DimWarehouseItem
GROUP BY
	FacilityName,
	LocationID
GOTO THEEND 
END
ELSE
	BEGIN
		if exists(select * from bluebin.FactWHHistory where [Date] = convert(Date,getdate()))
		BEGIN
		delete from bluebin.FactWHHistory where [Date] = convert(Date,getdate())
		
		INSERT INTO bluebin.FactWHHistory 
			SELECT 
			convert(Date,getdate()) as [Date],
			FacilityName,
			SUM(SOHQty * UnitCost) as DollarsOnHand,
			LocationID,
			LocationID as LocationName

			FROM bluebin.DimWarehouseItem
			GROUP BY
			FacilityName,
			LocationID 
		END
		ELSE
			BEGIN
			INSERT INTO bluebin.FactWHHistory 
				SELECT 
				convert(Date,getdate()) as [Date],
				FacilityName,
				SUM(SOHQty * UnitCost) as DollarsOnHand,
				LocationID,
				LocationID as LocationName

				FROM bluebin.DimWarehouseItem
				GROUP BY
				FacilityName,
				LocationID 
			END
	END

THEEND:
END
GO

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'FactWHHistory'
GO

--exec etl_FactWHHistory
--select * from bluebin.FactWHHistory
--delete from bluebin.FactWHHistory
--drop table bluebin.FactWHHistory
--update bluebin.FactWHHistory set DollarsOnHand = '1.00'








