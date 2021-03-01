# Take-Home Assessment - Loc Nguyen's Submission

## Stakeholders
The stakeholders for this hypothetical project are the Chief Revenue Officer, 
and the marketing, sales, and customer success teams that he oversees. 
The CRO has requested a solution so that his team, who do not necessarily have SQL proficiency, 
are able to independently determine how many **NEW** signups, demo requests, trials, paid workspaces, 
and monthly recurring revenue are being driven by a particular UTM campaign, medium, and/or source over any given time frame. 

The CRO prefers a [first-touch attribution model](https://chartio.com/learn/marketing-analytics/how-to-track-first-touch-attribution-in-google-analytics/#what-is-first-touch-attribution) 
but is open to exploring other approaches. 

We should assume that the team has access to a BI tool with a GUI that allows them 
to filter, sort, visualize, and perform simple aggregations.

## Implementation

This assignment was built using dbt + BigQuery.

I took a lot of reference from [dbt's "How we structure our dbt projects"](https://discourse.getdbt.com/t/how-we-structure-our-dbt-projects/355)
and [GitLab's internal dbt Guide](https://about.gitlab.com/handbook/business-ops/data-team/platform/dbt-guide/).

### For developers: 
Please clone this repo and follow [dbt's installation instructions](https://docs.getdbt.com/docs/dbt-cloud/cloud-quickstart) to view & edit code.

### For business users:
Business users will gain access to the below data tables in a GUI-driven, self-service BI solution.

The tables are all partitioned by creation time (usually filtered on in queries) and IDs (usually queried together).

A list and brief description of the data models created by your solution, including intermediate tables or views. Why did you choose these schemata? How will they be materialized, and why?

- `dim_dates`: Dates going from Jan 2020 to Feb 2021. It includes two columns:
    - `date_day`: dates, grouped by days
    - `date_month`: dates, grouped by month (to the first of the month)
- `dim_users`: Users' characteristics and first-touch attribution. It includes:
    - `user_id`: the user's ID
    - timestamps like `created_at` and `activated_at`
    - first-touch-attributed UTM tags: `campaign`, `source`, and `medium`
- `dim_workspaces`: Workspaces' most recent characteristics, including:
    - `most_recent_charge_month`
    - `most_recent_user_count`
    - `most_recent_plan_period`
    - `most_recent_plan_name`
    - `total_charge_amount`
- `fct_charges`: Charges to each workspaces - and can be used to count how many workspaces have paid in a timeframe. It includes:
    - `workspace_id`
    - `plan_period`
    - `plan_name`
    - `charge_month`
    - `amount_usd`
    - `user_count`
    - `charge_order_for_workspace`: an ordering of each charge sorted by time. The earliest charge would be numbered 1; the next would be 2; and so on.
    - `mrr_type`: MRR categories as one of [New; Retained; Reactivated]. _New_ if first charged. _Retained_ if charged last month. _Reactivated_ if previously charged, but not charged last month.
- `fct_demo_requests`: Demo requests by day for the users
- `fct_trials`: Trial for workspaces
