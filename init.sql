CREATE OR REPLACE TABLE `toggl-interview.sources.charges` AS
SELECT
	*
FROM
	`toggl-take-home-data.sources.charges`;

CREATE OR REPLACE TABLE `toggl-interview.sources.ga_sessions` AS
SELECT
	*
FROM
	`toggl-take-home-data.sources.ga_sessions`;

CREATE OR REPLACE TABLE `toggl-interview.sources.pricing_plans` AS
SELECT
	*
FROM
	`toggl-take-home-data.sources.pricing_plans`;

CREATE OR REPLACE TABLE `toggl-interview.sources.subscription_periods` AS
SELECT
	*
FROM
	`toggl-take-home-data.sources.subscription_periods`;

CREATE OR REPLACE TABLE `toggl-interview.sources.users` AS
SELECT
	*
FROM
	`toggl-take-home-data.sources.users`;

CREATE OR REPLACE TABLE `toggl-interview.sources.workspaces` AS
SELECT
	*
FROM
	`toggl-take-home-data.sources.workspaces`;