


--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectBlueBinLocationMaster') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectBlueBinLocationMaster
GO

--exec sp_SelectBlueBinLocationMaster 'BB',''
CREATE PROCEDURE sp_SelectBlueBinLocationMaster
@LocationName varchar(255),
@AcctUnit varchar(40)


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

IF exists (select * from sys.tables where name = 'RQLOC')
BEGIN
select
LocationKey,
LocationID,
LocationName,
isnull(gl.ACCT_UNIT,'') as AcctUnit,
isnull(gl.DESCRIPTION,'') as AcctUnitDesc,
case
	when rl.REQ_LOCATION is null then 'No' else 'Yes'
	end as Updated
FROM 
[bluebin].[DimLocation] dl
left join dbo.RQLOC rl on dl.LocationID = rl.REQ_LOCATION
left join dbo.GLNAMES gl on rl.ISS_ACCT_UNIT = gl.ACCT_UNIT and rl.COMPANY = gl.COMPANY
WHERE 
LocationName LIKE '%' + @LocationName + '%' and BlueBinFlag = 1 and isnull(gl.ACCT_UNIT,'') LIKE '%' + @AcctUnit + '%' 
order by LocationID
END
ELSE 
select
LocationKey,
LocationID,
LocationName,
'N/A' as AcctUnit,
'N/A' as AcctUnitDesc,
'Yes' as Updated
FROM 
[bluebin].[DimLocation] dl

WHERE 
LocationName LIKE '%' + @LocationName + '%' and BlueBinFlag = 1  
order by LocationID


END
GO
grant exec on sp_SelectBlueBinLocationMaster to appusers
GO

--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertBlueBinLocationMaster') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertBlueBinLocationMaster
GO

--exec sp_InsertBlueBinLocationMaster 'BB'
CREATE PROCEDURE sp_InsertBlueBinLocationMaster
@LocationID varchar(10),
@LocationName varchar(255)


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
if not exists (select * from bluebin.DimLocation where rtrim(LocationID) = rtrim(@LocationID))
BEGIN
insert [bluebin].[DimLocation] (LocationID,LocationName,LocationFacility,BlueBinFlag)
VALUES (@LocationID,@LocationName,1,1)
END

END
GO
grant exec on sp_InsertBlueBinLocationMaster to appusers
GO



--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_DeleteBlueBinLocationMaster') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_DeleteBlueBinLocationMaster 

GO

--exec sp_DeleteBlueBinLocationMaster 'DN000  '
CREATE PROCEDURE sp_DeleteBlueBinLocationMaster
@LocationKey int

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
delete from [bluebin].[DimLocation]  
where LocationKey = @LocationKey

delete from [bluebin].[BlueBinParMaster]
where LocationID = (select LocationID from [bluebin].[DimLocation] where LocationKey = @LocationKey)
END
GO
grant exec on sp_DeleteBlueBinLocationMaster to appusers
GO

--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_EditBlueBinLocationMaster') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_EditBlueBinLocationMaster
GO

--exec sp_EditBlueBinLocationMaster 'DN000','Testing'
CREATE PROCEDURE sp_EditBlueBinLocationMaster
@LocationKey int,
@LocationID varchar(10),
@LocationName varchar(255)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

update [bluebin].[DimLocation]  
set LocationName=@LocationName
where LocationKey = @LocationKey

END
GO
grant exec on sp_EditBlueBinLocationMaster to appusers
GO



--*****************************************************
--**************************SPROC**********************


if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectBlueBinItemMasterDetail') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectBlueBinItemMasterDetail
GO

--exec sp_SelectBlueBinItemMaster '2601'
CREATE PROCEDURE sp_SelectBlueBinItemMasterDetail
@ItemKey int

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
select 
ItemKey,
[ItemID],
ItemDescription,
ItemClinicalDescription,
ActiveStatus,
ISNULL(ItemManufacturer,'') as ItemManufacturer,
ISNULL(ItemManufacturerNumber,'') as ItemManufacturerNumber,
ISNULL(ItemVendor,'') as ItemVendor,
ISNULL(ItemVendorNumber,'') as ItemVendorNumber,
ISNULL(VendorItemNumber,'') as VendorItemNumber,
LastPODate,
StockUOM,
BuyUOM,
PackageString,
StockLocation
from  [bluebin].[DimItem] 

