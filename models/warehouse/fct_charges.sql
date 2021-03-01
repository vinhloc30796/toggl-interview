with 
stg_charges as (
    select *
    from {{ ref('stg_charges') }}
)

select *
from src_charges