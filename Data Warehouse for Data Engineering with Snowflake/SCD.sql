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
