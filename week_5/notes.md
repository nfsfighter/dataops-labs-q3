🔍 Report what you actually measure. This is a 313-row table, so the numbers will be small (single-digit milliseconds) and the planner may well still choose a sequential scan — on tiny tables a seq scan is genuinely cheaper than an index lookup. "No meaningful improvement, because the table is too small for the planner to bother" is a correct and full-credit answer, as long as it's backed by your real numbers. Run each query two or three times and use the later timings; the first run pays for a cold cache.

## Query tested
```sql
explain analyze
select *
from "DEV".fct_order_items f
join "DEV".fct_orders o on f.order_id = o.order_id;
```

### Additionally, built whole model without index first and then built again with an index , instead of using (drop index if exists "DEV".idx_fct_order_items_order_id;) for before state.

## Run 1: cold cache (first execution after each change)
| | With index | Without index |
|---|---|---|
| Scan type | Seq Scan (both) | Seq Scan (both) |
| Planning Time | 25.814 ms | 7.464 ms |
| Execution Time | 1.376 ms | 2.417 ms |

## Run 2: steady state (subsequent execution)
| | With index | Without index |
|---|---|---|
| Scan type | Seq Scan (both) | Seq Scan (both) |
| Planning Time | 1.360 ms | 0.396 ms |
| Execution Time | 2.004 ms | 1.525 ms |

## Interpretation
Postgres chose a Seq Scan on both `fct_order_items` (313 rows) and
`fct_orders` (155 rows) in every run, with or without the index.
At this table size, a sequential scan is cheaper than an index
lookup, so the planner never used the index, the optimizer is
cost-based, and index overhead doesn't pay off until tables are
much larger than a few hundred rows.

The clearest cold-cache effect is in Planning Time, not Execution
Time: the first query after dropping/recreating the index took
7–26 ms to plan, versus under 2 ms on the following run, as
Postgres pulled catalog and statistics pages into memory for the
first time. 
Execution Time itself stayed in the same low-single ms range across all four runs, and the with-index run
was not consistently faster than the without-index run — in Run 1
it was actually faster, and in Run 2 slower, confirming the
timing differences are normal run-to-run noise rather than any
real effect of the index.



