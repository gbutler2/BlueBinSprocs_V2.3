SELECT 
	a.ItemID as [ItemID],
	'' as ItemManufacturerNumber,
	COALESCE(b.ItemDescription,b.ItemDescription2,'*NEEDS*') as ClinicalDescription,
	a.LocationID as LocationCode,
	c.LocationName as LocationName,
	CASE WHEN BinSequence LIKE '[A-Z][A-Z]%' THEN LEFT(BinSequence, 2) ELSE LEFT(BinSequence, 1) END as Cart,
	CASE WHEN BinSequence LIKE '[A-Z][A-Z]%' THEN SUBSTRING(BinSequence, 3, 1) ELSE SUBSTRING(BinSequence, 2,1) END as Row,
	CASE WHEN BinSequence LIKE '[A-Z][A-Z]%' THEN SUBSTRING (BinSequence,4,2) ELSE SUBSTRING(BinSequence, 3,2) END as Position
FROM bluebin.BlueBinParMaster a


LEFT JOIN bluebin.DimItem b ON rtrim(a.ItemID) = rtrim(b.ItemID)
LEFT JOIN bluebin.DimLocation c on rtrim(c.LocationID) = rtrim(a.LocationID)

WHERE LEFT(a.LocationID, 2) IN (SELECT [ConfigValue] FROM   [bluebin].[Config] WHERE  [ConfigName] = 'REQ_LOCATION' AND Active = 1)