
with stg as (

    select * from {{ ref('stg_stores') }}

),

final as (

    select
        store_id,
        store_name,
        city,
        country,
        region,
        opened_date

    from stg

)

select * from final