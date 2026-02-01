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

