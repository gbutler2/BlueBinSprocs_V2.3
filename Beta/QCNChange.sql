--QCN Form Change

--add new columns
if not exists(select * from sys.columns where name = 'QCNCID' and object_id = (select object_id from sys.tables where name = 'QCN'))
BEGIN
ALTER TABLE qcn.QCN ADD QCNCID int
END

if not exists(select * from sys.columns where name = 'DateRequested' and object_id = (select object_id from sys.tables where name = 'QCN'))
BEGIN
ALTER TABLE qcn.QCN ADD DateRequested datetime
END

if not exists(select * from sys.columns where name = 'Par' and object_id = (select object_id from sys.tables where name = 'QCN'))
BEGIN
ALTER TABLE qcn.QCN ADD Par int
END

if not exists(select * from sys.columns where name = 'UOM' and object_id = (select object_id from sys.tables where name = 'QCN'))
BEGIN
ALTER TABLE qcn.QCN ADD [UOM] varchar(10);
END
GO

if not exists(select * from sys.columns where name = 'ApprovedBy' and object_id = (select object_id from sys.tables where name = 'QCN'))
BEGIN
ALTER TABLE qcn.QCN ADD [ApprovedBy] varchar(65);
END
GO

if not exists(select * from sys.columns where name = 'LoggedUserID' and object_id = (select object_id from sys.tables where name = 'QCN'))
BEGIN
ALTER TABLE qcn.QCN ADD [LoggedUserID] int;
END
GO

if not exists(select * from sys.columns where name = 'ManuNumName' and object_id = (select object_id from sys.tables where name = 'QCN'))
BEGIN
ALTER TABLE qcn.QCN ADD [ManuNumName] varchar(60);
END
GO

if not exists(select * from sys.columns where name = 'ClinicalDescription' and object_id = (select object_id from sys.tables where name = 'QCN'))
BEGIN
ALTER TABLE qcn.QCN ADD [ClinicalDescription] varchar(255);
END
GO

if not exists(select * from sys.columns where name = 'AssignToQCN' and object_id = (select object_id from sys.tables where name = 'BlueBinUser'))
BEGIN
ALTER TABLE bluebin.BlueBinUser ADD [AssignToQCN] int;
END
GO



--Other alter columns
ALTER TABLE qcn.QCN ALTER COLUMN RequesterUserID varchar(65)

--updating existing values
update qcn.QCN set QCNCID = 2
update qcn.QCN set DateRequested = DateEntered
update qcn.QCN set UOM = 'EA'
update qcn.QCN set RequesterUserID = a.Name from (select BlueBinResourceID,LastName + ', ' + FirstName as Name from bluebin.BlueBinResource) a where RequesterUserID = a.BlueBinResourceID
update qcn.QCN set LoggedUserID = 1
update qcn.QCN set ClinicalDescription = a.ItemD from (select ItemID as I,ItemDescription as ItemD from bluebin.DimItem) a where ItemID = a.I
update bluebin.BlueBinUser set AssignToQCN = 0
update bluebin.BlueBinUser set AssignToQCN = 1 where RoleID in (select RoleID from bluebin.BlueBinRoles where RoleName like '%BlueBelt%')
update qcn.QCN set Par = a.P from (select ItemID as I,LocationID as L, BinQty as P from bluebin.DimBin) a where ItemID = a.I and LocationID = a.L
update qcn.QCN set UOM = a.U from (select ItemID as I,LocationID as L, BinUOM as U from bluebin.DimBin) a where ItemID = a.I and LocationID = a.L
update qcn.QCN set AssignedUserID = z.ID from 
(select q.QCNID as Q,a.BlueBinUserID as ID,b.LastName as L,b.FirstName as F 
		from qcn.QCN q
			inner join bluebin.BlueBinResource b on q.AssignedUserID = b.BlueBinResourceID
			left join bluebin.BlueBinUser a on b.FirstName = a.FirstName and b.LastName = a.LastName) z where QCNID = z.Q

--Update QCN Types
insert into qcn.QCNType select 'REMOVE','1',getdate(),''
insert into qcn.QCNType select 'MODIFY','1',getdate(),''
update qcn.QCN set QCNTypeID = (Select QCNTypeID from qcn.QCNType where Name = 'MODIFY') where QCNTypeID in (Select QCNTypeID from qcn.QCNType where Name in('CHANGE','UPDATE'))
update qcn.QCN set QCNTypeID = (Select QCNTypeID from qcn.QCNType where Name = 'REMOVE') where QCNTypeID in (Select QCNTypeID from qcn.QCNType where Name in('DELETE'))
delete from qcn.QCNType where Name in ('CHANGE','UPDATE','DELETE')

--Update QCN Statuses
select Status +'-'+Description+'&#013;' from qcn.QCNStatus
insert into qcn.QCNStatus (Status,Active,LastUpdated,Description) VALUES
('NeedsMoreInfo','1',getdate(),'Requester/clinical/other clarification.'),
('AwaitingApproval','1',getdate(),'New items only, e.g. Value Analysis, Product Standards, or other new product committee process.'),
('InFileMaintenance','1',getdate(),'New ERP # or other item activation steps.')

update qcn.QCNStatus set LastUpdated = getdate(),Description = 'QCN is rejected.  This will remove the record off the Live board.' where Status = 'Rejected'
update qcn.QCNStatus set LastUpdated = getdate(),Description = 'QCN is done.  This will remove the record off the Live board.' where Status = 'Completed'
update qcn.QCNStatus set LastUpdated = getdate(),Status = 'New/NotStarted', Description = 'Logged, not yet evaluated for next steps.' where Status = 'New'
update qcn.QCNStatus set LastUpdated = getdate(),Status = 'InProgress/Approved', Description = 'No additional support needed, QCN will be completed within 10 working days.' where Status = 'InProgress'

update qcn.QCN set LastUpdated = getdate(),QCNStatusID = (Select QCNStatusID from qcn.QCNStatus where Status = 'NeedsMoreInfo') where QCNStatusID in (Select QCNStatusID from qcn.QCNStatus where Status in('OnHold','FutureVersion','InReview'))

delete from qcn.QCNStatus where Status in ('OnHold','FutureVersion','InReview')


--setting new columns not null
ALTER TABLE qcn.QCN ALTER COLUMN QCNCID int not null
ALTER TABLE qcn.QCN ALTER COLUMN DateRequested datetime not null
ALTER TABLE qcn.QCN ALTER COLUMN LoggedUserID int not null
ALTER TABLE bluebin.BlueBinUser ALTER COLUMN AssignToQCN int not null
ALTER TABLE qcn.QCN ALTER COLUMN not null
ALTER TABLE qcn.QCN ALTER COLUMN not null
ALTER TABLE qcn.QCN ALTER COLUMN not null

