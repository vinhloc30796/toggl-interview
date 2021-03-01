with days as (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2020-01-01' as datetime)",
        end_date="cast('2021-03-01' as datetime)"
    ) }}
)

select 
    date_day,
    datetime_trunc(date_day, month) as date_month,
from days