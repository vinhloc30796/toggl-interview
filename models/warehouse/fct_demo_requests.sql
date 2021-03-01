{{ config(
    materialized='table',
    cluster_by=["user_id"],
    partition_by={
        "field": "date",
        "data_type": "date"
    } 
) }}

select
    session_id,
    user_id,
    date,
from {{ ref('stg_ga_sessions') }}
where requested_demo = True