
create table dbo.names (
	Id int not null identity(1, 1),
	Name nvarchar(100) not null
) 

go

alter table dbo.names 
add constraint pk_names primary key clustered (id)

go

bulk
insert dbo.names
from 'c:\book1.csv'
with (
	fieldterminator = ',', rowterminator = '\n'
)

select * from dbo.names