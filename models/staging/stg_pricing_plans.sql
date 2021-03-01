select *
from {{ source('sources', 'pricing_plans')}}