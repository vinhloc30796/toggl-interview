with 
src_charges as (
    select *
    from {{ source('sources', 'charges') }}
)

select *
from src_charges