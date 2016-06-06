if exists (select * from dbo.sysobjects where id = object_id(N'sp_CleanLawsonTables') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_CleanLawsonTables
GO

--exec sp_CleanLawsonTables
CREATE PROCEDURE sp_CleanLawsonTables


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
truncate table dbo.APCOMPANY
truncate table dbo.APVENMAST
truncate table dbo.BUYER
truncate table dbo.GLCHARTDTL
truncate table dbo.GLNAMES
truncate table dbo.GLTRANS
truncate table dbo.ICCATEGORY
truncate table dbo.ICMANFCODE
truncate table dbo.ICLOCATION
truncate table dbo.ICTRANS
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

END
GO
grant exec on sp_CleanLawsonTables to appusers
GO
