create database Dannys_Diner;

create table sales (
    "customer_id" varchar(1),
    "order_date" date,
    "product_id" INTEGER
);

insert into sales
("customer_id", "order_date", "product_id")
VALUES
('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

  select * from sales
  select * from members;
  select * from menu;


--What is the total amount each customer spent at the restaurant?
  select s.customer_id, sum(m.price) as total_expenses
  from sales as s
  left join menu as m
  on s.product_id = m.product_id
  group by s.customer_id;

 --How many days has each customer visited the restaurant?
  select customer_id, count(distinct order_date) as days_total 
  from sales
  group by customer_id
  order by days_total desc;

  --What was the first item from the menu purchased by each customer? 
  select s.customer_id, m.product_name 
  from sales as s
  left join menu as m 
  on s.product_id = m.product_id
  where s.order_date = '2021-01-01'
  group by s.customer_id, m.product_name
  order by customer_id;

 --What is the most purchased item on the menu and how many times was it purchased by all customers?
  select m.product_name, count(s.product_id) as total_purchases
  from sales as s
  left join menu as m
  on s.product_id = m.product_id
  group by m.product_name
  having count(s.product_id) >= 2
  order by total_purchases desc;

--Which item was the most popular for each customer?
select s.customer_id, m.product_name
from sales as s
left join menu as m
on s.product_id = m.product_id
where m.product_id in (select count(product_id) 
from sales
group by product_id)
group by s.customer_id, m.product_name

--Which item was purchased first by the customer after they became a member?
select s.customer_id, m.product_name
from sales as s
left join menu as m
on s.product_id = m.product_id
left join members as me
on s.customer_id = me.customer_id
where s.order_date > '2021-01-09' and order_date between '2021-01-10' and '2021-01-11'
group by s.customer_id, m.product_name

--Which item was purchased just before the customer became a member?
select distinct s.customer_id, m.product_name
from sales as s
left join menu as m
on s.product_id = m.product_id
left join members as me
on s.customer_id = me.customer_id
where s.order_date < me.join_date 

--What is the total items and amount spent for each member before they became a member?
select s.customer_id, count(s.product_id) as items_amount, sum(m.price) as total_spent
from sales as s 
left join menu as m
on s.product_id = m.product_id
left join members as me
on s.customer_id = me.customer_id
where s.order_date < me.join_date
group by s.customer_id;


--If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

--First CTE--
with points as (
select s.customer_id, s.product_id, count(s.product_id) as items_count
from sales as s
left join menu as m
on s.product_id = m.product_id
group by s.customer_id, s.product_id, m.price
),
--Second CTE--
points_pool as (select p.customer_id, p.product_id,
CASE
when p.product_id = 1 then p.items_count*200
when p.product_id = 2 then p.items_count*150
when p.product_id = 3 then p.items_count*120
else p.items_count*0 end as points_pool
from points as p)
--Final Query--
Select p_p.customer_id, sum(p_p.points_pool) as total_points
from points_pool as p_p
group by p_p.customer_id;


--In the first week after a customer joins the program (including their join date) they earn 2x points on all items,
--not just sushi - how many points do customer A and B have at the end of January?

--First CTE--
with points as (
select s.customer_id, s.product_id, count(s.product_id) as items_count, s.order_date
from sales as s
left join menu as m
on s.product_id = m.product_id
where s.order_date < '2021-01-31' and s.order_date >= '2021-01-07'
and s.customer_id <> 'C'
group by s.customer_id, s.product_id, m.price, s.order_date),
--Second CTE--
points_pool as (select p.customer_id, p.product_id, p.order_date,
CASE
when p.order_date >= '2021-01-07' and p.order_date <= '2021-01-16' and p.product_id = 1 then p.items_count*200
when p.order_date >= '2021-01-07' and p.order_date <= '2021-01-16' and p.product_id = 2 then p.items_count*300
when p.order_date >= '2021-01-07' and p.order_date <= '2021-01-16' and p.product_id = 3 then p.items_count*240
else p.items_count*0 end as points_pool
from points as p
)
--Final Query--
select p_p.customer_id, sum(p_p.points_pool) as total_points
 from points_pool as p_p
 group by p_p.customer_id
 order by p_p.customer_id

--COMMENT--
--Taking into account the fact that all of the dates are included in first week promotion, it is not neccesery to write another CTE 
--with the dates that are not included in first week promotion--


--Select all customers, order dates, product names and prices and verify whether the customer was a member or not when the order was placed.  
select s.customer_id, s.order_date, m.product_name, m.price,
    CASE
    when s.order_date >= me.join_date then 'YES'
    else 'NO' end as member
from sales as s
left join menu as m 
on s.product_id = m.product_id
left join members as me
on s.customer_id = me.customer_id
order by s.customer_id, s.order_date


