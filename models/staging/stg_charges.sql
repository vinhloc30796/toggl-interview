with 
charges as (
    select *
    from {{ source('sources', 'charges') }}
),

plans as (
    select *
    from {{ ref('stg_pricing_plans') }}
)

select
    charges.workspace_id,
    charges.pricing_plan_id,
    plans.plan_period,
    plans.plan_name,
    charges.charge_month,
    row_number() over (partition by workspace_id order by charge_month) as charge_order_for_workspace,
    charges.amount_usd,
    charges.user_count,
from charges
left join plans
    on charges.pricing_plan_id = plans.pricing_plan_id