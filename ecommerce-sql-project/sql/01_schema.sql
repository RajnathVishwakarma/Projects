-- =====================================================================
-- E-Commerce Sales Analysis — Database Schema
-- Author : Rajnath Vishwakarma
-- Engine : MySQL 8.0+ (uses window functions — see 03_business_queries.sql)
-- =====================================================================
-- Entity Relationship Overview
--
--   customers (1) ───< orders (1) ───< orderdetails >─── (1) products
--
--   One customer places many orders.
--   One order can contain many line items (orderdetails).
--   One product can appear in many order line items.
-- =====================================================================

create database if not exists ecommerce_analysis;
use ecommerce_analysis;

-- Drop tables in FK-safe order for clean re-runs
drop table if exists orderdetails;
drop table if exists orders;
drop table if exists products;
drop table if exists customers;

-- ---------------------------------------------------------------------
-- customers : master list of registered customers
-- ---------------------------------------------------------------------
create table customers (
    customer_id     int primary key,
    name            varchar(100) not null,
    location        varchar(50)  not null
);

-- ---------------------------------------------------------------------
-- products : product catalog
-- ---------------------------------------------------------------------
create table products (
    product_id      int primary key,
    name            varchar(100) not null,
    category        varchar(50)  not null,
    price           decimal(10,2) not null
);

-- ---------------------------------------------------------------------
-- orders : one row per order placed (order-level summary)
-- ---------------------------------------------------------------------
create table orders (
    order_id        int primary key,
    order_date      date not null,
    customer_id     int not null,
    total_amount    decimal(12,2) not null,
    constraint fk_orders_customer
        foreign key (customer_id) references customers(customer_id)
);

-- ---------------------------------------------------------------------
-- orderdetails : line items within an order (order <-> product)
-- Note: a product can appear more than once within the same order
-- (e.g. added to cart in separate batches), so the natural key
-- (order_id, product_id) is NOT unique — a surrogate key is used.
-- ---------------------------------------------------------------------
create table orderdetails (
    order_detail_id int primary key auto_increment,
    order_id        int not null,
    product_id      int not null,
    quantity        int not null,
    price_per_unit  decimal(10,2) not null,
    constraint fk_orderdetails_order
        foreign key (order_id) references orders(order_id),
    constraint fk_orderdetails_product
        foreign key (product_id) references products(product_id)
);

-- Helpful indexes for the analytical queries in 03_business_queries.sql
create index idx_orders_customer_id   on orders(customer_id);
create index idx_orders_order_date    on orders(order_date);
create index idx_orderdetails_order   on orderdetails(order_id);
create index idx_orderdetails_product on orderdetails(product_id);
