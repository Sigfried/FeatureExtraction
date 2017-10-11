/***********************************
File cohortsOfInterest.sql
***********************************/

IF OBJECT_ID('@resultsDatabaseSchema.cohortsOfInterest', 'U') IS NOT NULL
  DROP TABLE @resultsDatabaseSchema.cohortsOfInterest;

SELECT first_use.*
INTO @resultsDatabaseSchema.cohortsOfInterest
FROM (
  SELECT drug_concept_id AS cohort_definition_id,
  	MIN(drug_era_start_date) AS cohort_start_date,
  	MIN(drug_era_end_date) AS cohort_end_date,
  	person_id 
  FROM @cdmDatabaseSchema.drug_era
  WHERE drug_concept_id = 1118084-- celecoxib
    OR drug_concept_id = 1124300 --diclofenac
  GROUP BY drug_concept_id, 
    person_id
) first_use 
INNER JOIN @cdmDatabaseSchema.observation_period
  ON first_use.person_id = observation_period.person_id
  AND cohort_start_date >= observation_period_start_date
  AND cohort_end_date <= observation_period_end_date
WHERE DATEDIFF(DAY, observation_period_start_date, cohort_start_date) >= 365;