with orders as (

    select * from {{ ref('stg_orders') }}

),

final as (

select
    order_id,
    order_status,
    shipping_fee,
    count(order_id) over (partition by order_status)      as orders_in_status,
    sum(shipping_fee) over (partition by order_status)     as total_shipping_by_status
from orders


)

select * from final
