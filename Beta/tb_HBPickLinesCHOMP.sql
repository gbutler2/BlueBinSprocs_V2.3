if exists (select * from dbo.sysobjects where id = object_id(N'tb_HBPickLines') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_HBPickLines
GO
--exec tb_HBPickLines
CREATE PROCEDURE tb_HBPickLines
AS
BEGIN
SET NOCOUNT ON


SELECT 
df.FacilityName,
dl.LocationID,
Cast(fi.IssueDate AS DATE) AS Date,
Count(*) AS PickLine
FROM   bluebin.FactIssue fi
inner join bluebin.DimFacility df on fi.ShipFacilityKey = df.FacilityID
left join bluebin.DimLocation dl on fi.LocationKey = dl.LocationKey
where fi.IssueDate > getdate() -15
GROUP  BY df.FacilityName,dl.LocationID,Cast(fi.IssueDate AS DATE)


END
GO
grant exec on tb_HBPickLines to public
GO
