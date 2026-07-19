-- =====================================================================
-- E-Commerce Sales Analysis — Business Queries
-- Run AFTER 01_schema.sql and 02_seed_data.sql
-- Engine: MySQL 8.0+ (uses window functions: LAG, SUM OVER)
-- =====================================================================
use ecommerce_analysis;

-- =====================================================================
-- 0. DATA OVERVIEW — quick look at every table
-- =====================================================================
select * from customers limit 5;
select * from products;
select * from orders limit 5;
select * from orderdetails limit 5;

select
    (select count(*) from customers)    as total_customers,
    (select count(*) from products)     as total_products,
    (select count(*) from orders)       as total_orders,
    (select count(*) from orderdetails) as total_line_items,
    (select min(order_date) from orders) as first_order_date,
    (select max(order_date) from orders) as last_order_date;


-- =====================================================================
-- 1. TOP 3 CITIES BY NUMBER OF CUSTOMERS
-- Business question: which cities are our key markets?
-- =====================================================================
select
    location,
    count(*) as customer_count
from customers
group by location
order by customer_count desc
limit 3;

/* Insight: Delhi (16), Chennai (15) and Jaipur (11) together hold ~42% 
of the customer base. These three cities should be the priority focus
for targeted marketing spend and regional logistics/warehouse planning. */


-- =====================================================================
-- 2. ORDER FREQUENCY DISTRIBUTION (Engagement Depth Analysis)
-- Business question: how many customers fall into each order-count bucket?
-- =====================================================================
with customer_orders as (
    select customer_id, count(order_id) as num_orders
    from orders
    group by customer_id
)
select
    num_orders as orders_placed,
    count(customer_id) as num_customers
from customer_orders
group by num_orders
order by num_orders;

-- 2b. Engagement segment summary (One-Time / Repeat / Loyal)
with customer_orders as (
    select customer_id, count(order_id) as num_orders
    from orders
    group by customer_id
)
select
    case
        when num_orders = 1 then 'one-time buyer'
        when num_orders between 2 and 3 then 'repeat buyer'
        else 'loyal customer'
    end as engagement_category,
    count(*) as num_customers
from customer_orders
group by engagement_category
order by num_customers desc;

/* Insight: As order count increases, the number of customers in that
bucket shrinks steadily (26 -> 26 -> 18 -> 6 -> 6 -> 1 -> 1), a classic
funnel/long-tail pattern. Grouped into segments, "Repeat Buyers" (2-3
rders) are the largest group at 44 customers (52% of active buyers),
while only 14 customers (17%) qualify as "Loyal" (4+ orders) — the
biggest growth opportunity is converting Repeat Buyers into Loyal ones. */


-- =====================================================================
-- 3. PREMIUM PRODUCT TREND
-- Business question: products with ~2 avg units/order but high revenue
-- =====================================================================
select
    p.product_id,
    p.name,
    p.category,
    round(avg(od.quantity), 2) as avg_qty_per_order,
    sum(od.quantity * od.price_per_unit) as total_revenue
from orderdetails od
join products p on p.product_id = od.product_id
group by p.product_id, p.name, p.category
having round(avg(od.quantity), 0) = 2
order by total_revenue desc;

/*Insight: Laptop 15" Pro (avg 1.88 units/order) and Digital SLR Camera
(avg 1.94 units/order) generate the highest revenue (₹75.6L and ₹60.4L)
despite customers buying close to the same ~2 units per order as
everything else. Revenue here is being driven by high unit price, not
volume — a textbook premium/luxury purchase pattern worth protecting
with premium-tier marketing rather than discount-driven promotions. */


-- =====================================================================
-- 4. UNIQUE CUSTOMERS PER PRODUCT CATEGORY (Category Reach)
-- =====================================================================
select
    p.category,
    count(distinct o.customer_id) as unique_customers
from orderdetails od
join products p  on p.product_id = od.product_id
join orders o    on o.order_id   = od.order_id
group by p.category
order by unique_customers desc;

-- Insight: Electronics reaches 79 unique customers — by far the widest
-- appeal — followed by Wearable Tech (61) and Photography (45).
-- Electronics is the category that needs continued focus/investment
-- since it already drives the broadest customer engagement.


-- =====================================================================
-- 5. MONTH-ON-MONTH % CHANGE IN TOTAL SALES
-- =====================================================================
with monthly_sales as (
    select
        date_format(order_date, '%y-%m') as sales_month,
        sum(total_amount) as total_sales
    from orders
    group by sales_month
)
select
    sales_month,
    total_sales,
    round(
        (total_sales - lag(total_sales) over (order by sales_month)) * 100.0
        / lag(total_sales) over (order by sales_month), 2
    ) as pct_change
from monthly_sales
order by sales_month;

-- Insight: Sales are highly volatile month to month, swinging between
-- +146.92% (Jul-23) and -74.53% (Feb-24). The steepest decline is
-- Feb-2024, where sales fell from ₹15.55L to just ₹3.96L — the largest
-- single-month drop in the dataset (see query 6 below).


