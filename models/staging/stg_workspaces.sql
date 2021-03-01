with 
workspaces as (
    select *
    from {{ source('sources', 'workspaces') }}
),

charges as (
    select *
    from {{ ref('stg_charges') }}
)

select 
    workspaces.*,
    count(distinct charges.user_count) as count_user_counts,
from workspaces
left join charges
    on workspaces.workspace_id = charges.workspace_id
group by 1, 2, 3, 4
having count_user_counts > 1
order by count_user_counts desc