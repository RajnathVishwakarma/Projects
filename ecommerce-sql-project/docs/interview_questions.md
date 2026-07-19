# Interview Prep — E-Commerce SQL Project

A set of questions an interviewer is realistically likely to ask about this project, grouped by theme. Answers are written the way you'd actually say them out loud — short, specific, and tied back to a decision you made in the repo.

---

## Project Design & Data Modeling

**1. Walk me through your schema. Why four tables instead of one flat table?**
The data has three natural entities — customers, products, and orders — plus a many-to-many relationship between orders and products, which is what `orderdetails` resolves. One flat table would repeat customer and product info on every row, waste storage, and make updates error-prone (classic update anomaly). Splitting it out is basic 3NF normalization: each fact lives in exactly one place.

**2. Why does `orderdetails` use a surrogate key instead of `(order_id, product_id)` as a composite primary key?**
Because it isn't actually unique in this data — I found 62 orders where the same product appears as two separate line items (e.g., added to the cart at different times). A composite key would have made those inserts fail. I caught this during EDA before writing the schema, not after hitting an error, which is the point — check your assumptions about uniqueness against the actual data.

**3. Why keep `price_per_unit` in `orderdetails` when `products.price` already has it?**
It's a deliberate denormalization. Product prices can change over time; storing the price *at the time of the transaction* in the fact table preserves historical accuracy for revenue calculations even if `products.price` is updated later. In this dataset the values happen to match, but the design should hold up even if they didn't.

**4. What indexes did you add, and why those specifically?**
`orders.customer_id`, `orders.order_date`, `orderdetails.order_id`, and `orderdetails.product_id` — these are exactly the columns used in JOIN conditions and WHERE/GROUP BY clauses across the analysis queries. Indexing columns that are actually filtered or joined on is the useful default; indexing everything just slows down writes for no benefit.

---

## SQL Technique

**5. Explain the window function you used for month-on-month % change.**
`LAG(total_sales) OVER (ORDER BY sales_month)` pulls the previous row's value into the current row without a self-join. Then `(current - previous) / previous * 100` gives the percentage change. The alternative — a self-join on "month - 1" — is more verbose and easy to get wrong with month/year boundaries; `LAG()` handles ordering for you.

**6. Why CTEs instead of subqueries or temp tables?**
Readability and reuse within a single statement. A query like the month-on-month growth one has two logical steps — first aggregate by month, then compute the window function on that aggregate — and a CTE lets me name and separate those steps instead of nesting a subquery three levels deep. I'd reach for a temp table only if I needed to reuse the same intermediate result across multiple separate statements.

**7. What's the difference between `WHERE` and `HAVING`, and where did you need `HAVING`?**
`WHERE` filters rows before aggregation; `HAVING` filters groups after `GROUP BY`/aggregation. I used it in the "premium product" query — I need `AVG(quantity)` computed first, per product, and then to filter on that averaged value, which is only possible after the group is formed.

**8. How would you find the top N products per category instead of overall?**
Add `ROW_NUMBER() OVER (PARTITION BY category ORDER BY total_revenue DESC)` in a CTE, then filter `WHERE row_num <= N` in the outer query. The `PARTITION BY` resets the ranking within each category instead of ranking across the whole table.

**9. Your turnover-rate query divides by `DATEDIFF(last_sale, first_sale) + 1`. What happens if a product only sold once?**
The DATEDIFF is 0, so `+1` avoids a divide-by-zero and treats it as "sold within 1 active day." It's a reasonable guard, but worth being upfront about: with only one data point, a "velocity" number is a weak signal — I'd flag it rather than let it rank misleadingly high, and I've noted that as a caveat in the README.

**10. How would you get this to run on PostgreSQL instead of MySQL?**
Two syntax swaps: `DATE_FORMAT(order_date, '%Y-%m')` → `TO_CHAR(order_date, 'YYYY-MM')`, and `DATEDIFF(a, b)` → `a - b` (Postgres date subtraction returns an integer directly). The CTEs and window functions (`LAG`, `SUM() OVER`) are standard ANSI SQL and need no changes.

---

## Business Reasoning

**11. Which insight from this project would you act on first, and why?**
The deceleration in customer acquisition — cumulative new-customer growth fell from +164% in month two to +1% by the last month. Everything else (top cities, top products) tells you where value already is; this one tells you the pipeline that creates *future* value is drying up, which is the more urgent problem for a growth team.

**12. You flagged February 2024 as a likely partial month. Why does that matter?**
Because it's the sharpest "decline" in the dataset (−74.5%), and if someone read that number without checking whether the month is complete, they could conclude sales are collapsing when it might just be the data cutoff. Good analysis means checking whether a data point deserves the weight you're about to put on it — I'd re-run that query excluding the current partial month before presenting it as a trend.

**13. What additional data would make this analysis stronger?**
Cost/margin data (to know if "top revenue" products are actually the most profitable), marketing spend by channel/month (to explain the sales spikes in July and September instead of just observing them), and customer acquisition channel (to see which channels are driving the customers acquired early vs. late).

**14. If a stakeholder asked "why did sales drop in month X," how would you actually investigate it in SQL, beyond what's in this repo?**
Break the aggregate down: is it fewer orders, or the same number of orders at lower value? Is it concentrated in one city or category, or broad-based? Did specific customers who normally order stop ordering that month? I'd write a drill-down query segmenting that month's orders by category and city and compare it to the prior month's same breakdown, rather than trying to explain a single aggregate number in isolation.

**15. How did you decide the thresholds for "One-Time / Repeat / Loyal" customer segments?**
I looked at the actual distribution first rather than picking round numbers blindly — order counts ranged 1 to 8, with a natural drop-off after 3 orders (18 customers at 3 orders vs. 6 at 4). I set the boundary there. It's a reasonable starting segmentation, not a definitive one — a real team would likely validate it against retention or revenue-per-segment data before using it operationally.

---

## General SQL Fundamentals (likely warm-up questions)

**16. What's the difference between `INNER JOIN` and `LEFT JOIN`, and which did you use in this project?**
`INNER JOIN` only returns rows with a match in both tables; `LEFT JOIN` keeps every row from the left table even without a match, filling unmatched columns with NULL. I used `INNER JOIN` throughout the business queries because I only want products/orders that actually have matching transactions — but I used a `LEFT JOIN` during EDA specifically to check for orphaned records (e.g., orders with no matching customer), where NULLs are the useful signal.

**17. What's the difference between `COUNT(*)` and `COUNT(DISTINCT column)`?**
`COUNT(*)` counts all rows in the group, including duplicates. `COUNT(DISTINCT customer_id)` counts unique customers only — I needed this specifically for the "unique customers per category" query, since one customer can buy from the same category multiple times and I don't want to count them twice.

**18. What's a primary key vs. a foreign key, in your schema specifically?**
Primary keys uniquely identify a row in its own table (`customer_id` in `customers`). Foreign keys reference a primary key in another table to enforce that the relationship is valid — `orders.customer_id` must exist in `customers.customer_id`, which is what stops an order from being inserted for a customer that doesn't exist.

---


