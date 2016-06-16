
if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertScanLineReceive') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertScanLineReceive
GO

/* 
exec sp_InsertScanLineReceive 16,'0000014','1'
exec sp_InsertScanLineReceive 16,'0000017','1'
exec sp_InsertScanLineReceive 16,'0000018','1'

select * from scan.ScanLine where Line = 0
*/

CREATE PROCEDURE sp_InsertScanLineReceive
@ScanBatchID int,
@Item varchar(30),
@Qty int

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

if exists (select * from bluebin.DimItem where ItemID = @Item) 
BEGIN
insert into scan.ScanLine (ScanBatchID,Line,ItemID,Qty,Active,ScanDateTime,Extracted)
	select 
	@ScanBatchID,
	0,--Default Received Line to 0
	@Item,
	@Qty,
	1,--Active Default to Yes
	getdate(),
	0 --Extracted default to No, will not extract this.
END
	ELSE
	BEGIN
	SELECT -1 -- Back out scan if there is an issue with the Item existing
	delete from scan.ScanLine where ScanBatchID = @ScanBatchID
	delete from scan.ScanBatch where ScanBatchID = @ScanBatchID
	END

END
GO
grant exec on sp_InsertScanLineReceive to public
GO
