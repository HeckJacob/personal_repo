SELECT EZ.policy_number AS 'PolicyNumber'
	, DATE(NB.SUBMISSION_DATE) AS submittedAt
	, CASE WHEN NB.ISSUE_DATE = '0001-01-01' THEN NULL ELSE NB.ISSUE_DATE END AS 'issueDate'
	, EZ.plan_name
	, CASE
		WHEN EZ.product_type = 'Whole Life' AND CAST(EZ.age_primary_insured AS INT) < 18 THEN 'Juvi Whole' -- AKA Juvi
		WHEN EZ.product_type = 'Whole Life' THEN 'Whole Life Other'
		WHEN EZ.product_type = 'Term Life' THEN 'Term Life'
		ELSE NULL
		END AS 'product_group'
	, CAST(EZ.face_amount AS INT) AS faceAmount
	, CAST(EZ.age_primary_insured AS INT) AS insuredAge
	, EZ.residence_state_primary_insured AS insuredState
	, CASE WHEN CPER.EligibleFlg = 1 THEN 'Eligible' ELSE 'Not Eligible' END AS coverpathEligible -- Official Eligibility Measurement
	-- Rider Start
	, CASE WHEN EZ.rider LIKE '%Accelerated Death Benefit for Qualified Long Term Care Services Rider%' THEN 1 ELSE 0 END AS 'Accelerated_Death_Benefit_Rider'
	, CASE WHEN EZ.rider LIKE '%+ Additional Life Insurance Rider%' THEN 1
		WHEN EZ.rider LIKE 'Additional Life Insurance Rider%' THEN 1
		ELSE 0 END AS 'Additional_Life_Insurance_Rider'
	, CASE WHEN EZ.rider LIKE '%Estate Protection Rider%' THEN 1 ELSE 0 END AS 'Estate_Protection_Rider'
	, CASE WHEN EZ.rider LIKE '%Extended LTC Benefits Rider Amount%' THEN 1 ELSE 0 END AS 'Extended_LTC_Benefits_Rider_Amount'
	, CASE WHEN EZ.rider LIKE '%Guaranteed Insurability Rider%' THEN 1 ELSE 0 END AS 'Guaranteed_Insurability_Rider'
	, CASE WHEN EZ.rider LIKE '%Life Insurance Supplement Rider%' THEN 1 ELSE 0 END AS 'Life_Insurance_Supplement_Rider'
	, CASE WHEN EZ.rider LIKE '%Long Term Care%' THEN 1 ELSE 0 END AS 'Long_Term_Care'
	, CASE WHEN EZ.rider LIKE '%Planned Additional Life Insurance Rider%' THEN 1 ELSE 0 END AS 'Planned_Additional_Life_Insurance_Rider'
	, CASE WHEN EZ.rider LIKE '%Renewable Term Rider%' THEN 1 ELSE 0 END AS 'Renewable_Term_Rider'
	, CASE WHEN EZ.rider LIKE '%Waiver Of Premium%' THEN 1 ELSE 0 END AS 'Waiver_Of_Premium'
	-- Rider End
	, EZ.party_type_code_primary_owner AS OwnerType
	, EZ.organization_form_like_trust_primary_owner AS OwnerOrganizationType
	, CASE WHEN COUNT(*) OVER(PARTITION BY EZ.transaction_id) > 1 THEN 'JointApp' ELSE 'Single' END AS JointStatus
	, PA.producerNumber
	, PA.CBO_DESC
	, AA.agentName
	, AA.agencyName
	, AA.legacyAgencyID
	, AA.CAS_IND
	, AA.agencyAssignedTo
FROM ezapp.ezapp_weekly_full_extract EZ
    LEFT JOIN haven_analytics.CoverPathEligibilityResults CPER ON CPER.policyNumber = EZ.policy_number
    LEFT JOIN teradata_nb.NB_RPT_VW NB ON NB.HLDG_KEY = EZ.policy_number
    LEFT JOIN haven_analytics.policy_agent_table PA ON PA.policyNumber = EZ.policy_number
    	AND PA.primaryAgentFlag = 1
    LEFT JOIN haven_analytics.agent_agency_table AA ON AA.producerNumber = PA.producerNumber
WHERE EZ.product_type IN ('Whole Life','Term Life')
	AND DATE(NB.SUBMISSION_DATE) >= '2019-01-01'