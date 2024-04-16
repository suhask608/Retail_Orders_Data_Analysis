select * from df_orders;

-- KPIs --
-- find top 10 highest revenue generating products.
select top 10 product_id, sum(sales_price) as sales
from df_orders
group by product_id
order by sales desc;

-- find the top 5 highest selling products in each region.
with cte as(
select region, product_id, sum(sales_price) as sales
from df_orders
group by region, product_id
),
cte2 as(
select *,
row_number() over(partition by region order by sales desc) as rn
from cte)
select * from cte2
where rn<=5;

-- find the month over month growth comparision for 2022 & 2023 sales eg: jan 2022 vs jan 2023
with cte as(
select year(order_date) as Year, month(order_date) as Month, sum(sales_price)as Sales
from df_orders
group by year(order_date), month(order_date)
--order by year(order_date), month(order_date)
)
select Month,
sum(case when Year=2022 then Sales else 0 end) as Sales_2022,
sum(case when Year=2023 then Sales else 0 end) as Sales_2023
from cte
group by Month;

-- for each category which month has highest sales.
with cte as(
select category, month(order_date) as Month, sum(sales_price) as Sales
from df_orders
group by category, month(order_date)
),
cte2 as(
select *,
row_number() over(partition by category order by Sales desc) as rn
from cte)
select * from cte2
where rn=1;

--which highest sub-category had highest growth by profit in 2023 compare to 2022
with cte as(
select sub_category, year(order_date) as Year, sum(sales_price) as Sales
from df_orders
group by sub_category, year(order_date)
),
cte2 as
(
select sub_category, 
sum(case when Year=2022 then Sales else 0 end) as sales_2022,
sum(case when Year=2023 then Sales else 0 end) as sales_2023
from cte
group by sub_category
)
select top 1 *,
round((sales_2023 - sales_2022) * 100.00 / sales_2022,2) as grouth_percentage
from cte2
order by round((sales_2023 - sales_2022) * 100.00 / sales_2022,2) desc


