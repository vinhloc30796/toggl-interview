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
    -- Find only the first session
    where session_order = 1
)

select 
    users.user_id,
    users.created_at,
    users.activated_at,
    users.deleted_at,
    first_sessions.date as fta_date,
    first_sessions.campaign as fta_campaign,
    first_sessions.source as fta_source,
    first_sessions.medium as fta_medium,
from sources_users as users
left join stg_ga_sessions as first_sessions
    on users.user_id = first_sessions.user_id -- Some users have no sessions