
with stg as (

    select * from {{ ref('stg_products') }}

),

final as (

    select
        product_id,
        product_name,
        category,
        subcategory,
        list_price - cost_price as unit_margin

    from stg

)

select * from final