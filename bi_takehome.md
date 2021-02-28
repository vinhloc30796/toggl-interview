## Take-Home Assessment

### Description

Your mission, if you choose to accept, is to design marketing attribution data models for Toggl Track to be used in a BI tool by users that do not have SQL proficiency. You will be working with a simplified, anonymous sample of subscriptions and public website sessions. Each table in the starting data has either been randomly generated, or purposely obfuscated, so we're not interested in any insights you may try to derive from this dataset. Instead, we will be paying attention to 

- The readability, accuracy and efficiency of your SQL
- The schemata of your data models with an eye toward simplicity and meeting all stakeholder requirements
- The choices you make in how to build the data models, and the reasoning you provide for these choices

### Stakeholders and Deliverables

Your stakeholders for this hypothetical project are the Chief Revenue Officer, and the marketing, sales, and customer success teams that he oversees. The CRO has requested a solution so that his team, who do not necessarily have SQL proficiency, are able to independently determine how many **NEW** signups, demo requests, trials, paid workspaces, and monthly recurring revenue are being driven by a particular UTM campaign, medium, and/or source over any given time frame. The CRO prefers a [first-touch attribution model](https://chartio.com/learn/marketing-analytics/how-to-track-first-touch-attribution-in-google-analytics/#what-is-first-touch-attribution) but is open to exploring other approaches. You should assume that the team has access to a BI tool with a GUI that allows them to filter, sort, visualize, and perform simple aggregations (but not join, union, or intersect) any tables or views that you build. 

Assuming that new data is loaded into the source tables every 24 hrs via an ETL tool, your task is to write transformations of the source data that result in one or more data tables that will be exposed to the BI tool. You should also decide on an implementation strategy for these transformations that will ensure those tables remain accurate and fresh as new data arrives. 

Your deliverables are

- A zip file or link to a source control repo containing the code required to transform the source data into the final data model(s).
- A list and brief description of the data models created by your solution, including intermediate tables or views. Why did you choose these schemata? How will they be materialized, and why?
- A few paragraphs describing, on a high level, how you envision your solution would be implemented.  How does your solution deal with, for instance, source data arriving at unpredictable times, or only some source tables getting updated? What steps would you take to ensure that our revenue team knows how to work with this data? Anything in particular you would tell the team about how to understand this data? How would you communicate these points to them? **You are not expected to write any code for the implementation.**
- **BONUS:** What would you do differently if the size of the `ga_sessions` dataset was 10x bigger? 1000x bigger?

### Getting the data

You are welcome to use any tools at your disposal to work on this solution, but for the sake of standardization, we ask that the only SQL dialect included in your solution is [BigQuery Standard SQL](https://cloud.google.com/bigquery/docs/reference/standard-sql/functions-and-operators) and the implementation you describe should result in the final data models being stored in BigQuery. Everything required of you in this assignment is possible within the BigQuery free-tier, and in general, you shouldn't need a credit card to complete any part of this assignment. If you feel like you can't complete this assignment within the free tier, let me know and we can work something out. Here is how to load the sample data:

1. If you don't already have a Google Cloud Platform account and project for personal use, activate your GCP account, and create a new project
2. Create a BigQuery dataset within your project called `sources`. 
3.  Execute the following queries to load (or reload if you need to start over) the sample dataset

```sql
CREATE OR REPLACE TABLE `<your-project-id>.sources.charges` AS
SELECT
	*
FROM
	`toggl-take-home-data.sources.charges`;

CREATE OR REPLACE TABLE `<your-project-id>.sources.ga_sessions` AS
SELECT
	*
FROM
	`toggl-take-home-data.sources.ga_sessions`;

CREATE OR REPLACE TABLE `<your-project-id>.sources.pricing_plans` AS
SELECT
	*
FROM
	`toggl-take-home-data.sources.pricing_plans`;

CREATE OR REPLACE TABLE `<your-project-id>.sources.subscription_periods` AS
SELECT
	*
FROM
	`toggl-take-home-data.sources.subscription_periods`;

CREATE OR REPLACE TABLE `<your-project-id>.sources.users` AS
SELECT
	*
FROM
	`toggl-take-home-data.sources.users`;

CREATE OR REPLACE TABLE `<your-project-id>.sources.workspaces` AS
SELECT
	*
FROM
	`toggl-take-home-data.sources.workspaces`;
```

### Data context

**workspaces -** Workspaces are collections of 1 or more Toggl Track users. Every workspace has exactly 1 user that is the workspace owner. 

**users -** A user is an account / profile on Toggl Track. 1 user = 1 email address. At signup, a user gets an autogenerated workspace, of which they are the workspace owner. A user can create or join many workspaces and invite many other users to join their workspace(s).

**subscription_periods -** A subscription period is a 30-day interval of a paid subscription. Subscriptions apply to workspaces, not users. Every workspace starts its first subscription with a special free trial `subscription_period` in which no `charge` is generated. Trial periods can occur only once per workspace. For a subscription in progress, `finished_on` is null. 

**charges -** A charge for a workspace is generated at the beginning of a `subscription_period`, based on the number of users in the workspace and the pricing plan of the subscription. The `charge_month` field is the first day of the month in which the corresponding `subscription_period` started. For example, a `subscription_period` starting on `2020-12-31` and ending on `2021-01-30` would have `charge_month = 2020-12-01` . 

**pricing-plans** - Indicate whether a subscription is starter or premium and monthly or annual. Annual plans are prepaid for 12 months, but still generate a charge every month that is subtracted from the pre-paid balance. In this way, charges represent the MRR, or periodized monthly revenue, of annual and monthly plans combined.

**ga_sessions -** An anonymized sample of user sessions collected by Google Analytics on visitors to the Toggl Track public website. The `user_id` field corresponds to the internal Toggl Track user ID. These sessions have already been backstitched, meaning that once a user has signed-up, the `user_id` field on all past and future sessions belonging to the same user (as determined by the Google Analytics internal user ID) is populated with their Toggl Track user ID. A session with a null `user_id` corresponds to a visitor that has not signed up for Toggl Track.

### Metrics Glossary

**Signups** - The total signups during a given time frame is the number of unique user ID's created during that period

**Trials** - The number of subscription periods with `is_trial = True` started during a given time frame

**Paid Workspaces** - The number of unique workspaces that generated a non-zero charge over a given time frame

**Monthly Recurring Revenue (MRR)** - MRR in USD is the sum of `amount_usd` over all charges with the same `charge_month`.

**New MRR** - MRR resulting from charges generated by a workspace for which there was no charge during the month prior

**Reactivation MRR** - A subset of new MRR resulting from workspaces that have previously generated a charge, but did not in the previous month.

**Attribution -** Trials, paid workspaces, and MRR are workspace-level metrics, but in the context of acquisition, they should be attributed to the marketing channel/source/medium that drove the signup of the workspace owner's user account.

Sessions on the public web that occur after a user has signed up should not be counted toward attribution