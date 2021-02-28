select
    -- Remove session_id because it's not useful as a unique identifier;
    -- We won't create our own identifier to ensure there's no duplicated data.
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
