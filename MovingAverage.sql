use assignment;


/* Formating the date from text to date and calculated the moving average for 20 days and 50 days 	
   And Created tables with date , 20 amd 50 day moving average
*/
DROP TABLE IF EXISTS bajaj1;

create table bajaj1 (
with sortedBajajData as (
select STR_TO_DATE(`Date`, '%d-%M-%Y') as MarketingDate, `Close Price` from bajajauto
order by MarketingDate
) 
SELECT  MarketingDate,
       `Close Price`,
       ROW_NUMBER() OVER (ORDER BY MarketingDate ASC) RowNumber,
       AVG(`Close Price`) OVER (ORDER BY MarketingDate ASC ROWS 19 PRECEDING) AS `20 Day MA`,
       AVG(`Close Price`) OVER (ORDER BY MarketingDate ASC ROWS 49 PRECEDING) AS `50 Day MA`
FROM   sortedBajajData
);



DROP TABLE IF EXISTS eichermotors1;


create table eichermotors1 (
with sortedEicherData as (
select STR_TO_DATE(`Date`, '%d-%M-%Y') as MarketingDate, `Close Price` from eichermotors
order by MarketingDate
)
SELECT  MarketingDate,
       `Close Price`,
       ROW_NUMBER() OVER (ORDER BY MarketingDate ASC) RowNumber,
       AVG(`Close Price`) OVER (ORDER BY MarketingDate ASC ROWS 19 PRECEDING) AS `20 Day MA`,
       AVG(`Close Price`) OVER (ORDER BY MarketingDate ASC ROWS 49 PRECEDING) AS `50 Day MA`
FROM   sortedEicherData
);


DROP TABLE IF EXISTS heromotocorp1;

create table heromotocorp1 (
with sortedheromotocorpData as (
select STR_TO_DATE(`Date`, '%d-%M-%Y') as MarketingDate, `Close Price` from heromotocorp
order by MarketingDate
)
SELECT  MarketingDate,
       `Close Price`,
       ROW_NUMBER() OVER (ORDER BY MarketingDate ASC) RowNumber,
       AVG(`Close Price`) OVER (ORDER BY MarketingDate ASC ROWS 19 PRECEDING) AS `20 Day MA`,
       AVG(`Close Price`) OVER (ORDER BY MarketingDate ASC ROWS 49 PRECEDING) AS `50 Day MA`
FROM   sortedheromotocorpData
);



DROP TABLE IF EXISTS infosys1;

create table infosys1 (
with sortedInfosysData as (
select STR_TO_DATE(`Date`, '%d-%M-%Y') as MarketingDate, `Close Price` from infosys
order by MarketingDate
)
SELECT  MarketingDate,
       `Close Price`,
       ROW_NUMBER() OVER (ORDER BY MarketingDate ASC) RowNumber,
       AVG(`Close Price`) OVER (ORDER BY MarketingDate ASC ROWS 19 PRECEDING) AS `20 Day MA`,
       AVG(`Close Price`) OVER (ORDER BY MarketingDate ASC ROWS 49 PRECEDING) AS `50 Day MA`
FROM   sortedInfosysData
);


DROP TABLE IF EXISTS tcs1;

create table tcs1 (
with sortedTcsData as (
select STR_TO_DATE(`Date`, '%d-%M-%Y') as MarketingDate, `Close Price` from tcs
order by MarketingDate
)
SELECT  MarketingDate,
       `Close Price`,
       ROW_NUMBER() OVER (ORDER BY MarketingDate ASC) RowNumber,
       AVG(`Close Price`) OVER (ORDER BY MarketingDate ASC ROWS 19 PRECEDING) AS `20 Day MA`,
       AVG(`Close Price`) OVER (ORDER BY MarketingDate ASC ROWS 49 PRECEDING) AS `50 Day MA`
FROM   sortedTcsData
);



DROP TABLE IF EXISTS tvsmotors1;

create table tvsmotors1 (
with sortedtvsmotorsData as (
select STR_TO_DATE(`Date`, '%d-%M-%Y') as MarketingDate, `Close Price` from tvsmotors
order by MarketingDate
)
SELECT  MarketingDate,
       `Close Price`,
       ROW_NUMBER() OVER (ORDER BY MarketingDate ASC) RowNumber,
       AVG(`Close Price`) OVER (ORDER BY MarketingDate ASC ROWS 19 PRECEDING) AS `20 Day MA`,
       AVG(`Close Price`) OVER (ORDER BY MarketingDate ASC ROWS 49 PRECEDING) AS `50 Day MA`
FROM   sortedtvsmotorsData
);

/* Creating Signnal stock function which takes following parameters as input and returns signal as output

	input: 
		ROWNUMBER
        DAY20AVERAGE
        DAY50AVERAGE
        PREVIOUS_DAY20AVERAGE
        PREVIOUS_DAY50AVERAGE
	output : Signal - (Sell , buy or hold)
*/
SET GLOBAL log_bin_trust_function_creators = 1;
delimiter $

