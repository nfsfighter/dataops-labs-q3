-- tests/test_net_amount_non_negative.sql
{{ config(severity='warn') }}

select *
from {{ ref('fct_order_items') }}
where net_amount < 0