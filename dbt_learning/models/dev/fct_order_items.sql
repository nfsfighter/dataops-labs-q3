{{ config(
    materialized='incremental',
    unique_key='order_item_id'
) }}

with order_items as (

    select * from {{ ref('stg_order_items') }}

),

orders as (

    select * from {{ ref('stg_orders') }}

),

products as (

    select * from {{ ref('stg_products') }}

),

joins as (

    select
        order_items.*,
        orders.customer_id,
        orders.store_id,
        orders.order_date,
        orders.order_status,
        products.cost_price

    from order_items
    left join orders on order_items.order_id = orders.order_id
    left join products on order_items.product_id = products.product_id

),

facts as (

    select
        oi.*,
        oi.quantity * oi.price                                     as gross_amount,
        oi.quantity * oi.price * oi.discount / 100                 as discount_amount,
        {{ net_amount('oi.quantity', 'oi.price', 'oi.discount') }}::numeric(12,2)           as net_amount,
        oi.quantity * oi.cost_price                                      as total_cost,
        {{ net_amount('oi.quantity', 'oi.price', 'oi.discount') }}
            - (quantity * cost_price)                               as margin

    from joins as oi

)

select * from facts

{% if is_incremental() %}
where order_item_id > (select coalesce(max(order_item_id), 0) from {{ this }})
{% endif %}