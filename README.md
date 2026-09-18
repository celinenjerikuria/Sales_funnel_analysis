# Sales Funnel Analysis

A SQL-based analysis of a 5-stage e-commerce sales funnel — page view → add to cart → checkout → payment → purchase — examining where users drop off, how traffic sources compare, and the revenue generated at each stage.

## Overview

Using a raw events table (`user_events`), this project builds a series of SQL queries to answer:
- How many users make it through each stage of the funnel, and where is the biggest drop-off?
- How do conversion rates differ by traffic source?
- How long does it take converted users to move from viewing to purchasing?
- What's the revenue impact — average order value, revenue per buyer, and revenue per visitor?

## Key Findings

- Of 5,000 users who viewed a page, **826 completed a purchase** — an overall conversion rate of **16.52%**.
- The biggest drop-off is early in the funnel: only **31.06%** of viewers add an item to cart. Once in the cart, however, users convert much more reliably — **71.02%** proceed to checkout, and **91.88%** of those who reach payment go on to purchase.
- **Email traffic converts best**: a 33.91% views-to-purchase rate, more than 4x higher than social traffic (6.93%).
- Converted users take an average of **24.63 minutes** from first page view to purchase — about 11 minutes to add to cart, then 13 minutes from cart to purchase.
- Total revenue across all purchases was **87,975**, with an average order value of **106.51**.
- **All 826 buyers purchased exactly once** — there were no repeat purchases in this dataset, meaning the entire revenue figure comes from one-time conversions.
- **Product 205** generated the most revenue (15,905) despite Product 404 having more views — its higher purchase count (147 vs. 141) made the difference. Revenue across the 6 products was fairly even overall (~13,900–15,900 each), with no single product dominating.
- **Data quality check**: the `amount` field is fully populated (no NULLs) across all event types, not just `purchase` — non-purchase events carry a value of 0 rather than a missing value. Worth knowing if replicating this analysis on a different dataset, since a NULL-based `amount` field would require different handling in the revenue queries.

## Tools

- SQL (window functions, CTEs, conditional aggregation)


## How to Reproduce

Run the queries in `Sales_funnel_query.sql` against a `user_events` table with columns: `event_id`, `user_id`, `event_type`, `event_date`, `product_id`, `amount`, `traffic_source`.
