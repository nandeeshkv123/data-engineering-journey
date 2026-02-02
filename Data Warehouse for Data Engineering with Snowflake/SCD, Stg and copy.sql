CREATE TABLE Customer (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100) NOT NULL,
    CustomerEmail VARCHAR(150),
    CustomerPhone VARCHAR(20),
    LoadDate DATE,
    CustomerAddress VARCHAR(255)
);
INSERT INTO Customer (
    CustomerID,
    CustomerName,
    CustomerEmail,
    CustomerPhone,
    LoadDate,
    CustomerAddress
)
VALUES
(1, 'Rahul Sharma', 'rahul.sharma@gmail.com', '9876543210', CURRENT_DATE, 'Bangalore, Karnataka'),
(2, 'Anita Verma', 'anita.verma@gmail.com', '9123456789', CURRENT_DATE, 'Mumbai, Maharashtra'),
(3, 'Suresh Kumar', 'suresh.kumar@gmail.com', '9988776655', CURRENT_DATE, 'Chennai, Tamil Nadu');

select * from Customer

---SCD 1

UPDATE CUSTOMER
SET CUSTOMERADDRESS = 'Bellary' where CUSTOMERID = 2 


select * from Customer


--- SCD 2

ALTER TABLE Customer ADD COLUMN customer_segment varchar(20) ;

ALTER TABLE Customer add column start_date date ;

ALTER TABLE Customer ADD COLUMN end_date date ;

ALTER TABLE Customer add column version bigint default 1 ;


UPDATE Customer set customer_segment = 'Gold'  , start_date = '2022-02-01' , end_date = '9999-12-31'   where customerid = 2 ;

select * from Customer


insert into Customer
select 
   CustomerID,
    CustomerName,
    CustomerEmail,
    CustomerPhone,
    LoadDate,
    CustomerAddress,
    'Platinum',
    '2022-02-01',
    '9999-12-31',
     version + 1
     from customer where customerid = 2

    UPDATE CUSTOMER set end_date ='2022-02-28' where customerid = 2 and version = 1 ;



--scd - 3 

ALTER TABLE customer add column prev_segment varchar(255) ;


insert into Customer
select 
   CustomerID,
    CustomerName,
    CustomerEmail,
    CustomerPhone,
    LoadDate,
    CustomerAddress,
    'Silver',
    '2022-02-01',
    '9999-12-31',
     version + 1,
     customer_segment
     from customer where customerid = 2
    
select * from Customer where customerid = 2


 ----STAGE AND COPY 
    
CREATE OR REPLACE DATABASE MANAGE_DB ;

CREATE OR REPLACE SCHEMA external_stages ;


create or replace stage manage_db.external_stages.aws_stage
url = 'S3://bucketsnowflakes3'


LIST @aws_stage


CREATE OR REPLACE TABLE MANAGE_DB.PUBLIC.ORDERS
(
ORDER_ID VARCHAR(3),
AMOUNT INT ,
PROFIT INT,
QUANTITY INT,
CATEGORY VARCHAR(30),
SUBCATEGORY VARCHAR(30));


SELECT * FROM MANAGE_DB.PUBLIC.ORDERS


COPY INTO MANAGE_DB.PUBLIC.ORDERS
FROM @aws_stage
file_format = (type = csv  field_delimiter = "," skip_header = 1)
files = ('OrderDetails.csv')


ALTER TABLE MANAGE_DB.PUBLIC.ORDERS
MODIFY COLUMN ORDER_ID VARCHAR(20);



---if you want to only add few column 


CREATE OR REPLACE TABLE MANAGE_DB.PUBLIC.ORDERS_EX
(
ORDER_ID VARCHAR(30),
AMOUNT INT 
);

COPY INTO MANAGE_DB.PUBLIC.ORDERS_EX
FROM ( SELECT s.$1 , s.$2  from  @manage_db.external_stages.aws_stage s)
file_format = (type = csv  field_delimiter = "," skip_header = 1)
files = ('OrderDetails.csv')


select * from MANAGE_DB.PUBLIC.ORDERS_EX


---if yon want to add more derivated column


