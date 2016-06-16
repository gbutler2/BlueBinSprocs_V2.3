if exists (select * from dbo.sysobjects where id = object_id(N'xp_RQ500ScanBatchS') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure xp_RQ500ScanBatchS
GO

--exec xp_RQ500ScanBatchS ''

CREATE PROCEDURE xp_RQ500ScanBatchS
@Facility varchar(4)
--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

--If there is nothing to extract skip to the end
if not exists(select * from scan.ScanBatch where Extracted = 0) 
BEGIN
GOTO THEEND
END

--Declare all paramters and parameter table
Declare @RQ500User varchar(100), @RQ500FromLoc varchar(5), @RQ500FromComp varchar(5), @RQ500Account varchar(6), @RQ500SubAccount varchar(4), @RQ500AccountCat varchar(5), @RQ500AccountUnit varchar(15)
DECLARE @Batch TABLE (iid int identity (1,1) PRIMARY KEY,ScanBatchID int,FacilityID int,LocationID char(7),RQ500User varchar(100),Extracted int,ScanDateTime datetime,RQ500FromLoc varchar(5),RQ500FromComp varchar(4))
declare @iid int, @ScanBatchID int

--Set The REQUESTER for the batch to be a generic value in bluebin.Config if set
select @RQ500User = ConfigValue from bluebin.Config where ConfigName = 'RQ500User'
--Set the From Location for the requisition
select @RQ500FromLoc = ConfigValue from bluebin.Config where ConfigName = 'RQ500FromLoc'
--Set Company that is the source of the items.
select @RQ500FromComp = ConfigValue from bluebin.Config where ConfigName = 'RQ500FromComp'

--Set The Account for the GL for the PO
select @RQ500Account = ConfigValue from bluebin.Config where ConfigName = 'RQ500Account'
--Set the Account Category code (used for reporting on ERP)
select @RQ500AccountCat = ConfigValue from bluebin.Config where ConfigName = 'RQ500AccountCat'
--Set the Posting Account Unit
select @RQ500AccountUnit = ConfigValue from bluebin.Config where ConfigName = 'RQ500AccountUnit'
--Set the Sub Account for the general ledger for the req
select @RQ500SubAccount = ConfigValue from bluebin.Config where ConfigName = 'RQ500SubAccount'


--Create data set of all the Batches that need to be extracted
insert into @Batch (ScanBatchID,FacilityID,LocationID,RQ500User,Extracted,ScanDateTime,RQ500FromLoc,RQ500FromComp) 
select 
	sb.ScanBatchID,
	sb.FacilityID,
	--sb.LocationID,  --Used for real Sprocs
	REPLACE(sb.LocationID,'BB','DS') as LocationID,--Used for Testing in Demo
	case 
		when bu.ERPUser = '' or bu.ERPUser is null then 
			case when @RQ500User = '' or @RQ500User is null then 'Invalid Requester' else @RQ500User end 
			else bu.ERPUser end
			,
	sb.Extracted,
	ScanDateTime,
	@RQ500FromLoc,
	@RQ500FromComp
from scan.ScanBatch sb
	left join bluebin.BlueBinUser bu on sb.BlueBinUserID = bu.BlueBinUserID 
where sb.Extracted = 0 and ScanType = 'Order'
		and sb.ScanBatchID in (select ScanBatchID from scan.ScanLine where Extracted = 0)
			and convert(varchar(4),FacilityID) like '%' + @Facility + '%'

;
	
	--Create RQ500 Header out of the ScanBatch
With C as (
	select 
	sb.ScanBatchID,1 as Line,
	left((
	'H'+																		--Record Type 1, 1
	right((REPLICATE('0',4) + rtrim(convert(varchar(4),sb.FacilityID))),4)+		--Company 4, 2-5
	REPLICATE('0',7)+															--Req Number 7, 6-12
	REPLICATE('0',6)+															--LineNumber 6, 13-18
	left(sb.RQ500User+SPACE(10),10)+											--Requester 10, 19-28
	left(sb.LocationID+SPACE(5),5)+												--Req Location 5, 29-33
	convert(varchar, sb.ScanDateTime, 112)+										--Req Delete Date 8, 34-41								
	convert(varchar, sb.ScanDateTime, 112)+										--Creation Date 8, 42-49
	right((REPLICATE('0',4) + rtrim(convert(varchar(4),rtrim(sb.RQ500FromComp)))),4)+--From Company 4, 50-53
	left(sb.RQ500FromLoc+SPACE(5),5)+											--From Location 5, 54-58
	SPACE(76)+																	--76 Spaces, 59-134
	'N'+																		--Print ReqFI  Should we print Req.  Default to N 1, 135
	SPACE(87)+																	--87 Spaces, 136-222
	'01'+																		--Priority 2, 223-224, default it to 01
	SPACE(16)+																	--16 Spaces, 225-240
	left(@RQ500AccountCat+SPACE(5),5)+											--Accounting Category 5, 241-245
	SPACE(32)+																	--32 Spaces, 246-277
	left(@RQ500AccountUnit+SPACE(15),15)+										--Account Unit 15, 278-292
	right((REPLICATE('0',6) + @RQ500Account),6)+								--Account 6, 293-298
	right((REPLICATE('0',4) + @RQ500SubAccount),4)+								--Sub Account 4, 299-302
	SPACE(320)+																	--320 Spaces, 303-622
	'1'+																		--One Source One PO, 1, 623.  default it to 1
	SPACE(115)+																	--115 Spaces, 624-738
	'A'+																		--FUNCTION CODE, 1, 739.  default it to A
	SPACE(503)+																	--503 Spaces, 740-1242
	'00000000'+																	--Default Procedure Date, 8, 1243-1250
	SPACE(382)+																	--382 Spaces, 1251-1632
	'00000000'+																	--Default Birthdate, 8, 1633-1640
	SPACE(2000)																	--Extra Spaces to fill out
	),2000) as Content
	from @Batch sb 
	where sb.RQ500User <> 'Invalid Requester'
	
	UNION

	--Create RQ500 Lines out of the ScanLines
	select 
	sb.ScanBatchID,Line+1 as Line,
	left((
	'L'+																		--Record Type 1, 1
	right((REPLICATE('0',4) + rtrim(convert(varchar(4),sb.FacilityID))),4)+		--Company 4, 2-5
	REPLICATE('0',7)+															--Req Number 7, 6-12 
	right(REPLICATE('0',6)+rtrim(sl.Line),6)+									--LineNumber 6, 13-18
	left(sl.ItemID+SPACE(32),32)+												--Item 32, 19-50
	SPACE(1)+																	--ItemType 1, 51
	SPACE(1)+																	--ServiceCode 1, 52
	SPACE(30)+																	--Service Code Description 30, 53-82
	right(REPLICATE('0',9)+rtrim(sl.Qty),9)+REPLICATE('0',4)+					--Quantity decimal 9,4, overall 13, 83-95
	left(di.StockUOM+SPACE(4),4)+												--Entered UOM 4, 96-99
	REPLICATE('0',18)+															--Transaction Cost, 100-117
	SPACE(56)+																	--Space for Override Cst, 56, 118-173Create PO,Agreement,Vendor,VendorLocation,Purchase Classes,Buyer
	right((REPLICATE('0',4) + rtrim(convert(varchar(4),rtrim(sb.RQ500FromComp)))),4)+		--From Company 4, 174-177
	left(sb.RQ500FromLoc+SPACE(5),5)+												--From Location 5, 178-182
	left(sb.LocationID+SPACE(5),5)+												--Req Location 5, 183-187
	convert(varchar, sb.ScanDateTime, 112)+										--Req Delivery Date 8, 188-195
	convert(varchar, sb.ScanDateTime+1, 112)+									--Late Delivery Date 8, 196-203
	SPACE(8)+																	--Creation Date 8, 204-211
	--convert(varchar, sb.ScanDateTime, 112)+									--Creation Date 8, 204-211
	SPACE(89)+																	--Spaces 89, 212-300
	'01'+																		--Priority 2, 301-302, default it to 01
	SPACE(80)+																	--80 Spaces, 303-382
	left(@RQ500AccountUnit+SPACE(15),15)+										--Account Unit 15, 383-397
	right((REPLICATE('0',6) + @RQ500Account),6)+								--Account 6, 398-403
	right((REPLICATE('0',4) + @RQ500SubAccount),4)+								--Sub Account 4, 404-407
	SPACE(103)+																	--Spaces 103, 408-510
	right((REPLICATE('0',4) + rtrim(convert(varchar(4),rtrim(sb.RQ500FromComp)))),4)+--Distribution (From) Company 4, 511-514
	SPACE(15)+																	--Spaces 15, 515-529
	left(@RQ500AccountCat+SPACE(5),5)+											--Accounting Category 5, 530-534
	SPACE(42)+																	--Spaces 42, 535-576
	'0000000000'+																--Asset Number 10, 577-586 default all zeroes
	SPACE(27)+																	--Spaces 27,587-613
	'0'+																		--Strategic Sourcing Event 1, 614. default to 0
	SPACE(2000)																	--Extra Spaces to fill out	
	),2000) as Content
	from @Batch sb
	inner join scan.ScanLine sl on sb.ScanBatchID = sl.ScanBatchID
	inner join bluebin.DimItem di on sl.ItemID = di.ItemID
	where sl.Extracted = 0 and sb.RQ500User <> 'Invalid Requester' and sl.Line <> 0 
	
	) 
	select Content from C order by ScanBatchID,Line
	;
	update scan.ScanBatch set Extracted = 1 where ScanBatchID in (select ScanBatchID from @Batch where RQ500User <> 'Invalid Requester')
	update scan.ScanLine set Extracted = 1 where ScanBatchID  in (select ScanBatchID from @Batch where RQ500User <> 'Invalid Requester')
THEEND:

/*
select * from scan.ScanBatch
select * from scan.ScanLinereeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeew
select * from bluebin.DimLocation
update scan.ScanBatch set Extracted = 0 where ScanBatchID in (10,11,12)
update scan.ScanLine set Extracted = 0 where ScanBatchID in (10,11,12)
exec xp_RQ500ScanBatchS ''
declare @ScanBatchID int 
select @ScanBatchID = min(ScanBatchID) from scan.ScanBatch where Active = 1 and Extracted = 0
*/

END
GO

grant exec on xp_RQ500ScanBatchS to BlueBin_RQ500User
GO