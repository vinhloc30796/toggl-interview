select *
from {{ source('sources', 'workspaces') }}