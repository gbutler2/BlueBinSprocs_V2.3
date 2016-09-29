if exists (select * from dbo.sysobjects where id = object_id(N'tb_PickLines') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_PickLines
GO
--exec tb_PickLines
CREATE PROCEDURE tb_PickLines
AS
BEGIN
SET NOCOUNT ON


SELECT 
df.FacilityName,
Cast(fi.IssueDate AS DATE) AS Date,
Count(*) AS PickLine
FROM   bluebin.FactIssue fi
inner join bluebin.DimFacility df on fi.ShipFacilityKey = df.FacilityID
GROUP  BY df.FacilityName,Cast(fi.IssueDate AS DATE)


END
GO
grant exec on tb_PickLines to public
GO
