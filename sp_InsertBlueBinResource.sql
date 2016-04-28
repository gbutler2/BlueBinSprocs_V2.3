if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertBlueBinResource') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertBlueBinResource
GO

--exec sp_InsertBlueBinResource 'TEST'

CREATE PROCEDURE sp_InsertBlueBinResource
@LastName varchar (30)
,@FirstName varchar (30)
,@MiddleName varchar (30)
,@Login varchar (60)
,@Email varchar (60)
,@Phone varchar (20)
,@Cell varchar (20)
,@Title varchar (50)


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
if exists(select * from bluebin.BlueBinResource where FirstName = @FirstName and LastName = @LastName and [Login] = @Login)
	BEGIN
		if not exists (select * from bluebin.BlueBinTraining where BlueBinResourceID in (select BlueBinResourceID from bluebin.BlueBinResource where FirstName = @FirstName and LastName = @LastName and [Login] = @Login))
		BEGIN
		insert into bluebin.Training ([BlueBinResourceID],[TrainingModuleID],[Status],[BlueBinUserID],[Active],[LastUpdated])
			select 
			u.BlueBinResourceID,
			t.TrainingModuleID,
			'No',
			(select BlueBinUserID from bluebin.BlueBinUser where UserLogin = 'gbutler@bluebin.com'),
			1,
			getdate()
			from bluebin.TrainingModule t, bluebin.BlueBinResource u
			where t.Required = 1 and  u.FirstName = @FirstName and u.LastName = @LastName and u.[Login] = @Login
			and Title in (select ConfigValue from bluebin.Config where ConfigName = 'TrainingTitle')
		END
		GOTO THEEND
	END
;
insert into bluebin.BlueBinResource (FirstName,LastName,MiddleName,[Login],Email,Phone,Cell,Title,Active,LastUpdated) 
VALUES (@FirstName,@LastName,@MiddleName,@Login,@Email,@Phone,@Cell,@Title,1,getdate())
;
	insert into bluebin.Training ([BlueBinResourceID],[TrainingModuleID],[Status],[BlueBinUserID],[Active],[LastUpdated])
	select 
	u.BlueBinResourceID,
	t.TrainingModuleID,
	'No',
	(select BlueBinUserID from bluebin.BlueBinUser where UserLogin = 'gbutler@bluebin.com'),
	1,
	getdate()
	from bluebin.TrainingModule t, bluebin.BlueBinResource u
	where t.Required = 1 and  u.FirstName = @FirstName and u.LastName = @LastName and u.[Login] = @Login
	and Title in (select ConfigValue from bluebin.Config where ConfigName = 'TrainingTitle')

END
THEEND:

GO
grant exec on sp_InsertBlueBinResource to appusers
GO

