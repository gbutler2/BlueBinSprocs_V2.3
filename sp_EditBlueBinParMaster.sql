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