drop Function if exists SignalStock;
CREATE FUNCTION SignalStock( ROWNUMBER INT , DAY20AVERAGE FLOAT , DAY50AVERAGE FLOAT, PREVIOUS_DAY20AVERAGE float ,PREVIOUS_DAY50AVERAGE float)
RETURNS VARCHAR(10)  
BEGIN
	DECLARE SIGNALS VARCHAR(10) DEFAULT NULL;
	
   SET SIGNALS =( SELECT CASE
				WHEN (PREVIOUS_DAY20AVERAGE < PREVIOUS_DAY50AVERAGE) and ROWNUMBER > 49 AND DAY20AVERAGE > DAY50AVERAGE THEN 'Buy'
				WHEN (PREVIOUS_DAY20AVERAGE > PREVIOUS_DAY50AVERAGE) and ROWNUMBER > 49 AND DAY20AVERAGE < DAY50AVERAGE THEN 'Sell'
				ELSE 'Hold'
			END) ;
	RETURN SIGNALS;

END;
delimiter ;

/* Creating table with date , closing price and signal*/

DROP TABLE IF EXISTS bajaj2;
create table bajaj2 (
SELECT MarketingDate, `Close Price`,
IF(RowNumber > 19, SignalStock(RowNumber,`20 Day MA`,`50 Day MA`,lag(`20 Day MA`,1,0) over MarketDate ,lag(`50 Day MA`,1,0) over MarketDate), NULL)  as `Signal`
FROM   bajaj1
window MarketDate as (ORDER BY MarketingDate)
);

DROP TABLE IF EXISTS eichermotors2;
create table eichermotors2 (
SELECT MarketingDate, `Close Price`,
IF(RowNumber > 19, SignalStock(RowNumber,`20 Day MA`,`50 Day MA`,lag(`20 Day MA`,1,0) over MarketDate ,lag(`50 Day MA`,1,0) over MarketDate), NULL)  as `Signal`
FROM   eichermotors1
window MarketDate as (ORDER BY MarketingDate)
);

DROP TABLE IF EXISTS heromotocorp2;
create table heromotocorp2 (
SELECT MarketingDate, `Close Price`,
IF(RowNumber > 19, SignalStock(RowNumber,`20 Day MA`,`50 Day MA`,lag(`20 Day MA`,1,0) over MarketDate ,lag(`50 Day MA`,1,0) over MarketDate), NULL)  as `Signal`
FROM   heromotocorp1
window MarketDate as (ORDER BY MarketingDate)
);

DROP TABLE IF EXISTS tcs2;
create table tcs2 (
SELECT MarketingDate, `Close Price`,
IF(RowNumber > 19, SignalStock(RowNumber,`20 Day MA`,`50 Day MA`,lag(`20 Day MA`,1,0) over MarketDate ,lag(`50 Day MA`,1,0) over MarketDate), NULL)  as `Signal`
FROM   tcs1
window MarketDate as (ORDER BY MarketingDate)
);


DROP TABLE IF EXISTS infosys2;
create table infosys2 (
SELECT MarketingDate, `Close Price`,
IF(RowNumber > 19, SignalStock(RowNumber,`20 Day MA`,`50 Day MA`,lag(`20 Day MA`,1,0) over MarketDate ,lag(`50 Day MA`,1,0) over MarketDate), NULL)  as `Signal`
FROM   infosys1
window MarketDate as (ORDER BY MarketingDate)
); 

DROP TABLE IF EXISTS tvsmotors2;
create table tvsmotors2 (
SELECT MarketingDate, `Close Price`,
IF(RowNumber > 19, SignalStock(RowNumber,`20 Day MA`,`50 Day MA`,lag(`20 Day MA`,1,0) over MarketDate ,lag(`50 Day MA`,1,0) over MarketDate), NULL)  as `Signal`
FROM   tvsmotors1
window MarketDate as (ORDER BY MarketingDate)
);


/* Creating Master table from  date and closing price of all the companies */

DROP TABLE IF EXISTS MasterTable;
create table MasterTable (
	select b.MarketingDate,
		   b.`Close Price` as bajaj,
		   e.`Close Price` as eichermotors,
		   t.`Close Price` as tvsmotors,
		   tc.`Close Price` as tcs,
		   h.`Close Price` as heromotocorp
	from bajaj2 b 
	left join eichermotors2 e on b.MarketingDate = e.MarketingDate
	left join tvsmotors2 t on e.MarketingDate=t.MarketingDate
	left join tcs2 tc on tc.MarketingDate=t.MarketingDate
	left join heromotocorp2 h on h.MarketingDate=tc.MarketingDate
);

