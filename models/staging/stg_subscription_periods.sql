with 
trials as (
    select 
        workspace_id,
        pricing_plan_id,
        user_count,
        started_on,
        finished_on,
        date_diff(
            ifnull(finished_on, current_date()), 
            started_on, 
            day
        ) as trial_days,
    from {{ source('sources', 'subscription_periods') }}
    where is_trial = True
)

-- Deduplicate data
-- because one workspace, on one pricing plan, 
-- on one started date, can only have one trial
-- i.e. (workspace_id, pricing_plan_id, started_on) should be unique
-- by selecting the longest trial
select 
    workspace_id,
    pricing_plan_id,
    started_on,
    max(trial_days) as longest_trial_days
from trials
group by 1, 2, 3
