{{ config(
    materialized='table',
    cluster_by=['workspace_id'],
    partition_by={
        "field": "started_on",
        "data_type": "date"
    } 
) }}

select *
from {{ ref('stg_subscription_periods') }}