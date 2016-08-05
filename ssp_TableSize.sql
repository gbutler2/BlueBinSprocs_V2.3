
if exists (select * from dbo.sysobjects where id = object_id(N'ssp_TableSize') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure ssp_TableSize
GO

--exec ssp_TableSize 'dbo'

CREATE PROCEDURE ssp_TableSize
@schema varchar(20)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

/*
select 
'Insert into @Count select '''+ss.name+''','''+st.name+''', count(*) from ' + ss.name + '.' + st.name
from sys.tables st
inner join sys.schemas ss on st.schema_id = ss.schema_id
where ss.name in ('tableau','dbo','bluebin')
order by st.name
*/
declare @Count Table ([Schema] varchar(50),TableName varchar(100),[Count] int)
--insert results of query here
Insert into @Count select 'dbo','APCOMPANY', count(*) from dbo.APCOMPANY
Insert into @Count select 'dbo','APVENMAST', count(*) from dbo.APVENMAST
Insert into @Count select 'bluebin','BlueBinFacility', count(*) from bluebin.BlueBinFacility
Insert into @Count select 'bluebin','BlueBinOperations', count(*) from bluebin.BlueBinOperations
Insert into @Count select 'bluebin','BlueBinParMaster', count(*) from bluebin.BlueBinParMaster
Insert into @Count select 'bluebin','BlueBinResource', count(*) from bluebin.BlueBinResource
Insert into @Count select 'bluebin','BlueBinRoleOperations', count(*) from bluebin.BlueBinRoleOperations
Insert into @Count select 'bluebin','BlueBinRoles', count(*) from bluebin.BlueBinRoles
Insert into @Count select 'bluebin','BlueBinUser', count(*) from bluebin.BlueBinUser
Insert into @Count select 'bluebin','BlueBinUserOperations', count(*) from bluebin.BlueBinUserOperations
Insert into @Count select 'dbo','BUYER', count(*) from dbo.BUYER
Insert into @Count select 'bluebin','ConesDeployed', count(*) from bluebin.ConesDeployed
Insert into @Count select 'bluebin','Config', count(*) from bluebin.Config
Insert into @Count select 'tableau','Contracts', count(*) from tableau.Contracts
Insert into @Count select 'bluebin','DimBin', count(*) from bluebin.DimBin
Insert into @Count select 'bluebin','DimBinHistory', count(*) from bluebin.DimBinHistory
Insert into @Count select 'bluebin','DimBinStatus', count(*) from bluebin.DimBinStatus
Insert into @Count select 'bluebin','DimDate', count(*) from bluebin.DimDate
Insert into @Count select 'bluebin','DimFacility', count(*) from bluebin.DimFacility
Insert into @Count select 'bluebin','DimItem', count(*) from bluebin.DimItem
Insert into @Count select 'bluebin','DimLocation', count(*) from bluebin.DimLocation
Insert into @Count select 'bluebin','DimSnapshotDate', count(*) from bluebin.DimSnapshotDate
Insert into @Count select 'bluebin','DimWarehouseItem', count(*) from bluebin.DimWarehouseItem
Insert into @Count select 'bluebin','Document', count(*) from bluebin.Document
Insert into @Count select 'bluebin','FactBinSnapshot', count(*) from bluebin.FactBinSnapshot
Insert into @Count select 'bluebin','FactIssue', count(*) from bluebin.FactIssue
Insert into @Count select 'bluebin','FactScan', count(*) from bluebin.FactScan
Insert into @Count select 'bluebin','FactWarehouseSnapshot', count(*) from bluebin.FactWarehouseSnapshot
Insert into @Count select 'dbo','GLCHARTDTL', count(*) from dbo.GLCHARTDTL
Insert into @Count select 'dbo','GLNAMES', count(*) from dbo.GLNAMES
Insert into @Count select 'dbo','GLTRANS', count(*) from dbo.GLTRANS
Insert into @Count select 'dbo','ICCATEGORY', count(*) from dbo.ICCATEGORY
Insert into @Count select 'dbo','ICLOCATION', count(*) from dbo.ICLOCATION
Insert into @Count select 'dbo','ICMANFCODE', count(*) from dbo.ICMANFCODE
Insert into @Count select 'dbo','ICTRANS', count(*) from dbo.ICTRANS
Insert into @Count select 'bluebin','Image', count(*) from bluebin.Image
Insert into @Count select 'dbo','ITEMLOC', count(*) from dbo.ITEMLOC
Insert into @Count select 'dbo','ITEMMAST', count(*) from dbo.ITEMMAST
Insert into @Count select 'dbo','ITEMSRC', count(*) from dbo.ITEMSRC
Insert into @Count select 'tableau','Kanban', count(*) from tableau.Kanban
Insert into @Count select 'dbo','MAINVDTL', count(*) from dbo.MAINVDTL
Insert into @Count select 'dbo','MAINVMSG', count(*) from dbo.MAINVMSG
Insert into @Count select 'bluebin','MasterLog', count(*) from bluebin.MasterLog
Insert into @Count select 'dbo','MMDIST', count(*) from dbo.MMDIST
Insert into @Count select 'dbo','POCODE', count(*) from dbo.POCODE
Insert into @Count select 'dbo','POLINE', count(*) from dbo.POLINE
Insert into @Count select 'dbo','POLINESRC', count(*) from dbo.POLINESRC
Insert into @Count select 'dbo','PORECLINE', count(*) from dbo.PORECLINE
Insert into @Count select 'dbo','POVAGRMTLN', count(*) from dbo.POVAGRMTLN
Insert into @Count select 'dbo','PURCHORDER', count(*) from dbo.PURCHORDER
Insert into @Count select 'dbo','REQHEADER', count(*) from dbo.REQHEADER
Insert into @Count select 'dbo','REQLINE', count(*) from dbo.REQLINE
Insert into @Count select 'dbo','REQUESTER', count(*) from dbo.REQUESTER
Insert into @Count select 'dbo','RQLOC', count(*) from dbo.RQLOC
Insert into @Count select 'tableau','Sourcing', count(*) from tableau.Sourcing
Insert into @Count select 'bluebin','Training', count(*) from bluebin.Training
Insert into @Count select 'bluebin','TrainingModule', count(*) from bluebin.TrainingModule--End
select * from @Count  where [Schema] like '%' + @schema + '%' order by 1,2 asc

END
GO
grant exec on ssp_TableSize to public
GO


