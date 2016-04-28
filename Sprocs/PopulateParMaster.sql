


USE [DemoV22]
GO

INSERT INTO [bluebin].[BlueBinFacility] ([FacilityID],[FacilityName],[LastUpdated])
     VALUES (1,'Demo',getdate())
GO

USE [DemoV22]
GO

select * from bluebin.BlueBinFacility

select top 10* from MHS.dbo.APCOMPANY where COMPANY in (3,6,1,19)
INSERT INTO [bluebin].[BlueBinFacility] ([FacilityID],[FacilityName],[LastUpdated])
     VALUES 
	 (1,'Demo',getdate()),
	 (1,'Demo',getdate()),
	 (1,'Demo',getdate()),
	 (1,'Demo',getdate())
GO



USE [Caldwell]
GO

INSERT INTO [bluebin].[BlueBinItemMaster] ([ItemID],[ItemDescription],[LastUpdated])
select 
distinct ItemID,ItemDescription,getdate() from bluebin.DimItem
GO


USE [Caldwell]
GO

INSERT INTO [bluebin].[BlueBinLocationMaster] ([LocationID],[LocationName],[LastUpdated])
select 
distinct LocationID,LocationName,getdate() from bluebin.DimLocation where BlueBinFlag = 1
GO







USE [Caldwell]
GO

INSERT INTO [bluebin].[BlueBinParMaster]([FacilityID],[LocationID],[ItemID],[BinSequence],[BinUOM],[BinQuantity],[LeadTime],[ItemType],[WHLocationID],[WHSequence],[PatientCharge],[Updated],[LastUpdated])
Select 
(select FacilityID from bluebin.BlueBinFacility where FacilityName = 'Caldwell'),
LocationId,ItemNumber,BinSequence,StockUOM,BinQuantity,LeadTime,ItemType,ItemType,'',0,1,getdate()
from ParMaster
GO


USE [DemoV22]
GO

INSERT INTO [bluebin].[BlueBinParMaster]([FacilityID],[LocationID],[ItemID],[BinSequence],[BinUOM],[BinQuantity],[LeadTime],[ItemType],[WHLocationID],[WHSequence],[PatientCharge],[Updated],[LastUpdated])
Select 
1,
LocationID,ItemID,BinSequence,BinUOM,BinQty,BinLeadTime,'','STORE','',0,1,getdate()
from bluebin.DimBin
GO

select * from bluebin.DimBin

select top 10* from ITEMLOC
select top 20* from APCOMPANY


