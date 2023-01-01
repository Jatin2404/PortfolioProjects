1. What is Total Amount each customer Spend on Zomato
select b.userid,sum(a.price) 
from Zomato_Project..product a join Zomato_Project..sales b 
on a.product_id= b.product_id 
group by b.userid

2. How many days each customer visited Zomato?

select userid,count(created_date) 
from Zomato_Project..sales 
group by userid

3. What was the first product purchased by each customer?

select * from 
(select * ,rank() over(partition by userid order by created_date) rnk from Zomato_Project..sales) a where rnk=1

4. What is the most purchased item on the menu and how many time it purchased  by all Customer?

select userid,count(product_id) cnt from sales where product_id=
(select top 1 product_id from sales group by product_id order by count(product_id)  desc)
group by userid

5. Which item was most popular for each customer?
select * from
(select *,rank() over(partition by userid order by cnt desc)rnk from
(select userid, product_id,count(product_id) cnt from sales group by userid,product_id)a)b
where rnk=1

6. Which item was purchased first by the customer after they become a member?

select * from
(select c.* ,rank() over(partition by userid order by created_date)rnk from
(select a.*,b.product_id,b.created_date 
from Zomato_Project..goldusers_signup a left outer join Zomato_Project..sales b 
on a.userid=b.userid and b.created_date>a.gold_signup_date)c)d where rnk=1

7. Which item is just purchased by customer before become a member?

select * from
(select c.* ,rank() over(partition by userid order by created_date)rnk from
(select a.*,b.product_id,b.created_date 
from Zomato_Project..goldusers_signup a left outer join Zomato_Project..sales b 
on a.userid=b.userid and b.created_date<=a.gold_signup_date)c)d where rnk=1
	 
8. What is the total order and amount spent for each member before they become a member?
select * from Zomato_Project..sales

select userid,count(created_date) as Total_Order,sum(price) as Total_Amt from
(select d.*,c.price from
(select a.*,b.created_date,b.product_id
from Zomato_Project..goldusers_signup a left outer join Zomato_Project..sales b 
on a.userid=b.userid  and b.created_date<=a.gold_signup_date) d  join  Zomato_Project..product c
on c.product_id=d.product_id )e group by userid

9. If buying each product generates points for eg 5rs=2 zomato points each product has different purchasing points 
   for eg: p1 5rs= 1 zomato point,p2 10rs= 5 zomato points and p3 5rs= 1 Zoamato Points
   calculate points collected by each customer and for which product most points have been given till now ?

select f.userid,f.Total_Points_Collected,Total_Points_Collected*2.5 as Cashback_Earn from
(select e.userid,sum(e.Rewards) as Total_Points_Collected from
(select d.*,d.Total_price/d.Points as Rewards from
(select c.userid,c.product_id,case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 else 0 end as Points,
sum(c.price) as Total_price from
(select b.*,a.price
from Zomato_Project..product a inner join Zomato_Project..sales b 
on a.product_id=b.product_id )c group by c.userid,c.product_id )d )e group by e.userid)f group by f.userid,f.Total_Points_Collected
 
 --For Second Question
 select e.product_id,sum(e.Rewards) from
 (select d.*,d.Total_price/d.Points as Rewards from
(select c.userid,c.product_id,case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 else 0 end as Points,
sum(c.price) as Total_price from
(select b.*,a.price
from Zomato_Project..product a inner join Zomato_Project..sales b 
on a.product_id=b.product_id )c group by c.userid,c.product_id )d)e group by e.product_id

10. In the first one year after a customer joins the gold program (including thier join date ) irrespective of what the customer has purchased they earn 5 Zomato points 
for every 10rs spend who earned more 1 or 3 and what was thier points earning in their first year?

--1 ZP=2rs
select c.*,d.price,d.price/2 as Total_points_earned from
(select a.*,b.created_date,b.product_id
from Zomato_Project..goldusers_signup a  join Zomato_Project..sales b 
on a.userid=b.userid and a.gold_signup_date<=b.created_date and DATEADD(year,1,a.gold_signup_date)>=b.created_date)c
join Zomato_Project..product d on c.product_id=d.product_id

11.Rank all the transaction of the customer?

select *,rank() over(partition by userid order by created_date)Rank from Zomato_Project..sales

12. Rank all the transaction for each member whenever they are a zomato gold member,for every non gold member transaction mark as NA?

select e.*,case when rnk=0 then 'NA' else rnk end as rnk from
(select c.*,cast(case when c.gold_signup_date is null then 0 else rank() over(partition by c.userid order by c.created_date desc)end as varchar)as rnk from
(select a.*,b.gold_signup_date from Zomato_Project..sales a left join Zomato_Project..goldusers_signup b
on a.userid=b.userid and a.created_date>=b.gold_signup_date)c)e
