select * 
from {{ source('sources', 'subscription_periods') }}