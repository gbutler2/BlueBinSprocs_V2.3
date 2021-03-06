if exists (select * from dbo.sysobjects where id = object_id(N'tb_ItemLocator') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_ItemLocator
GO

--exec tb_ItemLocator

CREATE PROCEDURE tb_ItemLocator

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
Declare @UseClinicalDescription int
select @UseClinicalDescription = ConfigValue from bluebin.Config where ConfigName = 'UseClinicalDescription'         
	
SELECT 
	a.COMPANY,
	df.FacilityName,
	a.ITEM as LawsonItemNumber,
	ISNULL(c.MANUF_NBR,'N/A') as ItemManufacturerNumber,
	case when @UseClinicalDescription = 1 then
		case 
			when b.ClinicalDescription is null or b.ClinicalDescription = ''  then
			case
				when a.USER_FIELD3 is null or a.USER_FIELD3 = ''  then
				case	
					when a.USER_FIELD1 is null or a.USER_FIELD1 = '' then '*NEEDS*' 
				else a.USER_FIELD1 end
			else a.USER_FIELD3 end
		else b.ClinicalDescription end	
	else c.DESCRIPTION
	end as ClinicalDescription,
	a.LOCATION as LocationCode,
	a.NAME as LocationName,
	a.Cart,
	a.Row,
	a.Position
FROM 
(SELECT 
	a.COMPANY,
	ITEM,
	LOCATION,
	b.NAME,
	USER_FIELD1,
	USER_FIELD3,
	CASE WHEN ISNUMERIC(left(PREFER_BIN,1))=1 then LEFT(PREFER_BIN,2) 
		else CASE WHEN PREFER_BIN LIKE '[A-Z][A-Z]%' THEN LEFT(PREFER_BIN, 2) ELSE LEFT(PREFER_BIN, 1) END END as Cart,
	CASE WHEN ISNUMERIC(left(PREFER_BIN,1))=1 then SUBSTRING(PREFER_BIN, 3, 1) 
		else CASE WHEN PREFER_BIN LIKE '[A-Z][A-Z]%' THEN SUBSTRING(PREFER_BIN, 3, 1) ELSE SUBSTRING(PREFER_BIN, 2,1) END END as Row,
	CASE WHEN ISNUMERIC(left(PREFER_BIN,1))=1 then SUBSTRING(PREFER_BIN, 4, 2)
		else CASE WHEN PREFER_BIN LIKE '[A-Z][A-Z]%' THEN SUBSTRING (PREFER_BIN,4,2) ELSE SUBSTRING(PREFER_BIN, 3,2) END END as Position	
FROM ITEMLOC a 
INNER JOIN RQLOC b ON a.LOCATION = b.REQ_LOCATION and a.COMPANY = b.COMPANY
WHERE LEFT(REQ_LOCATION, 2) IN (SELECT [ConfigValue] FROM   [bluebin].[Config] WHERE  [ConfigName] = 'REQ_LOCATION' AND Active = 1)) a
LEFT JOIN 
(SELECT 
	ITEM, 
	max(USER_FIELD3) as ClinicalDescription
FROM ITEMLOC 
WHERE LOCATION IN (SELECT [ConfigValue] FROM [bluebin].[Config] WHERE  [ConfigName] = 'LOCATION' AND Active = 1) AND LEN(LTRIM(USER_FIELD3) ) > 0 group by ITEM
) b
ON a.ITEM = b.ITEM

left join ITEMMAST c on a.ITEM = c.ITEM
left join bluebin.DimFacility df on a.COMPANY = df.FacilityID



END
GO
grant exec on tb_ItemLocator to public
GO



