USE [msdb]
GO

/****** Object:  Job [BlueBinETL_Demo]    Script Date: 2/8/2016 9:11:50 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 2/8/2016 9:11:50 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'BlueBinETL_Demo', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'bluebindba', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Demo - Copy MHS Data to Demo]    Script Date: 2/8/2016 9:11:51 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Demo - Copy MHS Data to Demo', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
truncate table dbo.APCOMPANY
truncate table dbo.APVENMAST
truncate table dbo.BUYER
truncate table dbo.GLCHARTDTL
truncate table dbo.GLNAMES
truncate table dbo.GLTRANS
truncate table dbo.ICCATEGORY
truncate table dbo.ICMANFCODE
truncate table dbo.ICTRANS
truncate table dbo.ICLOCATION
truncate table dbo.ITEMLOC
truncate table dbo.ITEMMAST
truncate table dbo.ITEMSRC
truncate table dbo.MAINVDTL
truncate table dbo.MAINVMSG
truncate table dbo.MMDIST
truncate table dbo.POCODE
truncate table dbo.POLINE
truncate table dbo.POLINESRC
truncate table dbo.PORECLINE
truncate table dbo.POVAGRMTLN
truncate table dbo.PURCHORDER
truncate table dbo.REQHEADER
truncate table dbo.REQLINE
truncate table dbo.REQUESTER
truncate table dbo.RQLOC


insert into [Demo].[dbo].[APCOMPANY] Select * from [MHS].[dbo].[APCOMPANY]
insert into [Demo].[dbo].[APVENMAST] Select * from [MHS].[dbo].[APVENMAST]
insert into [Demo].[dbo].[BUYER] Select * from [MHS].[dbo].[BUYER]
insert into [Demo].[dbo].[GLCHARTDTL] Select * from [MHS].[dbo].[GLCHARTDTL]
insert into [Demo].[dbo].[GLNAMES] Select * from [MHS].[dbo].[GLNAMES]
insert into [Demo].[dbo].[GLTRANS] Select * from [MHS].[dbo].[GLTRANS]
insert into [Demo].[dbo].[ICCATEGORY] Select * from [MHS].[dbo].[ICCATEGORY]
insert into [Demo].[dbo].[ICMANFCODE] Select * from [MHS].[dbo].[ICMANFCODE]
insert into [Demo].[dbo].[ICLOCATION] Select * from [MHS].[dbo].[ICLOCATION]
insert into [Demo].[dbo].[ICTRANS]
	(COMPANY,LOCATION,DOC_TYPE,SYSTEM_CD,DOCUMENT,SHIPMENT_NBR,LINE_NBR,COMPONENT_SEQ,TRANS_DATE,ITEM,SOH_QTY,QUANTITY,TRAN_UOM,TRAN_UOM_MULT,UNIT_COST,FROM_TO_LOC,ACTUAL_TIME,FROM_TO_CMPY) 
	Select COMPANY,LOCATION,DOC_TYPE,SYSTEM_CD,DOCUMENT,SHIPMENT_NBR,LINE_NBR,COMPONENT_SEQ,TRANS_DATE,ITEM,SOH_QTY,QUANTITY,TRAN_UOM,TRAN_UOM_MULT,UNIT_COST,FROM_TO_LOC,ACTUAL_TIME,FROM_TO_CMPY
	 from [MHS].[dbo].[ICTRANS] 
insert into [Demo].[dbo].[ITEMLOC] Select * from [MHS].[dbo].[ITEMLOC]
insert into [Demo].[dbo].[ITEMMAST] Select * from [MHS].[dbo].[ITEMMAST]
insert into [Demo].[dbo].[ITEMSRC] Select * from [MHS].[dbo].[ITEMSRC]
insert into [Demo].[dbo].[MAINVDTL] Select * from [MHS].[dbo].[MAINVDTL]
insert into [Demo].[dbo].[MAINVMSG] Select * from [MHS].[dbo].[MAINVMSG]
insert into [Demo].[dbo].[MMDIST] Select * from [MHS].[dbo].[MMDIST]
insert into [Demo].[dbo].[POCODE] Select * from [MHS].[dbo].[POCODE]
insert into [Demo].[dbo].[POLINE] Select * from [MHS].[dbo].[POLINE]
insert into [Demo].[dbo].[POLINESRC] Select * from [MHS].[dbo].[POLINESRC]
insert into [Demo].[dbo].[PORECLINE] Select * from [MHS].[dbo].[PORECLINE]
insert into [Demo].[dbo].[POVAGRMTLN] Select * from [MHS].[dbo].[POVAGRMTLN]
insert into [Demo].[dbo].[PURCHORDER] Select * from [MHS].[dbo].[PURCHORDER]
insert into [Demo].[dbo].[REQHEADER] Select * from [MHS].[dbo].[REQHEADER]
insert into [Demo].[dbo].[REQLINE] Select * from [MHS].[dbo].[REQLINE]
insert into [Demo].[dbo].[REQUESTER] Select * from [MHS].[dbo].[REQUESTER]
insert into [Demo].[dbo].[RQLOC] Select * from [MHS].[dbo].[RQLOC]

', 
		@database_name=N'Demo', 
		@flags=4
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Demo - Alter source tables from DS to BB]    Script Date: 2/8/2016 9:11:51 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Demo - Alter source tables from DS to BB', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'update bluebin.Config set ConfigValue = ''BB'' where ConfigName = ''REQ_LOCATION''
Update ICCATEGORY set LOCATION = REPLACE(LOCATION,''DS'',''BB'')
Update ICLOCATION set LOCATION = REPLACE(LOCATION,''DS'',''BB'')
Update ICTRANS set LOCATION = REPLACE(LOCATION,''DS'',''BB''), FROM_TO_LOC = REPLACE(FROM_TO_LOC,''DS'',''BB'')

Update ICLOCATION set NAME = REPLACE(NAME,''DS '',''BB '')
Update ITEMLOC set LOCATION = REPLACE(LOCATION,''DS'',''BB'')
Update ITEMSRC set LOCATION = REPLACE(LOCATION,''DS'',''BB'')
Update MAINVDTL set LOCATION = REPLACE(LOCATION,''DS'',''BB'')
Update MMDIST set REQ_LOCATION = REPLACE(REQ_LOCATION,''DS'',''BB'')
--Update MMDIST set LOCATION = REPLACE(LOCATION,''DS'',''BB'')
Update POLINE set LOCATION = REPLACE(LOCATION,''DS'',''BB'')
Update POLINESRC set REQ_LOCATION = REPLACE(REQ_LOCATION,''DS'',''BB'')
Update REQLINE set REQ_LOCATION = REPLACE(REQ_LOCATION,''DS'',''BB'')
Update RQLOC set REQ_LOCATION = REPLACE(REQ_LOCATION,''DS'',''BB''),NAME = REPLACE(NAME,''DS '',''BB '')', 
		@database_name=N'Demo', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Demo - etl_RefreshDashboardData]    Script Date: 2/8/2016 9:11:51 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Demo - etl_RefreshDashboardData', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [Demo]

GO

DECLARE	@return_value int

EXEC	@return_value = [dbo].[etl_RefreshDashboardData]

SELECT	''Return Value'' = @return_value

GO

', 
		@database_name=N'Demo', 
		@flags=4
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Demo - Delete greater than 90 days (keep it small)]    Script Date: 2/8/2016 9:11:52 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Demo - Delete greater than 90 days (keep it small)', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'delete from [tableau].[Kanban] where [Date] < getdate() -90

', 
		@database_name=N'Demo', 
		@flags=4
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Reduce # of stockouts to keep fill rate high]    Script Date: 2/8/2016 9:11:52 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Reduce # of stockouts to keep fill rate high', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'update tableau.Kanban set StockOut = 0 where BinKey in (Select BinKey from tableau.Kanban where BinKey not in (select top 150 BinKey from tableau.Kanban where BinSnapshotDate > getdate() -30 and StockOut = 1 and ScanHistseq > 1)
and BinSnapshotDate > getdate() -30 and StockOut = 1 and ScanHistseq > 1)
and BinSnapshotDate > getdate() -30 and StockOut = 1 and ScanHistseq > 1', 
		@database_name=N'Demo', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Create dummy Locations for Main dashbaord]    Script Date: 2/8/2016 9:11:52 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Create dummy Locations for Main dashbaord', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'INSERT INTO [tableau].[Kanban]
select (select ((max(BinKey))+1) from bluebin.DimBin [BinKey]),''DN005'',[ItemID],[BinSequence],[BinUOM],[BinQty],[BinCurrentCost] ,[BinGLAccount],[BinConsignmentFlag],[BinLeadTime],[BinGoLiveDate],[BinCurrentStatus],[Date],[ScanHistseq],[ItemType],[OrderNum],[LineNum] ,[OrderUOM],[OrderQty],[OrderDate],[OrderCloseDate] ,[PrevOrderDate],[PrevOrderCloseDate],0 ,0,0,[BinSnapshotDate],[LastScannedDate],[DaysSinceLastScan],[ScanSinThreshold],[HotScanSinThreshold],[StockOutSinThreshold],[StockOutsDaily],[TimeToFill],[BinVelocity],[BinStatus],[ItemDescription] ,[ItemClinicalDescription],[ItemManufacturer],[ItemManufacturerNumber],[ItemVendor],[ItemVendorNumber],REPLACE([LocationName],''BB'',''DN''),[TotalBins]
from [tableau].[Kanban] where LocationID = ''BB005'' and ItemID = ''0005240'' and [BinSnapshotDate] = (select max(BinSnapshotDate) from tableau.Kanban)
INSERT INTO [tableau].[Kanban]
select (select ((max(BinKey))+2) from bluebin.DimBin [BinKey]),''DT005'',[ItemID],[BinSequence],[BinUOM],[BinQty],[BinCurrentCost] ,[BinGLAccount],[BinConsignmentFlag],[BinLeadTime],[BinGoLiveDate],[BinCurrentStatus],[Date],[ScanHistseq],[ItemType],[OrderNum],[LineNum] ,[OrderUOM],[OrderQty],[OrderDate],[OrderCloseDate] ,[PrevOrderDate],[PrevOrderCloseDate],0 ,0,0,[BinSnapshotDate],[LastScannedDate],[DaysSinceLastScan],[ScanSinThreshold],[HotScanSinThreshold],[StockOutSinThreshold],[StockOutsDaily],[TimeToFill],[BinVelocity],[BinStatus],[ItemDescription] ,[ItemClinicalDescription],[ItemManufacturer],[ItemManufacturerNumber],[ItemVendor],[ItemVendorNumber],REPLACE([LocationName],''BB'',''DT''),[TotalBins]
from [tableau].[Kanban] where LocationID = ''BB005'' and ItemID = ''0005240'' and [BinSnapshotDate] = (select max(BinSnapshotDate) from tableau.Kanban)
INSERT INTO [tableau].[Kanban]
select (select ((max(BinKey))+3) from bluebin.DimBin [BinKey]),''DS005'',[ItemID],[BinSequence],[BinUOM],[BinQty],[BinCurrentCost] ,[BinGLAccount],[BinConsignmentFlag],[BinLeadTime],[BinGoLiveDate],[BinCurrentStatus],[Date],[ScanHistseq],[ItemType],[OrderNum],[LineNum] ,[OrderUOM],[OrderQty],[OrderDate],[OrderCloseDate] ,[PrevOrderDate],[PrevOrderCloseDate],0 ,0,0,[BinSnapshotDate],[LastScannedDate],[DaysSinceLastScan],[ScanSinThreshold],[HotScanSinThreshold],[StockOutSinThreshold],[StockOutsDaily],[TimeToFill],[BinVelocity],[BinStatus],[ItemDescription] ,[ItemClinicalDescription],[ItemManufacturer],[ItemManufacturerNumber],[ItemVendor],[ItemVendorNumber],REPLACE([LocationName],''BB'',''DS''),[TotalBins]
from [tableau].[Kanban] where LocationID = ''BB005'' and ItemID = ''0005240'' and [BinSnapshotDate] = (select max(BinSnapshotDate) from tableau.Kanban)', 
		@database_name=N'Demo', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Demo - Create DimBin entries for missing items]    Script Date: 2/8/2016 9:11:52 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Demo - Create DimBin entries for missing items', 
		@step_id=7, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'declare @BinKey int 
set @BinKey = (select Max(BinKey)+1 from bluebin.DimBin)
declare @LocationID char(5) = ''BB003''
insert into bluebin.DimBin select @BinKey,BinFacility,ItemID,@LocationID,BinSequence,BinCart,BinRow,BinPosition,BinSize,BinUOM,BinQty,BinLeadTime,BinGoLiveDate,BinCurrentCost,BinConsignmentFlag,BinGLAccount,BinCurrentStatus
 from bluebin.DimBin where BinKey in (''1'',''2'',''3'',''4'',''5'',''6'',''7'',''8'')

set @BinKey = @BinKey+1
set @LocationID = ''BB004''
insert into bluebin.DimBin select @BinKey,BinFacility,ItemID,@LocationID,BinSequence,BinCart,BinRow,BinPosition,BinSize,BinUOM,BinQty,BinLeadTime,BinGoLiveDate,BinCurrentCost,BinConsignmentFlag,BinGLAccount,BinCurrentStatus
 from bluebin.DimBin where BinKey in (''1'',''2'',''3'',''4'',''5'',''6'',''7'',''8'')

set @BinKey = @BinKey+1
set @LocationID = ''BB009''
insert into bluebin.DimBin select @BinKey,BinFacility,ItemID,@LocationID,BinSequence,BinCart,BinRow,BinPosition,BinSize,BinUOM,BinQty,BinLeadTime,BinGoLiveDate,BinCurrentCost,BinConsignmentFlag,BinGLAccount,BinCurrentStatus
 from bluebin.DimBin where BinKey in (''1'',''2'',''3'',''4'',''5'',''6'',''7'',''8'')

set @BinKey = @BinKey+1
set @LocationID = ''BB010''
insert into bluebin.DimBin select @BinKey,BinFacility,ItemID,@LocationID,BinSequence,BinCart,BinRow,BinPosition,BinSize,BinUOM,BinQty,BinLeadTime,BinGoLiveDate,BinCurrentCost,BinConsignmentFlag,BinGLAccount,BinCurrentStatus
 from bluebin.DimBin where BinKey in (''1'',''2'',''3'',''4'',''5'',''6'',''7'',''8'')

set @BinKey = @BinKey+1
set @LocationID = ''BB014''
insert into bluebin.DimBin select @BinKey,BinFacility,ItemID,@LocationID,BinSequence,BinCart,BinRow,BinPosition,BinSize,BinUOM,BinQty,BinLeadTime,BinGoLiveDate,BinCurrentCost,BinConsignmentFlag,BinGLAccount,BinCurrentStatus
 from bluebin.DimBin where BinKey in (''1'',''2'',''3'',''4'',''5'',''6'',''7'',''8'')

set @BinKey = @BinKey+1
set @LocationID = ''BB015''
insert into bluebin.DimBin select @BinKey,BinFacility,ItemID,@LocationID,BinSequence,BinCart,BinRow,BinPosition,BinSize,BinUOM,BinQty,BinLeadTime,BinGoLiveDate,BinCurrentCost,BinConsignmentFlag,BinGLAccount,BinCurrentStatus
 from bluebin.DimBin where BinKey in (''1'',''2'',''3'',''4'',''5'',''6'',''7'',''8'')

set @BinKey = @BinKey+1
set @LocationID = ''BB017''
insert into bluebin.DimBin select @BinKey,BinFacility,ItemID,@LocationID,BinSequence,BinCart,BinRow,BinPosition,BinSize,BinUOM,BinQty,BinLeadTime,BinGoLiveDate,BinCurrentCost,BinConsignmentFlag,BinGLAccount,BinCurrentStatus
 from bluebin.DimBin where BinKey in (''1'',''2'',''3'',''4'',''5'',''6'',''7'',''8'')

set @BinKey = @BinKey+1
set @LocationID = ''BB018''
insert into bluebin.DimBin select @BinKey,BinFacility,ItemID,@LocationID,BinSequence,BinCart,BinRow,BinPosition,BinSize,BinUOM,BinQty,BinLeadTime,BinGoLiveDate,BinCurrentCost,BinConsignmentFlag,BinGLAccount,BinCurrentStatus
 from bluebin.DimBin where BinKey in (''1'',''2'',''3'',''4'',''5'',''6'',''7'',''8'')

set @BinKey = @BinKey+1
set @LocationID = ''BB021''
insert into bluebin.DimBin select @BinKey,BinFacility,ItemID,@LocationID,BinSequence,BinCart,BinRow,BinPosition,BinSize,BinUOM,BinQty,BinLeadTime,BinGoLiveDate,BinCurrentCost,BinConsignmentFlag,BinGLAccount,BinCurrentStatus
 from bluebin.DimBin where BinKey in (''1'',''2'',''3'',''4'',''5'',''6'',''7'',''8'')

set @BinKey = @BinKey+1
set @LocationID = ''BB022''
insert into bluebin.DimBin select @BinKey,BinFacility,ItemID,@LocationID,BinSequence,BinCart,BinRow,BinPosition,BinSize,BinUOM,BinQty,BinLeadTime,BinGoLiveDate,BinCurrentCost,BinConsignmentFlag,BinGLAccount,BinCurrentStatus
 from bluebin.DimBin where BinKey in (''1'',''2'',''3'',''4'',''5'',''6'',''7'',''8'')

set @BinKey = @BinKey+1
set @LocationID = ''BB023''
insert into bluebin.DimBin select @BinKey,BinFacility,ItemID,@LocationID,BinSequence,BinCart,BinRow,BinPosition,BinSize,BinUOM,BinQty,BinLeadTime,BinGoLiveDate,BinCurrentCost,BinConsignmentFlag,BinGLAccount,BinCurrentStatus
 from bluebin.DimBin where BinKey in (''1'',''2'',''3'',''4'',''5'',''6'',''7'',''8'')

set @BinKey = @BinKey+1
set @LocationID = ''BB024''
insert into bluebin.DimBin select @BinKey,BinFacility,ItemID,@LocationID,BinSequence,BinCart,BinRow,BinPosition,BinSize,BinUOM,BinQty,BinLeadTime,BinGoLiveDate,BinCurrentCost,BinConsignmentFlag,BinGLAccount,BinCurrentStatus
 from bluebin.DimBin where BinKey in (''1'',''2'',''3'',''4'',''5'',''6'',''7'',''8'')

set @BinKey = @BinKey+1
set @LocationID = ''BB025''
insert into bluebin.DimBin select @BinKey,BinFacility,ItemID,@LocationID,BinSequence,BinCart,BinRow,BinPosition,BinSize,BinUOM,BinQty,BinLeadTime,BinGoLiveDate,BinCurrentCost,BinConsignmentFlag,BinGLAccount,BinCurrentStatus
 from bluebin.DimBin where BinKey in (''1'',''2'',''3'',''4'',''5'',''6'',''7'',''8'')

set @BinKey = @BinKey+1
set @LocationID = ''BB026''
insert into bluebin.DimBin select @BinKey,BinFacility,ItemID,@LocationID,BinSequence,BinCart,BinRow,BinPosition,BinSize,BinUOM,BinQty,BinLeadTime,BinGoLiveDate,BinCurrentCost,BinConsignmentFlag,BinGLAccount,BinCurrentStatus
 from bluebin.DimBin where BinKey in (''1'',''2'',''3'',''4'',''5'',''6'',''7'',''8'')

set @BinKey = @BinKey+1
set @LocationID = ''BB027''
insert into bluebin.DimBin select @BinKey,BinFacility,ItemID,@LocationID,BinSequence,BinCart,BinRow,BinPosition,BinSize,BinUOM,BinQty,BinLeadTime,BinGoLiveDate,BinCurrentCost,BinConsignmentFlag,BinGLAccount,BinCurrentStatus
 from bluebin.DimBin where BinKey in (''1'',''2'',''3'',''4'',''5'',''6'',''7'',''8'')
', 
		@database_name=N'Demo', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [INACTIVEDemo - Pare down the database to just DS and change name to BB]    Script Date: 2/8/2016 9:11:52 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'INACTIVEDemo - Pare down the database to just DS and change name to BB', 
		@step_id=8, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
Delete from bluebin.DimBin where LocationID not like ''BB%''
Update bluebin.DimBin set LocationID = REPLACE(LocationID,''DS'',''BB'') 

Update bluebin.DimLocation set LocationID = REPLACE(LocationID,''DS'',''BB'') 
Update bluebin.DimLocation set LocationName = REPLACE(LocationName,''DS '',''BB '')
Delete from bluebin.DimLocation where LocationID not in (Select LocationID from bluebin.DimBin)

Delete from bluebin.DimItem where ItemID not in (select ItemID from bluebin.DimBin) 

Update qcn.QCN set LocationID = REPLACE(LocationID,''DS'',''BB'') 
Update gemba.GembaAuditNode set LocationID = REPLACE(LocationID,''DS'',''BB'') 
Update scan.ScanBatch set LocationID = REPLACE(LocationID,''DS'',''BB'')
Update tableau.Kanban set LocationID = REPLACE(LocationID,''DS'',''BB'')
Update tableau.Kanban set LocationName = REPLACE(LocationName,''DS '',''BB '')
delete from qcn.QCN where LocationID like ''DN%'' or LocationID like ''DT%'' 
delete from gemba.GembaAuditNode where LocationID like ''DN%'' or LocationID like ''DT%'' 
delete from scan.ScanLine where ScanBatchID in (select ScanBatchID from scan.ScanBatch where LocationID like ''DN%'' or LocationID like ''DT%'')
delete from scan.ScanBatch where LocationID like ''DN%'' or LocationID like ''DT%'' 

DELETE t1 
from bluebin.FactBinSnapshot t1
left join bluebin.DimBin t2 on t1.BinKey = t2.BinKey
WHERE t2.BinKey is NULL

DELETE t1 
from bluebin.FactIssue t1
left join bluebin.DimLocation t2 on t1.LocationKey = t2.LocationKey 
WHERE t2.LocationKey is NULL

DELETE t1
from bluebin.FactScan t1
left join bluebin.DimBin t2 on t1.BinKey = t2.BinKey
WHERE t2.BinKey is null

DELETE t1
from tableau.Contracts t1
left join bluebin.DimItem t2 on t1.ItemNumber = t2.ItemID
WHERE t2.ItemID is null

DELETE t1
from tableau.Kanban t1
left join bluebin.DimBin t2 on t1.BinKey = t2.BinKey
WHERE t2.BinKey is null or t1.[Date] < getdate() -90

DELETE t1
select top 10* from tableau.Sourcing t1
left join bluebin.DimLocation t2 on t1.LocationID = t2.LocationID
WHERE t2.LocationID is null', 
		@database_name=N'Demo', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20151001, 
		@active_end_date=99991231, 
		@active_start_time=4000, 
		@active_end_time=235959, 
		@schedule_uid=N'854aae6a-dda1-420b-a30f-60c4937163bb'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


