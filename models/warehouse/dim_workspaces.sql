{{ config(
    materialized='table',
    partition_by={
        "field": "created_at",
        "data_type": "date"
    } 
) }}

with
workspaces as (
    select *
    from {{ ref('stg_workspaces') }}
),

charges as (
    select *
    from {{ ref('stg_charges') }}
),

charges_aggs as (
    select
        workspace_id,
        -- Find most recent charge order for this workspace
        -- to be used in JOIN clause later
        max(charge_order_for_workspace) as most_recent_charge_order,
        -- Calculate the total charge amount for this workspace
        sum(amount_usd) as total_charge_amount,
    from charges
    group by 1
)

select 
    workspaces.workspace_id,
    workspaces.owner_user_id,
    workspaces.created_at,
    charges.charge_month as most_recent_charge_month,
    charges.user_count as most_recent_user_count,
    charges.plan_period as most_recent_plan_period,
    charges.plan_name as most_recent_plan_name,
    ifnull(charges_aggs.total_charge_amount, 0) as total_charge_amount,
from workspaces
left join charges_aggs
    on workspaces.workspace_id = charges_aggs.workspace_id
left join charges
    on charges_aggs.workspace_id = charges.workspace_id
    and charges_aggs.most_recent_charge_order = charges.charge_order_for_workspace