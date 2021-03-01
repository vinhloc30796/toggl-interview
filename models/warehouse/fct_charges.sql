{{ config(
    materialized='table',
    cluster_by=["workspace_id"],
    partition_by={
        "field": "charge_month",
        "data_type": "date"
    } 
) }}

with 
charges as (
    select *
    from {{ ref('stg_charges') }}
),

charges_window as (
    select
        workspace_id,
        charge_month,
        date_diff(
            charge_month, 
            lag(charge_month) over (
                partition by workspace_id 
                order by charge_month
            ), 
            month
        ) as months_since_last_charge,
        lag(amount_usd) over (partition by workspace_id order by charge_month) as previous_amount_usd,
        sum(amount_usd) over (partition by workspace_id order by charge_month) as running_amount_usd,
    from charges
)

select
    charges.workspace_id,
    charges.plan_period,
    charges.plan_name,
    charges.charge_month,
    charges.charge_order_for_workspace,
    charges.amount_usd,
    charges.user_count,
    charges_window.months_since_last_charge,
    case
        when months_since_last_charge is null then "New"
        when months_since_last_charge = 1 then "Retained"
        when months_since_last_charge > 1 then "Reactivated"
        else NULL
    end as mrr_type,
from charges
left join charges_window
    on charges.workspace_id = charges_window.workspace_id
    and charges.charge_month = charges_window.charge_month
