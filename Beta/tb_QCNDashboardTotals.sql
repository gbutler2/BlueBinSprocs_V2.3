if exists (select * from dbo.sysobjects where id = object_id(N'tb_QCNDashboardTotals') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_QCNDashboardTotals
GO

--exec tb_QCNDashboard 
CREATE PROCEDURE tb_QCNDashboardTotals

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

select 
CONVERT(VARCHAR(8),d.Date,112),
count(CONVERT(VARCHAR(8),q1.DateEntered,112)),
count(CONVERT(VARCHAR(8),q2.DateCompleted,112)) 
from bluebin.DimDate d
	left join [qcn].[QCN] q1 on CONVERT(VARCHAR(8),d.Date,112) = CONVERT(VARCHAR(8),q1.DateEntered,112) and q1.Active = 1
	left join [qcn].[QCN] q2 on CONVERT(VARCHAR(8),d.Date,112) = CONVERT(VARCHAR(8),q2.DateCompleted,112) and q2.Active = 1
where d.Date > getdate()-90 and d.Date < getdate() +1
group by CONVERT(VARCHAR(8),d.Date,112)

order by 1 desc

END
GO
grant exec on tb_QCNDashboardTotals to public
GO