WHERE ([ItemKey] = @ItemKey)


END
GO
grant exec on sp_SelectBlueBinItemMasterDetail to appusers
GO


--*****************************************************
--**************************SPROC**********************


if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectBlueBinItemMaster') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectBlueBinItemMaster
GO

--exec sp_SelectBlueBinItemMaster '2601'
CREATE PROCEDURE sp_SelectBlueBinItemMaster
@ItemDescription varchar(255),
@Manufacturer varchar(255)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
select
ItemKey,
[ItemID],
ItemDescription,
ItemClinicalDescription,
ActiveStatus,
ISNULL(ItemManufacturer,'') as Manufacturer,
ISNULL(ItemManufacturerNumber,'') as ManufacturerNo,
ISNULL(ItemVendor,'') as Vendor,
ISNULL(ItemVendorNumber,'') as VendorNo,
ISNULL(VendorItemNumber,'') as VendorItemID,
LastPODate,
StockUOM,
BuyUOM,
PackageString,
StockLocation
from  [bluebin].[DimItem]
WHERE 
	rtrim(ItemManufacturerNumber) +' - ' + rtrim(ItemManufacturer) like '%' + @Manufacturer + '%'
	AND
	rtrim(ItemID) +' - ' + rtrim(ItemDescription) like '%' + @ItemDescription + '%'
OR
	rtrim(ItemManufacturerNumber) +' - ' + rtrim(ItemManufacturer) like '%' + @Manufacturer + '%'
	AND
	rtrim(ItemID) +' - ' + rtrim(ItemClinicalDescription) like '%' + @ItemDescription + '%'
order by ItemID

END
GO
grant exec on sp_SelectBlueBinItemMaster to appusers
GO


--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertBlueBinItemMaster') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertBlueBinItemMaster
GO

--exec sp_InsertBlueBinItemMaster '2601'
CREATE PROCEDURE sp_InsertBlueBinItemMaster
@ItemID varchar(32),
@ItemDescription varchar(255),
@ItemClinicalDescription varchar(255),
@ItemManufacturer char(30),
@ItemManufacturerNumber char(35),
@ItemVendor char(30),
@ItemVendorNumber char(9),
@VendorItemNumber char(32),
@StockUOM char(4)




--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

if not exists(select * from bluebin.DimItem where ItemID = @ItemID)
BEGIN
set @ItemManufacturerNumber = isnull(@ItemManufacturerNumber,'None')

insert into [bluebin].[DimItem] (ItemKey,ActiveStatus,[ItemID],ItemDescription,ItemDescription2,ItemClinicalDescription,ItemManufacturer,ItemManufacturerNumber,ItemVendor,ItemVendorNumber,VendorItemNumber,StockUOM)

VALUES ((Select max(ItemKey) + 1 from bluebin.DimItem),'A',rtrim(@ItemID),@ItemDescription,@ItemClinicalDescription,@ItemClinicalDescription,@ItemManufacturer,@ItemManufacturerNumber,@ItemVendor,@ItemVendorNumber,@VendorItemNumber,@StockUOM)
END

END
GO
grant exec on sp_InsertBlueBinItemMaster to appusers
GO


--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_DeleteBlueBinItemMaster') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_DeleteBlueBinItemMaster
GO

--exec sp_DeleteBlueBinItemMaster '2601'
CREATE PROCEDURE sp_DeleteBlueBinItemMaster
@ItemKey int

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
delete from [bluebin].[DimItem] 

where ItemKey = @ItemKey


END
GO
grant exec on sp_DeleteBlueBinItemMaster to appusers
GO



--*****************************************************
--**************************SPROC**********************


