/*  creating a sample zomato database and use sql to clean the data for required query*/
use zomato;
drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'2017-09-22'),
(3,'2017-04-21');

drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'2014-02-09'),
(2,'2015-11-02'),
(3,'2014-11-04');

drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'2017-04-19',2),
(3,'2019-12-18',1),
(2,'2020-07-20',3),
(1,'2019-10-23',2),
(1,'2016-03-19',3),
(3,'2016-12-20',2),
(1,'2016-11-09',1),
(1,'2016-05-20',3),
(2,'2017-09-24',1),
(1,'2017-03-11',2),
(1,'2016-03-11',1),
(3,'2016-11-10',1),
(3,'2017-12-07',2),
(3,'2016-12-15',2),
(2,'2017-11-08',2),
(2,'2018-09-10',3);


drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);


select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

/* QUERY SECTION
*/
/*  total amount spent by each user on zomato*/
select a.userid , sum(p.price) total_amount_spent from sales a join product p  
 on a.product_id = p.product_id group by a.userid  ;
 
 /* how many days each customer visited zomato*/
  select a.userid , count( distinct b.created_date) distinct_days from users a join sales b 
  on a.userid = b.userid group by userid;
  
 /* what was the first prodect purchased by customer */
 select* from
 (select * , rank() over ( partition by userid order by created_date) rnk from sales)  
 a where rnk = 1;
 
 /* what is the most purchased item in the menu and how many times it is purchased by each of the customer */
 select userid , count(product_id) cnt from sales where product_id =
 (select product_id  from sales group by product_id 
 order by count(product_id) desc limit 1) group by userid
 ;
 
 /* which item is most popular for each of the customer */
select *from
(select * , rank() over( partition by userid order by cnt desc ) rnk from
 (select userid , product_id ,count(product_id) cnt from sales
 group by userid , product_id) a)b where rnk=1 ;
 
 /* what item is purchased first by customer when they become the goldmember*/
 
select * from
(select t.* , rank() over (partition by userid order by created_date) rnk from 
( select b.userid , a.gold_signup_date , b.created_date , b.product_id from goldusers_signup a 
 join sales b on a.userid = b.userid and created_date >= gold_signup_date) t) v where rnk = 1;
 
/* what was the product purchased just before the customer become member */
 select * from
 (select t.* , rank() over( partition by userid order by created_date desc ) rnk 
 from (select a.userid , a.created_date , a.product_id , b.gold_signup_date
 from sales a join goldusers_signup b on a.userid = b.userid and
 created_date < gold_signup_date) t) x where rnk=1 ;
 
 /* what is the total no. of order and amount spent by each user before they become member */
 
 select x.userid , count(x.created_date) , sum(x.price) from
 (select m.* , n.price from
 (select a.userid , a.created_date,a.product_id  from sales a
 join goldusers_signup b on
 a.userid = b.userid and 
 created_date < gold_signup_date ) m  
 join product n on m.product_id = n.product_id)x group by userid;
 
 /* if buying each product generate points eg 5rs for 2 zomato points and each product has different purchasing points
  eg for p1 rs 5 for 1 zp , for p2 rs 10 for 5 zp and for p3 5 rs for 1 zp
  calculate the points collected by each customer and which product have given the most point
  */
  select userid , sum(zp) from
 ( select e.userid , floor(amt/points) zp  from 
  (select d.* , case when product_id = 1 then 5 
  when product_id = 2 then 2 when product_id = 3 then 5 else 0 end as points from
  (select c.userid,c.product_id , sum(c.price) amt from
 ( select a.userid , a.created_date ,a.product_id ,b.price from sales a join product b on  
  a.product_id = b.product_id )c group by c.userid,c.product_id )d)e ) f group by userid;
  
  
  select product_id , sum(zp) from
 ( select e.userid , e.product_id, floor(amt/points) zp  from 
 (select d.* , case when product_id = 1 then 5 
  when product_id = 2 then 2 when product_id = 3 then 5 else 0 end as points from
 (select c.userid,c.product_id , sum(c.price) amt from
 ( select a.userid , a.created_date ,a.product_id ,b.price from sales a join product b on  
  a.product_id = b.product_id )c group by c.userid,c.product_id)d )e)f group by product_id;
  
  /* for the very first year for gold member they are given 5 zp for every 10 
  rupee spent tell me the which member has got the max zp*/
   
   select c.userid ,c.product_id, floor(d.price/2) total_zp from
   (select a.userid , a.created_date ,a.product_id ,b.gold_signup_date from sales a
   join goldusers_signup b on a.userid = b.userid and 
   created_date>= gold_signup_date and 
   created_date <=  date_add( gold_signup_date, INTERVAL 1 YEAR) ) C join
   product d on c.product_id = d.product_id order by total_zp desc;
   
   /* rank all the transaction of the customer */
   
   
   
   
 