CREATE OR REPLACE TABLE MANAGE_DB.PUBLIC.ORDERS_EX1
(
ORDER_ID VARCHAR(30),
AMOUNT INT ,
PROFIT INT,
QUANTITY INT,
CATEGORY_SUBSTRING VARCHAR(5)
);


COPY INTO MANAGE_DB.PUBLIC.ORDERS_EX1
FROM ( 
SELECT 
s.$1 , 
s.$2  ,
s.$3,
s.$4,
CASE WHEN CAST(s.$3 as int ) < 0 then 'not profitable' else 'profitable' end 
from  @manage_db.external_stages.aws_stage s)
file_format = (type = csv  field_delimiter = "," skip_header = 1)
files = ('OrderDetails.csv');

ALTER TABLE MANAGE_DB.PUBLIC.ORDERS_EX1
MODIFY COLUMN CATEGORY_SUBSTRING VARCHAR(20);


select * from MANAGE_DB.PUBLIC.ORDERS_EX1




    

--- HOW TO HANDLE UNSTRUCTURED DATA and convert into a usable format 

CREATE OR REPLACE STAGE MANAGE_DB.EXTERNAL_STAGES.JSONSTAGE
     URL = 's3://bucketsnowflake-jsondemo' ;

CREATE OR REPLACE file format MANAGE_DB.FILE_FORMATS.JSONFORMAT
   TYPE = JSON ;
   
CREATE DATABASE OUR_FIRST_DB ;

CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.JSON_RAW (
RAW_FILE VARIANT 
);

SELECT * FROM OUR_FIRST_DB.PUBLIC.JSON_RAW

EX:
    {
  "city": "Bakersfield",
  "first_name": "Portia",
  "gender": "Male",
  "id": 1,
  "job": {
    "salary": 32000,
    "title": "Financial Analyst"
  },
  "last_name": "Gioani",
  "prev_company": [],
  "spoken_languages": [
    {
      "language": "Kazakh",
      "level": "Advanced"
    },
    {
      "language": "Lao",
      "level": "Basic"
    }
  ]
}


COPY INTO OUR_FIRST_DB.PUBLIC.JSON_RAW
 FROM @MANAGE_DB.EXTERNAL_STAGES.JSONSTAGE
 FILE_FORMAT = MANAGE_DB.FILE_FORMATS.JSONFORMAT
 files = ('HR_data.json') ;

 select *  from OUR_FIRST_DB.PUBLIC.JSON_RAW


 select RAW_FILE:city  as city ,RAW_FILE:first_name as first_name ,RAW_FILE:job.salary ,RAW_FILE:job.title     FROM OUR_FIRST_DB.PUBLIC.JSON_RAW


     ---If you want one row per language (more analytics-friendly) 
     
     SELECT
    raw:id::INT                AS id,
    raw:first_name::STRING     AS first_name,
    raw:last_name::STRING      AS last_name,
    raw:gender::STRING         AS gender,
    raw:city::STRING           AS city,
    raw:job.title::STRING      AS job_title,
    raw:job.salary::INT        AS job_salary,
    lang.value:language::STRING AS language,
    lang.value:level::STRING    AS level
FROM OUR_FIRST_DB.PUBLIC.JSON_RAW,
     LATERAL FLATTEN(input => raw:spoken_languages) lang;

output :

| id | first_name | last_name | city        | job_title         | job_salary | language | level    |
| -- | ---------- | --------- | ----------- | ----------------- | ---------- | -------- | -------- |
| 1  | Portia     | Gioani    | Bakersfield | Financial Analyst | 32000      | Kazakh   | Advanced |
| 1  | Portia     | Gioani    | Bakersfield | Financial Analyst | 32000      | Lao      | Basic    |

 CREATE  OR REPLACE TABLE Languages as 
 select 
    RAW_FILE:first_name :: STRING first_name ,
    f.value:language::STRING language,
    f.value:level::STRING level 
FROM OUR_FIRST_DB.PUBLIC.JSON_RAW , TABLE(flatten(RAW_FILE:spoken_languages)) f

select * from Languages




 
