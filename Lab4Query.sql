use Lab1
go

-- check an int 
create function checkId(@n int) 
returns int as 
begin  
   declare @integer int   
   if @n>1 and @n<=10   
      set @integer=1  
   else   
      set @integer=0  
   return @integer 
end 
go 
--checkName
create function checkName(@name varchar(50))
returns bit as
begin
   declare @ok bit
   if @name like'[a-z]%[a-z]'
      set @ok=1
   else
      set @ok=0
   return @ok
end
go
--checkDate
alter function checkDate(@date varchar(50))
returns bit as
begin
   declare @ok bit
   if isdate( @date)=1 
      set @ok=1
   else
      set @ok=0
   return @ok
end
go
--checkDate
create function checkDateOfExp(@date varchar(50))
returns bit as
begin
   declare @ok bit
   declare @currentD date 
   Set @currentD= (Select GETDATE())
   if @date > @currentD
      set @ok=1
   else
      set @ok=0
   return @ok
end
go
--create the first procedure for inserting
create procedure addNeighborhood @id int,@name varchar(50)
AS
begin
     --validate the name and the id
	 if dbo.checkId(@id)=1 and dbo.checkName(@name)=1
	 begin
	    insert into Neighborhood(Nid,Name) values (@id,@name)
		print 'The neighborhood was succesfully added!'
		select * from Neighborhood
	end
	else
	begin
	    print 'The neighborhood could not be added!'
		select * from Neighborhood
	end
end
go
--exec addNeighborhood 9,'Paris'
--exec addNeighborhood 10,'Praga'
exec addNeighborhood 11,'Madrid' --it won't be added,cause 11>10
go

--create the second procedure for inserting
create procedure addDriverLicense @id int,@date1 varchar(50), @date2 varchar(50)
AS
begin
     --validate the name and the id
	 if dbo.checkId(@id)=1 and dbo.checkDate(@date1)=1 and dbo.checkDate(@date2)=1 and dbo.checkDateOfExp(@date2)=1
	 begin
	    insert into DriverLicense(Did,DateOfAdmission,DateOfExpiration) values (@id,@date1,@date2)
		print 'The drivelicense was succesfully added!'
		select * from DriverLicense
	end
	else
	begin
	    print 'The drivelicense could not be added!'
		select * from DriverLicense
	end
end
go
--exec addDriverLicense 8,'10-10-2018','11-11-2024'
--exec addDriverLicense 9,'mamaaa','11-11-2024' --it doesn't work, cause mamaaa is not a date type

-- show coresponding to each driver the brand of his car,
--the salary monthly earned and his drivelicense'date of expiration
create view myView
as
    select d.Name, c.Brand, s.SalaryAmount, l.DateOfExpiration
	from Driver d inner join Car c on d.Did =c.Cid
	inner join Salary s on s.DriverID=d.Did
	inner join DriverLicense l on l.Did=d.Did
	where l.DateOfExpiration>(Select GETDATE())
go
select * from myView
create table Logs



create table Logs(TriggerDate date,TriggerType varchar(50),NameAffectedTable varchar(50), NoAMDRows int)
select * from Logs

--create a copy for Salary table
create table SalaryCopy(DriverID int not null, SalaryAmount float)
go
--INSERT TRIGGER
create trigger Add_Salary on Salary for insert as
begin
   insert into SalaryCopy(DriverID,SalaryAmount)
   select DriverID, SalaryAmount
   from inserted
insert into Logs(TriggerDate, TriggerType, NameAffectedTable, NoAMDRows) values (GETDATE(), 'INSERT', 'Salary', @@ROWCOUNT)
end
go
--UPDATE TRIGGER
alter trigger Update_Salary on Salary for update as
begin
   update SalaryCopy
   set  SalaryAmount=i.SalaryAmount
   from inserted i
   where SalaryCopy.DriverID=i.DriverID
insert into Logs(TriggerDate, TriggerType, NameAffectedTable, NoAMDRows) values (GETDATE(), 'UPDATE', 'Salary', @@ROWCOUNT)
end
go


select * from Salary 
select * from SalaryCopy
insert into Salary Values (6,2800)
update Salary 
    set SalaryAmount=4000
	where DriverID=5
select * from Salary
select * from SalaryCopy 
 
select * from Logs

--create a copy for Neighborhood table
create table NeighborhoodCopy(Nid int not null, Name varchar(255))
go
--INSERT TRIGGER
create trigger Add_Neighborhood on Neighborhood for insert as
begin
    insert into NeighborhoodCopy(Nid,Name)
	select Nid,Name
	from inserted
insert into Logs(TriggerDate, TriggerType, NameAffectedTable, NoAMDRows) values (GETDATE(), 'INSERT', 'Neighborhood', @@ROWCOUNT)
end
go
--DELETE TRIGGER
alter trigger Delete_Neighborhood on Neighborhood for delete as
begin
    delete from NeighborhoodCopy
	 where Nid = (select Nid from deleted);
insert into Logs(TriggerDate, TriggerType, NameAffectedTable, NoAMDRows) values (GETDATE(), 'DELETE', 'Neighborhood', @@ROWCOUNT)
end
go

select * from Neighborhood 
select * from NeighborhoodCopy
insert into Neighborhood Values (9,'Mihaela Zaharie-Butucel')
delete from Neighborhood where Nid=9
select * from Neighborhood
select * from NeighborhoodCopy 
 
select * from Logs
