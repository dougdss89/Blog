select 
	top(10)
	CustomerID,
	+( 'split column divide colunas') as coluna
from Sales.SalesOrderHeader;
go

with stringsplit as (
select 
	top(10)
	CustomerID,
	+( 'string_split divide colunas') as coluna
from Sales.SalesOrderHeader)

select distinct customerid, [value]
from stringsplit
cross apply string_split(coluna, ' ');
go

declare 
@sentenca as varchar(30) = 'testando string split'
select [value]
from string_split(@sentenca, ' ');
go