if exists (select * from dbo.sysobjects where id = object_id(N'sp_EditBlueBinItemMaster') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_EditBlueBinItemMaster
GO

--exec sp_EditBlueBinItemMaster '0000001','Test','Test2'
CREATE PROCEDURE sp_EditBlueBinItemMaster
@ItemKey int,
@ItemID varchar(32),
@ItemDescription varchar(255),
@ItemClinicalDescription varchar(255),
@ItemManufacturer char(30),
@ItemManufacturerNumber char(35),
@ItemVendor char(30),
@ItemVendorNumber char(9),
@VendorItemNumber char(32),
@StockUOM char(4),
@ActiveStatus char(1),
@BuyUOM char(4),
@PackageString varchar(38),
@StockLocation char(7)


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

update [bluebin].[DimItem] 
set 
ItemDescription = @ItemDescription,
ItemClinicalDescription = @ItemClinicalDescription,
ItemManufacturer = @ItemManufacturer,
ItemManufacturerNumber = @ItemManufacturerNumber,
ItemVendor = @ItemVendor,
ItemVendorNumber = @ItemVendorNumber,
VendorItemNumber = @VendorItemNumber,
StockUOM = @StockUOM,
ActiveStatus = @ActiveStatus,
BuyUOM=@BuyUOM,
PackageString=@PackageString,
StockLocation=@StockLocation

where ItemKey = @ItemKey


END
GO
grant exec on sp_EditBlueBinItemMaster to appusers
GO


--*****************************************************
--**************************SPROC**********************


if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectBlueBinParMaster') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectBlueBinParMaster
GO

--exec sp_SelectBlueBinParMaster '','','17'
CREATE PROCEDURE sp_SelectBlueBinParMaster
@FacilityName varchar(255)
,@LocationName varchar(255)
,@ItemDescription varchar(255)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON


select
bbpm.[ParMasterID],
bbpm.[FacilityID],
bbf.[FacilityName],
rtrim(bbpm.[LocationID]) as LocationID,
ISNULL((rtrim(bblm.[LocationName])),'') as LocationName,
rtrim(bbpm.[ItemID]) as ItemID,
ISNULL((COALESCE(bbim.ItemClinicalDescription,bbim.ItemDescription,'None')),'') as ItemDescription,
bbpm.[BinSequence],
bbpm.[BinSize],
bbpm.[BinUOM],
bbpm.[BinQuantity],
bbpm.[LeadTime],
bbpm.[ItemType],
isnull(bbim.VendorItemNumber,'') as VendorItemNumber,
bbpm.[WHSequence],
bbpm.[PatientCharge],
case when bbpm.[PatientCharge] = 1 then 'Yes' else 'No' end as PatientChargeName,
case when bbpm.[Updated] = '1' then 'Yes' else 'No' end as Updated,
bbpm.[LastUpdated]
from [bluebin].[BlueBinParMaster] bbpm
	inner join [bluebin].[DimItem] bbim on rtrim(bbpm.ItemID) = rtrim(bbim.ItemID)
		inner join [bluebin].[DimLocation] bblm on rtrim(bbpm.LocationID) = rtrim(bblm.LocationID) and bblm.BlueBinFlag = 1
			inner join bluebin.DimFacility bbf on rtrim(bbpm.FacilityID) = rtrim(bbf.FacilityID)
				
				
WHERE 
rtrim(bblm.LocationName) LIKE '%' + @LocationName + '%' 
		and bbf.FacilityName LIKE '%' + @FacilityName + '%' 
			and (rtrim(bbim.ItemID) +' - ' + rtrim(bbim.ItemDescription) like '%' + @ItemDescription + '%'
					OR
						rtrim(bbim.ItemID) +' - ' + rtrim(bbim.ItemClinicalDescription) like '%' + @ItemDescription + '%')
order by LocationID,ItemID

END
GO
grant exec on sp_SelectBlueBinParMaster to appusers
GO

--*****************************************************
--**************************SPROC**********************


if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertBlueBinParMaster') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertBlueBinParMaster
GO

--exec sp_InsertBlueBinParMaster '','',''
CREATE PROCEDURE sp_InsertBlueBinParMaster
@FacilityID int
,@LocationID varchar(10)
,@ItemID varchar(32)
,@BinSequence varchar(50)
,@BinUOM varchar(10)
,@BinQuantity int
,@LeadTime int
,@ItemType varchar(10)
,@WHSequence varchar(50)
,@PatientCharge int

--& txtFacilityName & "','" & txtLocationName & "','" & txtItemDescription & "','" & txtItemDescription & "','" & txtBinSequence & "','" & txtBinUOM & "','" & txtBinQuantity & "','" & txtLeadTime & "','" & txtItemType & "','" & txtWHLocationID & "','" & txtWHSequence & "','" & txtPatientCharge & "'"
--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
if not exists(select * from [bluebin].[BlueBinParMaster] WHERE rtrim(LocationID) = rtrim(@LocationID) and rtrim(ItemID) = rtrim(@ItemID) and FacilityID = @FacilityID)
BEGIN

declare @BinSize varchar(5) = right(@BinSequence,3)
insert [bluebin].[BlueBinParMaster] (FacilityID,LocationID,ItemID,BinSequence,BinSize,BinUOM,BinQuantity,LeadTime,ItemType,WHLocationID,WHSequence,PatientCharge,Updated,LastUpdated)
VALUES(
@FacilityID,
@LocationID,
@ItemID,
@BinSequence,
@BinSize,
@BinUOM,
@BinQuantity,
@LeadTime,
@ItemType,
'',
@WHSequence,
@PatientCharge,
0,
getdate()

) 
END


END
GO
grant exec on sp_InsertBlueBinParMaster to appusers
GO

--*****************************************************
--**************************SPROC**********************


if exists (select * from dbo.sysobjects where id = object_id(N'sp_DeleteBlueBinParMaster') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_DeleteBlueBinParMaster
GO

--exec sp_DeleteBlueBinParMaster '','',''
CREATE PROCEDURE sp_DeleteBlueBinParMaster
@ParMasterID int
--@FacilityID int
--,@LocationID varchar(10)
--,@ItemID varchar(32)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
delete from [bluebin].[BlueBinParMaster] 
WHERE ParMasterID = @ParMasterID 
--WHERE rtrim(LocationID) = rtrim(@LocationID)
--	and rtrim(ItemID) = rtrim(@ItemID)
--		and FacilityID = @FacilityID 


END
GO
grant exec on sp_DeleteBlueBinParMaster to appusers
GO

--*****************************************************
--**************************SPROC**********************


if exists (select * from dbo.sysobjects where id = object_id(N'sp_EditBlueBinParMaster') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_EditBlueBinParMaster
GO

--exec sp_EditBlueBinParMaster '','',''
CREATE PROCEDURE sp_EditBlueBinParMaster
@ParMasterID int
,@FacilityID int
,@LocationID varchar(10)
,@ItemID varchar(32)
, @BinSequence varchar(15)
,@BinUOM varchar(10)
,@BinQuantity decimal(13,4)
,@LeadTime int
,@ItemType varchar(20)
,@WHSequence varchar(50)
,@PatientCharge int

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
update [bluebin].[BlueBinParMaster] 
set BinSequence = @BinSequence,
	BinSize = right(@BinSequence,3),
	BinUOM = @BinUOM,
	BinQuantity = @BinQuantity,
	LeadTime = @LeadTime,
	ItemType = @ItemType,
	WHSequence = @WHSequence,
	PatientCharge = @PatientCharge,
	LastUpdated = getdate()
	WHERE ParMasterID = @ParMasterID
--WHERE rtrim(LocationID) = rtrim(@LocationID)
--	and rtrim(ItemID) = rtrim(@ItemID)
--		and FacilityID = @FacilityID 


END
GO
grant exec on sp_EditBlueBinParMaster to appusers
GO
