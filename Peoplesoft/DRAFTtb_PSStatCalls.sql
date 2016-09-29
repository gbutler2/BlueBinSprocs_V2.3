if exists (select * from dbo.sysobjects where id = object_id(N'tb_StatCalls') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_StatCalls
GO



--exec tb_StatCalls
CREATE PROCEDURE tb_StatCalls
AS
BEGIN
SET NOCOUNT ON


--SELECT
--    a.FROM_TO_CMPY,
--	df.FacilityName,
--	TRANS_DATE as Date,
--    COUNT(*) as StatCalls,
--    LTRIM(RTRIM(c.ACCT_UNIT)) + ' - '+ c.DESCRIPTION       as Department
--FROM
--    ICTRANS a 
--INNER JOIN
--RQLOC b ON a.FROM_TO_CMPY = b.COMPANY AND a.FROM_TO_LOC = b.REQ_LOCATION
--INNER JOIN
--GLNAMES c ON b.COMPANY = c.COMPANY AND b.ISS_ACCT_UNIT = c.ACCT_UNIT
--INNER JOIN bluebin.DimFacility df on a.FROM_TO_CMPY = df.FacilityID
--WHERE SYSTEM_CD = 'IC' AND DOC_TYPE = 'IS'
--GROUP BY
--    a.FROM_TO_CMPY,
--	df.FacilityName,
--	TRANS_DATE,
--    c.ACCT_UNIT,
--    c.DESCRIPTION

SELECT
    '' AS FROM_TO_CMPY,
	'' AS FacilityName,
	'' AS Date,
    '' AS StatCalls,
    '' AS Department



END
GO
grant exec on tb_StatCalls to public
GO
