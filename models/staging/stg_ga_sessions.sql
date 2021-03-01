{{ config(
    materialized='table',
    incremental_strategy='insert_overwrite',
    cluster_by="user_id",
    partition_by={
        "field": "date",
        "data_type": "date",
    }, 
) }}

with
-- Get necessary columns
-- and deduplicate data based on those columns
deduped_ga_sessions as (
    select
        -- Remove session_id because it's not useful as a unique identifier,
        -- nor is it useful as a timestamp.
        -- session_id,
        user_id,
        date,
        campaign,
        split(source_medium, ' / ')[offset(0)] as source,
        split(source_medium, ' / ')[offset(1)] as medium,
        requested_demo,
    from {{ source('sources', 'ga_sessions') }}
    -- Because we only care about signups, demo requests, 
    -- trials, paid workspaces, and monthly recurring revenue,
    -- we don't care about sessions that haven't been tied to a user_id.
    where user_id is not null
    -- Group by the above 6 columns
    -- to deduplicate
    {{ dbt_utils.group_by(n=6) }}
),

-- Create a hash
-- to use as unique identifier 
-- and a fake timestamp
-- so that we can identify the first session
hashed_ga_sessions as (
    select
        *,
        -- Cheapest hashing function
        farm_fingerprint(
            concat(user_id, date, ifnull(campaign, ""), ifnull(source, ""), ifnull(medium, ""), requested_demo)
        ) as session_id
    from deduped_ga_sessions
)

-- Add an ordering to sessions
-- to identify first-touch / last-touch as needed
select
    session_id,
    row_number() over (partition by user_id order by date, session_id) as session_order,
    user_id,
    date,
    campaign,
    source,
    medium,
    requested_demo,
from hashed_ga_sessions