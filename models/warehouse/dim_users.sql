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
),

stg_ga_sessions as (
    select *
    from {{ ref('stg_ga_sessions') }}
),

inter_ga_sessions_first_dates as (
    -- Find the first session dates for each user
    select
        user_id,
        min(date) as first_session_at,
    from stg_ga_sessions
    group by 1
),

users_attributions as (
    select
        *
    from sources_users
)

select * 
from users_attributions