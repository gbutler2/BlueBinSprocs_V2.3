IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'tb_TodaysOrders')
                    AND type IN ( N'P', N'PC' ) ) 

DROP PROCEDURE  tb_TodaysOrders
GO

CREATE PROCEDURE	tb_TodaysOrders
--exec tb_TodaysOrders  
AS

SET NOCOUNT on

select 
[current].CREATION_DATE,
[current].COMPANY,
[current].REQ_LOCATION,
[current].LocationName,
[current].Lines as TodayLines,
ISNULL([past].Lines,0) as YestLines,
case 
	when [current].Lines > ISNULL([past].Lines,0) then 'UP' 
	when [current].Lines < ISNULL([past].Lines,0) then 'DOWN'
	else 'EVEN' end as Trend

from (
select 
			rq.CREATION_DATE as CREATION_DATE,
			rq.COMPANY,
			rq.REQ_LOCATION,
			dl.LocationName,
			count(rq.LINE_NBR) as Lines

			from REQLINE rq
			inner join bluebin.DimLocation dl on rq.COMPANY = dl.LocationFacility and rq.REQ_LOCATION = dl.LocationID and dl.BlueBinFlag = 1
			inner join REQHEADER rh on rq.REQ_NUMBER = rh.REQ_NUMBER
			where rq.CREATION_DATE > getdate() -2
			group by
			rq.CREATION_DATE,
			rq.COMPANY,
			rq.REQ_LOCATION,
			dl.LocationName) [current]
left join (
			select 
			rq.CREATION_DATE+1 as CREATION_DATE,
			rq.COMPANY,
			rq.REQ_LOCATION,
			dl.LocationName,
			count(rq.LINE_NBR) as Lines

			from REQLINE rq
			inner join bluebin.DimLocation dl on rq.COMPANY = dl.LocationFacility and rq.REQ_LOCATION = dl.LocationID and dl.BlueBinFlag = 1
			inner join REQHEADER rh on rq.REQ_NUMBER = rh.REQ_NUMBER
			where rq.CREATION_DATE > getdate() -3
			group by
			rq.CREATION_DATE+1,
			rq.COMPANY,
			rq.REQ_LOCATION,
			dl.LocationName) [past] on [current].COMPANY = past.COMPANY and [current].REQ_LOCATION = past.REQ_LOCATION and [current].CREATION_DATE = past.CREATION_DATE
where [current].CREATION_DATE > getdate()-2

GO
grant exec on tb_TodaysOrders to public
GO
