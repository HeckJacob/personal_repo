
DROP VIEW IF EXISTS haven_analytics.AdvisorNPSScore;

CREATE VIEW haven_analytics.AdvisorNPSScore AS

WITH CBB1851 AS (
SELECT DISTINCT PRD.BUSINESS_PARTNER_ID
FROM teradata.PDCR_DEMOGRAPHICS_VW PRD
WHERE PRD.BCC_START_DT IS NOT NULL
	AND NOW() BETWEEN PRD.BCC_START_DT AND PRD.BCC_END_DT
)
, NPS as (	
SELECT CAST(NPS.id AS VARCHAR(255)) AS id
	, UPPER(CAST(NPS.user_id AS VARCHAR(255))) AS user_id
	, CAST(NPS.user_name AS VARCHAR(255)) AS user_name
	, NPS.score
	, NPS."timestamp"
	, CAST(NPS.user_email AS VARCHAR(255)) AS user_email
	, CAST(NPS.anonymous_id AS VARCHAR(255)) AS anonymous_id
	, CASE WHEN nps.context_page_path LIKE '%/client-details/%' THEN '/client-details'
		ELSE nps.context_page_path END AS ReviewPage
FROM haven_segment_cp.nps_score_appcues NPS
WHERE NPS.user_id NOT LIKE '%TPD%'
)
, NPSclean AS (
SELECT A.id
	, A.user_id
	, A.producerNumber
	, A.user_name
	, A.user_email
	, A.anonymous_id
	, A.timestamp
	, A.score
	, A.ReviewPage
FROM (
	SELECT nps.id
		, nps.user_id
		, LTRIM(CASE WHEN nps.user_id LIKE '%OLD%' THEN RTRIM(RIGHT(LEFT(nps.user_id,12),6),'-')
					WHEN nps.user_id LIKE '%TPD%' THEN LTRIM(nps.user_id,'TPD')
					ELSE LTRIM(LTRIM(LTRIM(nps.user_id,'A'),'E'),'MM')
					END
				,'0') AS producerNumber
		, nps.user_name
		, nps.user_email
		, nps.anonymous_id
		, nps.score
		, nps."timestamp"
		, LEAD(nps."timestamp") OVER(PARTITION BY nps.user_id ORDER BY nps."timestamp") AS NextTime
		, nps.ReviewPage
	FROM NPS nps
	) A
WHERE (A.NextTime IS NULL OR DATEDIFF(second,A.timestamp,A.NextTime) > 86400)
)
, SocietyAppsSubmitted AS (
SELECT DISTINCT pa.producerNumber
	, mp.submittedAt
FROM haven_analytics.policy_agent_table pa
	INNER JOIN haven.policy pol ON pol._id = pa.policy_id
	INNER JOIN haven.application app ON app._id = pol.application_id
	LEFT JOIN haven_analytics.main_policy mp ON mp.policyNumber = pa.policyNumber
WHERE app.isSociety1851 = TRUE
)
, SocietyAppsSubmittedRecently AS (
SELECT NPS.id
	, COUNT(*) AS '1851AppsSubmittedRecently'
FROM NPSClean NPS
	INNER JOIN SocietyAppsSubmitted SAS ON SAS.producerNumber = NPS.producerNumber
		AND SAS.submittedAt BETWEEN TIMESTAMPADD(Day,-180,NPS.timestamp) AND NPS.timestamp
GROUP BY 1
)
, NPSFeedback AS (
SELECT NPSC.id
	, CAST(feedback.feedback AS VARCHAR(1000)) AS feedback
	, ROW_NUMBER() OVER(PARTITION BY NPSC.id ORDER BY FEEDBACK.timestamp) AS RN
FROM NPSclean NPSC
	LEFT JOIN haven_segment_cp.nps_feedback_appcues feedback ON NPSC.anonymous_id = feedback.anonymous_id
		AND Feedback.timestamp BETWEEN NPSC."timestamp" AND TIMESTAMPADD(hour, 6, NPSC."timestamp")
)
SELECT NPSC.id
	, NEW_TIME(NPSC.timestamp, 'UTC', 'US/Eastern')  AS scoreDate
	, NPSC.score
	, CASE WHEN NPSC.score <= 6 THEN -1
		WHEN NPSC.score >= 9 THEN 1
		ELSE 0
		END AS ScoreBucket
	, NPSC.ReviewPage
	, NPSC.anonymous_id
	, NPSC.user_id
	, NPSC.producerNumber
	, COALESCE(AP.createdTime, AA.firstLoginDate) AS firstLoginDate
	, COALESCE(proxPrt.firstName || ' ' || proxPrt.lastName, AA.agentName) AS agentName
	, AA.agencyName
	, AA.legacyAgencyID
	, CASE WHEN NPSC.user_id LIKE 'AE%' THEN 'Proxy' ELSE AA.CAS_IND END AS CAS_IND
	, CASE WHEN NPSC.user_id LIKE 'AE%' THEN 'Proxy' ELSE 'Agent' END AS Role
	, CASE WHEN CBB1851.BUSINESS_PARTNER_ID IS NOT NULL THEN 'Member' ELSE 'Non-Member' END AS '1851 Society Status'
	, ADV.LEN_OF_SVC AS AgentLengthOfService
	, ADV.AGE AS AgentAge
	, ADV.GNDR AS AgentGender
	, ADV.HM_STATE AS AgentHomeState
	, NPSF.feedback AS feedback
	, ROW_NUMBER() OVER(PARTITION BY NPSC.user_id ORDER BY NPSC.timestamp) AS ReviewOrder
	, ROW_NUMBER() OVER(PARTITION BY NPSC.user_id ORDER BY NPSC.timestamp DESC) AS ReviewOrderDesc
	, COALESCE(SASR.'1851AppsSubmittedRecently',0) AS '1851AppsSubmittedRecently'
FROM NPSclean NPSC
	LEFT JOIN haven_analytics.agent_agency_table AA ON AA.producerNumber = NPSC.producerNumber
	LEFT JOIN haven.agent_proxy AP ON AP.proxyId = NPSC.user_id
	LEFT JOIN haven.party proxPrt ON proxPrt._id = AP.party_id
	LEFT JOIN NPSFeedback NPSF ON NPSF.id = NPSC.id
		AND NPSF.RN = 1
	LEFT JOIN CBB1851 ON CBB1851.BUSINESS_PARTNER_ID = AA.BUSINESS_PARTNER_ID
	LEFT JOIN prod_usig_crcog_dm_rptg_vw.ADVSR_VW ADV ON AA.producerNumber = LTRIM(ADV.BP_ID,'0')
	LEFT JOIN SocietyAppsSubmittedRecently SASR ON SASR.id = NPSC.id
