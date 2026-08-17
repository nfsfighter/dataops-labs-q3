-- snapshots/example_snap_products.sql
-- ──────────────────────────────────────────────────────────────
-- EXAMPLE: This shows the general pattern for a dbt snapshot.
-- Your task is to create a REAL snapshot file called snap_products.sql
-- that tracks price and active-status changes on the products table.
-- ──────────────────────────────────────────────────────────────
--
-- The example below is wrapped in a Jinja comment {# ... #} so dbt ignores it
-- entirely — otherwise dbt would try to parse this guide as a real snapshot
-- and fail. Copy the pattern into your own snap_products.sql (without the
-- comment wrapper and the leading -- markers).
--
{#
    {% snapshot snap_products %}

        {{
            config(
                target_schema='RAW',
                unique_key='product_id',
                strategy='check',
                check_cols=['list_price', 'is_active']
            )
        }}

        select * from {{ ref('raw_products') }}

    {% endsnapshot %}
#}
--
-- STRATEGY OPTIONS:
--   'check'     → compares specific columns to detect changes
--   'timestamp' → uses an updated_at column to detect changes
--
-- After running `dbt snapshot`, dbt adds these columns automatically:
--   dbt_scd_id       → unique ID for each version
--   dbt_updated_at   → when dbt last checked this row
--   dbt_valid_from   → when this version became active
--   dbt_valid_to     → when this version was replaced (null = current)