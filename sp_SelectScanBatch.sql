
if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectScanBatch') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectScanBatch
GO

--exec sp_SelectScanBatch '',''

CREATE PROCEDURE sp_SelectScanBatch
@ScanDate varchar(20),
@Facility varchar(50)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
select 
sb.ScanBatchID,
rtrim(df.FacilityID) as FacilityID,
df.FacilityName as FacilityName,
rtrim(sb.LocationID) as LocationID,
dl.LocationName as LocationName,
max(sl.Line) as BinsScanned,
sb.ScanDateTime as [DateScanned],
--convert(Date,sb.ScanDateTime) as ScanDate,
bbu.LastName + ', ' + bbu.FirstName as ScannedBy,
case when sb.Extracted = 0 then 'No' Else 'Yes' end as Extracted

from scan.ScanBatch sb
inner join bluebin.DimLocation dl on sb.LocationID = dl.LocationID
inner join bluebin.DimFacility df on sb.FacilityID = df.FacilityID
inner join scan.ScanLine sl on sb.ScanBatchID = sl.ScanBatchID
inner join bluebin.BlueBinUser bbu on sb.BlueBinUserID = bbu.BlueBinUserID
where sb.Active = 1 and ScanType = 'Order' 
and convert(varchar,(convert(Date,sb.ScanDateTime)),111) LIKE '%' + @ScanDate + '%'  
--and convert(varchar(4),df.FacilityID) +' - '+ df.FacilityName like '%' + @Facility + '%' 
and sb.FacilityID like '%' + @Facility + '%' 

group by 
sb.ScanBatchID,
df.FacilityID,
df.FacilityName,
sb.LocationID,
dl.LocationName,
sb.ScanDateTime,
bbu.LastName + ', ' + bbu.FirstName,
sb.Extracted
order by sb.ScanDateTime desc

END
GO
grant exec on sp_SelectScanBatch to public
GO
