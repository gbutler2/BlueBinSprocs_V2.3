if exists (select * from dbo.sysobjects where id = object_id(N'tb_ItemLocator') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_ItemLocator
GO

--exec tb_ItemLocator

CREATE PROCEDURE tb_ItemLocator

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
Declare @UseClinicalDescription int
select @UseClinicalDescription = ConfigValue from bluebin.Config where ConfigName = 'UseClinicalDescription'         

SELECT 
	df.FacilityID,
	df.FacilityName,
	Bins.INV_ITEM_ID  as LawsonItemNumber,
	di.ItemManufacturerNumber  as ItemManufacturerNumber,
	di.ItemDescription as ClinicalDescription,
	dl.LocationID as LocationCode,
	dl.LocationName,
	CASE WHEN ISNUMERIC(left(Bins.COMPARTMENT,1))=1 then LEFT(Bins.COMPARTMENT,2) 
				else CASE WHEN Bins.COMPARTMENT LIKE '[A-Z][A-Z]%' THEN LEFT(Bins.COMPARTMENT, 2) ELSE LEFT(Bins.COMPARTMENT, 1) END END as Cart,
			CASE WHEN ISNUMERIC(left(Bins.COMPARTMENT,1))=1 then SUBSTRING(Bins.COMPARTMENT, 3, 1) 
				else CASE WHEN Bins.COMPARTMENT LIKE '[A-Z][A-Z]%' THEN SUBSTRING(Bins.COMPARTMENT, 3, 1) ELSE SUBSTRING(Bins.COMPARTMENT, 2,1) END END as Row,
			CASE WHEN ISNUMERIC(left(Bins.COMPARTMENT,1))=1 then SUBSTRING(Bins.COMPARTMENT, 4, 2)
				else CASE WHEN Bins.COMPARTMENT LIKE '[A-Z][A-Z]%' THEN SUBSTRING (Bins.COMPARTMENT,4,2) ELSE SUBSTRING(Bins.COMPARTMENT, 3,2) END END as Position

FROM   
	(select distinct 
	INV_CART_ID, 
	INV_ITEM_ID,
	--COMPARTMENT,
	case when LEN(COMPARTMENT) < 6 then '' else COMPARTMENT end as COMPARTMENT,
	QTY_OPTIMAL,
	UNIT_OF_MEASURE
	
	 from dbo.CART_TEMPL_INV
	 ) Bins
	          
	  INNER JOIN dbo.CART_ATTRIB_INV Carts
              ON Bins.INV_CART_ID = Carts.INV_CART_ID
		INNER JOIN bluebin.DimLocation dl
              ON Carts.LOCATION COLLATE DATABASE_DEFAULT = dl.LocationID
		--INNER JOIN dbo.BU_ITEMS_INV bu on Bins.INV_ITEM_ID = bu.INV_ITEM_ID
		INNER JOIN bluebin.DimFacility df on dl.LocationFacility = df.FacilityID
		inner join bluebin.DimItem di on Bins.INV_ITEM_ID = di.ItemID
WHERE LEFT(Carts.LOCATION, 2) IN (SELECT [ConfigValue] FROM   [bluebin].[Config] WHERE  [ConfigName] = 'REQ_LOCATION' AND Active = 1) or Carts.LOCATION in (Select REQ_LOCATION from bluebin.ALT_REQ_LOCATION) and Bins.COMPARTMENT <> ''
group by
df.FacilityID,
	df.FacilityName,
	Bins.INV_ITEM_ID,
	di.ItemDescription,
	di.ItemManufacturerNumber,
	dl.LocationID,
	dl.LocationName,
	Bins.COMPARTMENT


END
GO
grant exec on tb_ItemLocator to public
GO