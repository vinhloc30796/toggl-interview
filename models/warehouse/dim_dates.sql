{{ dbt_utils.date_spine(
    datepart="day",
    start_date="cast('2020-01-01' as datetime)",
    end_date="cast('2021-03-01' as datetime)"
   )
}}