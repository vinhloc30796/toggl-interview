
{{ config(
    materialized='table',
    partition_by={
        "field": "created_at",
        "data_type": "timestamp"
    } 
) }}


with
sources_users as (
    select *
    from {{ source('sources', 'users') }}
)

select * 
from sources_users