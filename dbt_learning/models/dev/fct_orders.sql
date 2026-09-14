with orders as (

    select *
    from {{ ref('stg_orders') }}

),

order_items as (

    select *
    from {{ ref('fct_order_items') }}

),

item_rollup as (

    select
        order_id,
        count(*) as num_line_items,
        sum(quantity) as total_quantity,
        sum(net_amount) as net_revenue

    from order_items

    group by order_id

),

final as (

    select
        o.order_id,
        o.order_status,
        o.customer_id,
        o.store_id,
        o.order_date,
        o.shipping_fee,

        coalesce(r.num_line_items, 0) as num_line_items,
        coalesce(r.total_quantity, 0) as total_quantity,
        coalesce(r.net_revenue, 0) as net_revenue,

        coalesce(r.net_revenue, 0)
            + coalesce(o.shipping_fee, 0) as order_total

    from orders o

    left join item_rollup r
        on o.order_id = r.order_id

)

select *
from final