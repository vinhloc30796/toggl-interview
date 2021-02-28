
{{ config(
    materialized='table',
    partition_by={
      "field": "created_at",
      "data_type": "timestamp"
    } 
) }}



select *
from {{ source('sources', 'users') }}