-- =====================================================================
-- 6. MONTH WITH THE LARGEST SALES DECLINE
-- =====================================================================
with monthly_sales as (
    select
        date_format(order_date, '%y-%m') as sales_month,
        sum(total_amount) as total_sales
    from orders
    group by sales_month
),
mom_change as (
    select
        sales_month,
        total_sales,
        round(
            (total_sales - lag(total_sales) over (order by sales_month)) * 100.0
            / lag(total_sales) over (order by sales_month), 2
        ) as pct_change
    from monthly_sales
)
select sales_month, total_sales, pct_change
from mom_change
order by pct_change asc
limit 1;

-- Insight: February 2024 saw the largest decline at -74.53%. Because
-- this is also the last month in the dataset, it may reflect a partial
-- month of data rather than a genuine demand collapse — worth flagging
-- before drawing firm conclusions (see README "Caveats" section).


-- =====================================================================
-- 7. MONTH-ON-MONTH AVERAGE ORDER VALUE (AOV) TREND
-- =====================================================================
with monthly_aov as (
    select
        date_format(order_date, '%y-%m') as sales_month,
        round(avg(total_amount), 2) as avg_order_value
    from orders
    group by sales_month
)
select
    sales_month,
    avg_order_value,
    round(
        avg_order_value - lag(avg_order_value) over (order by sales_month), 2
    ) as change_vs_prev_month
from monthly_aov
order by sales_month;

-- Insight: AOV climbed steadily from ~₹60.7K (Mar-23) to a peak of
-- ~₹132.1K (Dec-23) — customers were buying higher-value baskets over
-- time, not just more often. This supports upselling/bundling
-- strategies around the Nov-Dec period specifically.


-- =====================================================================
-- 8. PRODUCT TURNOVER RATE (sales velocity)
-- Defined as: total units sold / number of active days between a
-- product's first and last sale in the dataset. Higher = faster mover.
-- =====================================================================
with product_sales as (
    select
        od.product_id,
        p.name,
        sum(od.quantity) as total_qty_sold,
        min(o.order_date) as first_sale,
        max(o.order_date) as last_sale
    from orderdetails od
    join orders o    on o.order_id   = od.order_id
    join products p  on p.product_id = od.product_id
    group by od.product_id, p.name
)
select
    product_id,
    name,
    total_qty_sold,
    datediff(last_sale, first_sale) + 1 as active_days,
    round(total_qty_sold / (datediff(last_sale, first_sale) + 1), 4) as units_sold_per_day
from product_sales
order by units_sold_per_day desc;

-- Insight: Digital SLR Camera has the fastest turnover (0.42 units/day)
-- despite being the highest-priced item after the Laptop — it should be
-- prioritized for frequent restocking to avoid stockouts. Smartphone 6"
-- has the slowest turnover (0.32 units/day) and can be restocked on a
-- longer cycle.


-- =====================================================================
-- 9. PRODUCTS PURCHASED BY LESS THAN 40% OF THE CUSTOMER BASE
-- =====================================================================
select
    p.product_id,
    p.name,
    count(distinct o.customer_id) as unique_buyers,
    round(
        count(distinct o.customer_id) * 100.0 / (select count(*) from customers), 2
    ) as pct_of_customer_base
from orderdetails od
join products p on p.product_id = od.product_id
join orders o   on o.order_id   = od.order_id
group by p.product_id, p.name
having pct_of_customer_base < 40
order by pct_of_customer_base asc;

-- Insight: Smartphone 6" (36%) and Wireless Earbuds (38%) are reaching
-- fewer than 4 in 10 customers — a possible mismatch between what's
-- stocked/promoted and actual customer interest, or simply strong
-- competition in those specific sub-categories worth investigating.


-- =====================================================================
-- 10. MONTH-ON-MONTH GROWTH IN CUSTOMER BASE
-- Defined as growth in the *cumulative* count of customers who have
-- placed at least one order by the end of each month.
-- =====================================================================
with first_order as (
    select customer_id, date_format(min(order_date), '%y-%m') as first_month
    from orders
    group by customer_id
),
new_customers_per_month as (
    select first_month, count(*) as new_customers
    from first_order
    group by first_month
),
cumulative as (
    select
        first_month,
        new_customers,
        sum(new_customers) over (order by first_month) as cumulative_customers
    from new_customers_per_month
)
select
    first_month,
    new_customers,
    cumulative_customers,
    round(
        (cumulative_customers - lag(cumulative_customers) over (order by first_month)) * 100.0
        / lag(cumulative_customers) over (order by first_month), 2
    ) as growth_rate_pct
from cumulative
order by first_month;

-- Insight: Customer acquisition is decelerating hard — cumulative base
-- growth fell from +163.64% (Apr-23) to just +1.20% (Feb-24). Roughly
-- 70% of all customers who ever ordered (59 of 84) had already made
-- their first purchase within the first 5 months (Mar-Jul 2023). This
-- is a strong signal to increase acquisition spend rather than assume
-- organic growth will continue at the early pace.


-- =====================================================================
-- 11. MONTHS WITH THE HIGHEST SALES VOLUME
-- =====================================================================
select
    date_format(order_date, '%y-%m') as sales_month,
    sum(total_amount) as total_sales,
    count(order_id) as num_orders
from orders
group by sales_month
order by total_sales desc
limit 3;

-- Insight: September 2023 (₹29.27L), December 2023 (₹27.74L) and
-- July 2023 (₹25.68L) were peak months. December aligns with a natural
-- holiday-shopping season; September and July are worth investigating
-- for repeatable causes (campaigns, promotions) that can be scheduled
-- deliberately in future planning cycles.
