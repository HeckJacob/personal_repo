DROP VIEW haven_analytics.CoverPathEligibilityRules;

CREATE VIEW haven_analytics.CoverPathEligibilityRules as

WITH add_alt_hold AS (
    SELECT base.policy_number, 
        base.transaction_id, 
        base.product_type, 
        case when base.additional_holding = 'yes' or add_hold1.product_type is not null then 1 else 0 end AS additional_holding,
        NVL(add_hold1.product_type, add_hold2.product_type) AS additional_holding_prod_type,
        case when base.alternate_holding = 'yes' or alt_hold1.product_type is not null then 1 else 0 end AS alternate_holding,
        NVL(alt_hold1.product_type, alt_hold2.product_type) AS alternate_holding_prod_type
    FROM ezapp.ezapp_weekly_full_extract base
    LEFT JOIN (
        SELECT additional_holding_policy_number, product_type
        FROM ezapp.ezapp_weekly_full_extract
        WHERE additional_holding_policy_number is not null
    ) add_hold1 ON base.policy_number = add_hold1.additional_holding_policy_number
    LEFT JOIN (
        SELECT policy_number, product_type
        FROM ezapp.ezapp_weekly_full_extract
    ) add_hold2 ON base.additional_holding_policy_number = add_hold2.policy_number
    LEFT JOIN (
        SELECT alternate_holding_policy_number, product_type
        FROM ezapp.ezapp_weekly_full_extract
        WHERE alternate_holding_policy_number is not null
    ) alt_hold1 ON base.policy_number = alt_hold1.alternate_holding_policy_number
    LEFT JOIN (
        SELECT policy_number, product_type
        FROM ezapp.ezapp_weekly_full_extract
    ) alt_hold2 ON base.alternate_holding_policy_number = alt_hold2.policy_number
)
, x AS (
	SELECT t2.MAX_FLAT_EXTRA_ON_PARENT_1
	, t1.hldg_stus
	, t1.hldg_key
	, t2.PERMENANT_TABLE_RATING_1
	, t1.AGREEMENT_SOURCE_CD
	FROM teradata.AGMT_CMN_VW t1
	    LEFT JOIN teradata.AGMT_UWRT_CMN_VW t2 ON t1.AGREEMENT_ID = t2.AGREEMENT_ID
	WHERE LTRIM(t1.hldg_key, '0') IN (
	    SELECT LTRIM(ezapp.ezapp_weekly_full_extract.policy_number,'0')
	    FROM ezapp.ezapp_weekly_full_extract)
   )
, eligibile AS (
SELECT a.policy_number AS policyNumber
, DATE(NB.SUBMISSION_DATE) AS 'SubmittedDate'
, a.transaction_id
--, DATE(a.transaction_date) AS 'TransactionDate'
, CASE WHEN a.product_type IN ('Whole Life','Term Life') THEN 1 ELSE 0 END AS 'Product_Type_Whole_or_Term_Life'
, CASE WHEN a.plan_name NOT LIKE '%Vantage Term ART%' AND a.plan_name NOT LIKE '%Renew%' THEN 1 ELSE 0 END AS 'Plan_Name_not_like_Vantage_Term_ART' --
, CASE WHEN a.plan_name NOT IN ('WholeLife Legacy 10 Pay (A1000)','Whole Life Legacy 10 Pay') THEN 1 ELSE 0 END AS 'Plan_Name_Not_Whole_Life_Legacy_10_Pay'
, CASE WHEN a.plan_name  <> 'Whole Life Legacy 12 Pay' THEN 1 ELSE 0 END AS 'Plan_Name_Not_Whole_Life_Legacy_12_Pay' --
--, CASE WHEN a.plan_name  <> 'Whole Life Legacy 15 Pay' THEN 1 ELSE 0 END AS 'Plan_Name_Not_Whole_Life_Legacy_15_Pay' --
, CASE WHEN a.age_primary_insured >= 18 AND a.plan_name = 'Whole Life Legacy 15 Pay' THEN 0 ELSE 1 END AS 'Plan_Name_Not_Whole_Life_Legacy_15_Pay' --
, CASE WHEN a.age_primary_insured < 18 AND a.plan_name = 'Whole Life Legacy 15 Pay' THEN 0 ELSE 1 END as 'Juvenile_WL_15' --
, CASE WHEN a.plan_name NOT LIKE '%Whole Life Legacy 20%' THEN 1 ELSE 0 END AS 'Plan_Name_not_like_Whole_Life_Legacy_20'
, CASE WHEN a.product_type IN ('Whole Life','Term Life') THEN 1 ELSE 0 END AS 'Product_Type_not_Whole_Life_or_Term_Life'
, CASE WHEN a.plan_name NOT LIKE '%Whole Life Legacy 65%' THEN 1 ELSE 0 END AS 'Plan_Name_not_Like_Whole_Life_Legacy_65'
, CASE WHEN a.plan_name NOT LIKE '%Survivorship%' THEN 1 ELSE 0 END AS 'Plan_Name_not_Like_Survivorship'
, CASE WHEN a.plan_name NOT LIKE '%CareChoice%' THEN 1 ELSE 0 END AS 'Plan_Name_not_Like_CareChoice'
, CASE WHEN a.plan_name NOT LIKE '%HECV%' AND a.plan_name NOT LIKE '%Cash%' THEN 1 ELSE 0 END AS 'Plan_Name_not_Like_HECV' --
, CASE WHEN a.plan_name NOT LIKE '%ECP%' THEN 1 ELSE 0 END AS 'Plan_Name_not_Like_ECP'
, CASE WHEN a.plan_name NOT LIKE '%25%' THEN 1 ELSE 0 END AS 'Plan_Name_not_Like_25'
, CASE WHEN a.plan_name NOT LIKE '%30%' THEN 1 ELSE 0 END AS 'Plan_Name_not_Like_30'
, CASE WHEN a.plan_name NOT LIKE '%15%' THEN 1 ELSE 0 END AS 'Plan_Name_not_Like_15'
, CASE WHEN add_alt_hold.additional_holding_prod_type = 'Term Life' THEN 0 ELSE 1 END AS 'Additional_Holding_Prod_Type_excluding_Term_Life'
, CASE WHEN add_alt_hold.additional_holding_prod_type = 'Whole Life' THEN 0 ELSE 1 END AS 'Additional_Holding_Prod_Type_excluding_Whole_Life'
, CASE WHEN add_alt_hold.additional_holding = 0 THEN 1 ELSE 0 END AS 'Additional_Holding_doesnt_exist'
, CASE WHEN add_alt_hold.alternate_holding_prod_type = 'Whole Life' THEN 0 ELSE 1 END AS 'Alternative_Holding_Prod_Type_excluding_Whole_Life'
, CASE WHEN add_alt_hold.alternate_holding_prod_type = 'Term Life' THEN 0 ELSE 1 END AS 'Alternative_Holding_Prod_Type_excluding_Term_Life'
, CASE WHEN add_alt_hold.alternate_holding = 0 THEN 1 ELSE 0 END AS 'Alternative_Holding_doesnt_exist'
, CASE WHEN a.di_concur is null THEN 1 ELSE 0 END AS 'DI_Concur_is_Null'
, CASE WHEN bene.entity = 0 THEN 1 ELSE 0 END AS 'Entity_is_0'
, CASE WHEN bene.organization = 0 THEN 1 ELSE 0 END AS 'Organization_is_0'
, CASE WHEN a.immigration_status_primary_insured IN ('Non-resident U.S. citizen','Non-resident alien','Non-resident non-U.S. citizen')
		OR a.immigration_status_primary_insured IS NULL THEN 0 ELSE 1 END as 'Is_Non_Resident' --
, CASE WHEN a.immigration_status_primary_insured IN ('Alien','Non-U.S. citizen','Resident alien','Resident non-U.S. citizen') THEN 0 ELSE 1 END AS 'Is_Resident_Or_Alien' --
, CASE WHEN a.intent_to_sell_A1AGE = 0 OR a.intent_to_sell_A1AGE IS NULL THEN 1 ELSE 0 END AS 'Intent_to_Sell'
, CASE WHEN COALESCE(a.collateral_assignment_indicator_A1000, a.collateral_assignment_indicator_A2000,'0') = '0' THEN 1 ELSE 0 END AS 'Collateral_is_Not_Assigned'
, CASE WHEN COALESCE(a.incentives_given_for_application_A1000, a.incentives_given_for_application_A2000,'0') = '0' THEN 1 ELSE 0 END AS 'No_Economic_Incentive'
, CASE WHEN a.age_primary_insured > 64 THEN 0 ELSE 1 END as 'Insured_Over_64' --
, CASE WHEN a.age_primary_insured < 18 THEN 0 ELSE 1 END as 'Insured_Under_18' --
, CASE WHEN a.face_amount > 3000000 THEN 0 ELSE 1 END as 'Face_Amount_Under_3Million' --
, CASE WHEN a.age_primary_insured BETWEEN 61 AND 64 AND a.face_amount > 1000000 THEN 0 ELSE 1 END as 'Insured_Age_61_To_64_Over_1_Million' --
, CASE WHEN a.source_of_funds NOT LIKE '%Premium Financing%' OR a.source_of_funds IS NULL THEN 1 ELSE 0 END AS 'Source_of_Funds_not_like_Premium_Financing'
, CASE WHEN COALESCE(a.sponsoring_plan_type_A1000, a.sponsoring_plan_type_A2000,'0') = '1' THEN 0 ELSE 1 END AS 'sponsoring_plan_type_A1000_and_A2000_are_not_1'
, CASE WHEN a.relation_primary_insured_quick_close = 'Quick Close' THEN 0 ELSE 1 END AS 'Not_a_Quick_Close'
, CASE WHEN COALESCE(a.conversion_or_eio_A1000, a.conversion_or_eio_A2000, '0') = 0 THEN 1 ELSE 0 END AS 'Conversion_is_0'
, CASE WHEN a.product_type = 'Whole Life' AND rplmt.primary_policy_transaction_id IS NOT NULL THEN 0 ELSE 1 END as 'Not_Whole_Policy_With_Replacement' --
, CASE WHEN a.product_type = 'Term Life' AND rplmt.primary_policy_transaction_id IS NOT NULL THEN 0 ELSE 1 END as 'Not_Term_Policy_With_Replacement' --
, CASE WHEN a.all_holding_type like '%1035%' THEN 0 ELSE 1 END AS 'Holding_Type_Not_Like_1035'
, CASE WHEN (x.PERMENANT_TABLE_RATING_1 IS NULL OR x.PERMENANT_TABLE_RATING_1 = 0) THEN 1 ELSE 0 END AS 'Permanant_Table_Rating_doesnt_exist'
, CASE WHEN (x.MAX_FLAT_EXTRA_ON_PARENT_1 IS NULL OR x.MAX_FLAT_EXTRA_ON_PARENT_1 = 0) THEN 1 ELSE 0 END AS 'Max_Flat_Extra_On_Parent_doesnt_exist'
--, CASE WHEN (a.rider IS NULL OR a.rider = 'Waiver Of Premium') THEN 1 ELSE 0 END AS 'rider_doesnt_exist_or_is_Waiver_of_Premium'
, CASE WHEN a.all_owners LIKE '%Owner_2%' THEN 0 ELSE 1 END AS 'No_Owner_Number_2'
, CASE WHEN a.party_type_code_primary_owner = 'Organization' OR NVL(a.organization_form_like_trust_primary_owner, ' ') = 'Trust' THEN 0 ELSE 1 END AS 'Not_Trust_or_Organization_as_Primary_Owner'
, CASE WHEN 
		CASE WHEN a.relation_primary_insured_is_owner = 'Owner' THEN a.citizenship_primary_insured ELSE a.citizenship_primary_owner END	IS NOT NULL
	THEN 0 ELSE 1 END AS 'Owner_must_be_US_Citizen'
, CASE WHEN (a.intent_for_insurance NOT IN ('Key Employee', 'Loan Guarantee Coverage', '457 Plan', 'Keogh', 'Target Benefit Plan',
	                        'Other Business', 'Stock Redemption', '401k', 'Deferred Compensation', 'Profit Sharing',
	                        'Pension Trust', 'Cross Purchase', '412i', 'ESOP', 'Split Dollar')
	OR a.intent_for_insurance is null) THEN 1 ELSE 0 END AS 'Exclude_Business_Purpose_Intent_for_Insurance'
, CASE WHEN a.residence_state_primary_insured <> 'FL' OR a.residence_state_primary_insured IS NULL THEN 1 ELSE 0 END AS 'Exclude_Residency_States_for_Insured_FL'
, CASE WHEN a.residence_state_primary_insured <> 'NY' OR a.residence_state_primary_insured IS NULL THEN 1 ELSE 0 END AS 'Exclude_Residency_States_for_Insured_NY'
, CASE WHEN a.residence_state_primary_insured <> 'PR' OR a.residence_state_primary_insured IS NULL THEN 1 ELSE 0 END AS 'Exclude_Residency_States_for_Insured_PR'
, CASE WHEN a.residence_state_primary_insured NOT IN ('CA','DC','DE','MT','ND','SD') OR a.residence_state_primary_insured IS NULL THEN 1 ELSE 0 END AS 'Exclude_Residency_States_for_Insured_6_States'
, CASE WHEN a.rider LIKE '%Accelerated Death Benefit for Qualified Long Term Care Services Rider%' THEN 0 ELSE 1 END AS 'Accelerated_Death_Benefit_Rider'
, CASE WHEN a.rider LIKE '%+ Additional Life Insurance Rider%' THEN 0
	WHEN a.rider LIKE 'Additional Life Insurance Rider%' THEN 0
	ELSE 1 END AS 'Additional_Life_Insurance_Rider'
, CASE WHEN a.rider LIKE '%Estate Protection Rider%' THEN 0 ELSE 1 END AS 'Estate_Protection_Rider'
, CASE WHEN a.rider LIKE '%Extended LTC Benefits Rider Amount%' THEN 0 ELSE 1 END AS 'Extended_LTC_Benefits_Rider_Amount'
, CASE WHEN a.rider LIKE '%Guaranteed Insurability Rider%' THEN 0 ELSE 1 END AS 'Guaranteed_Insurability_Rider'
, CASE WHEN a.rider LIKE '%Life Insurance Supplement Rider%' THEN 0 ELSE 1 END AS 'Life_Insurance_Supplement_Rider'
, CASE WHEN a.rider LIKE '%Long Term Care%' THEN 0 ELSE 1 END AS 'Long_Term_Care'
, CASE WHEN a.rider LIKE '%Planned Additional Life Insurance Rider%' THEN 0 ELSE 1 END AS 'Planned_Additional_Life_Insurance_Rider'
, CASE WHEN a.rider LIKE '%Renewable Term Rider%' THEN 0 ELSE 1 END AS 'Renewable_Term_Rider'
, CASE WHEN a.rider LIKE '%Waiver Of Premium%' THEN 0 ELSE 1 END AS 'Waiver_Of_Premium'
, CASE WHEN a.policy_number NOT IN ( -- No policies with agents who are using different agencies (not necessarily their home agency)
							Select DISTINCT B.policy_number
							FROM (
								Select A.policy_number
								, CASE WHEN A.AgencyCount = 2 THEN
										CASE WHEN LEAST(A.AgencyId1, A.AgencyId2) <> GREATEST(A.AgencyId1, A.AgencyId2) THEN 1 ELSE 0 END
									WHEN A.AgencyCount = 3 THEN
										CASE WHEN LEAST(A.AgencyId1, A.AgencyId2, A.AgencyId3) <> GREATEST(A.AgencyId1, A.AgencyId2, A.AgencyId3) THEN 1 ELSE 0 END
									WHEN A.AgencyCount = 4 THEN
										CASE WHEN LEAST(A.AgencyId1, A.AgencyId2, A.AgencyId3, A.AgencyId4)
												<> GREATEST(A.AgencyId1, A.AgencyId2, A.AgencyId3, A.AgencyId4) THEN 1 ELSE 0 END
									WHEN A.AgencyCount = 5 THEN
										CASE WHEN LEAST(A.AgencyId1, A.AgencyId2, A.AgencyId3, A.AgencyId4, A.AgencyId5)
												<> GREATEST(A.AgencyId1, A.AgencyId2, A.AgencyId3, A.AgencyId4, A.AgencyId5) THEN 1 ELSE 0 END
									WHEN A.AgencyCount = 6 THEN
										CASE WHEN LEAST(A.AgencyId1, A.AgencyId2, A.AgencyId3, A.AgencyId4, A.AgencyId5, A.AgencyId6)
												<> GREATEST(A.AgencyId1, A.AgencyId2, A.AgencyId3, A.AgencyId4, A.AgencyId5, A.AgencyId6) THEN 1 ELSE 0 END
									WHEN A.AgencyCount = 7 THEN
										CASE WHEN LEAST(A.AgencyId1, A.AgencyId2, A.AgencyId3, A.AgencyId4, A.AgencyId5, A.AgencyId6, A.AgencyId7)
												<> GREATEST(A.AgencyId1, A.AgencyId2, A.AgencyId3, A.AgencyId4, A.AgencyId5, A.AgencyId6, A.AgencyId7) THEN 1 ELSE 0 END
									WHEN A.AgencyCount = 8 THEN
										CASE WHEN LEAST(A.AgencyId1, A.AgencyId2, A.AgencyId3, A.AgencyId4, A.AgencyId5, A.AgencyId6, A.AgencyId7, A.AgencyId8)
												<> GREATEST(A.AgencyId1, A.AgencyId2, A.AgencyId3, A.AgencyId4, A.AgencyId5, A.AgencyId6, A.AgencyId7, A.AgencyId8) THEN 1 ELSE 0 END
									WHEN A.AgencyCount = 9 THEN
										CASE WHEN LEAST(A.AgencyId1, A.AgencyId2, A.AgencyId3, A.AgencyId4, A.AgencyId5, A.AgencyId6, A.AgencyId7, A.AgencyId8, A.AgencyId9)
												<> GREATEST(A.AgencyId1, A.AgencyId2, A.AgencyId3, A.AgencyId4, A.AgencyId5, A.AgencyId6, A.AgencyId7, A.AgencyId8, A.AgencyId9) THEN 1 ELSE 0 END
									WHEN A.AgencyCount = 10 THEN
										CASE WHEN LEAST(A.AgencyId1, A.AgencyId2, A.AgencyId3, A.AgencyId4, A.AgencyId5, A.AgencyId6, A.AgencyId7, A.AgencyId8, A.AgencyId9, A.AgencyId10)
												<> GREATEST(A.AgencyId1, A.AgencyId2, A.AgencyId3, A.AgencyId4, A.AgencyId5, A.AgencyId6, A.AgencyId7, A.AgencyId8, A.AgencyId9, A.AgencyId10) THEN 1 ELSE 0 END
									ELSE 0 END AS 'DifferentAgencies'
								FROM (
									Select EZ.policy_number
									, EZ.AgencyCount
									, SUBSTRING(EZ.all_agents, CASE WHEN INSTR(EZ.all_agents, 'agency_id:',1,1) = 0 THEN NULL
												ELSE INSTR(EZ.all_agents, 'agency_id:',1,1) + 10 END, 3) AS 'AgencyId1'
									, SUBSTRING(EZ.all_agents, CASE WHEN INSTR(EZ.all_agents, 'agency_id:',1,2) = 0 THEN NULL
												ELSE INSTR(EZ.all_agents, 'agency_id:',1,2) + 10 END, 3) AS 'AgencyId2'
									, SUBSTRING(EZ.all_agents, CASE WHEN INSTR(EZ.all_agents, 'agency_id:',1,3) = 0 THEN NULL
												ELSE INSTR(EZ.all_agents, 'agency_id:',1,3) + 10 END, 3) AS 'AgencyId3'
									, SUBSTRING(EZ.all_agents, CASE WHEN INSTR(EZ.all_agents, 'agency_id:',1,4) = 0 THEN NULL
												ELSE INSTR(EZ.all_agents, 'agency_id:',1,4) + 10 END, 3) AS 'AgencyId4'
									, SUBSTRING(EZ.all_agents, CASE WHEN INSTR(EZ.all_agents, 'agency_id:',1,5) = 0 THEN NULL
												ELSE INSTR(EZ.all_agents, 'agency_id:',1,5) + 10 END, 3) AS 'AgencyId5'
									, SUBSTRING(EZ.all_agents, CASE WHEN INSTR(EZ.all_agents, 'agency_id:',1,6) = 0 THEN NULL
												ELSE INSTR(EZ.all_agents, 'agency_id:',1,6) + 10 END, 3) AS 'AgencyId6'
									, SUBSTRING(EZ.all_agents, CASE WHEN INSTR(EZ.all_agents, 'agency_id:',1,7) = 0 THEN NULL
												ELSE INSTR(EZ.all_agents, 'agency_id:',1,7) + 10 END, 3) AS 'AgencyId7'
									, SUBSTRING(EZ.all_agents, CASE WHEN INSTR(EZ.all_agents, 'agency_id:',1,8) = 0 THEN NULL
												ELSE INSTR(EZ.all_agents, 'agency_id:',1,8) + 10 END, 3) AS 'AgencyId8'
									, SUBSTRING(EZ.all_agents, CASE WHEN INSTR(EZ.all_agents, 'agency_id:',1,9) = 0 THEN NULL
												ELSE INSTR(EZ.all_agents, 'agency_id:',1,9) + 10 END, 3) AS 'AgencyId9'
									, SUBSTRING(EZ.all_agents, CASE WHEN INSTR(EZ.all_agents, 'agency_id:',1,10) = 0 THEN NULL
												ELSE INSTR(EZ.all_agents, 'agency_id:',1,10) + 10 END, 3) AS 'AgencyId10'
									FROM (
											Select EZAPP.policy_number 
											, EZAPP.all_agents
											, REGEXP_COUNT(EZAPP.all_agents, 'agency_id:') AS AgencyCount
											FROM ezapp.ezapp_weekly_full_extract EZAPP
												Where REGEXP_COUNT(EZAPP.all_agents, 'agency_id:') > 1
											) EZ
									) A
								) B
								Where B.DifferentAgencies = 1
						) THEN 1 ELSE 0 END AS 'Exclude_Policies_with_Multiple_Agency_IDs'
, CASE WHEN a.policy_number NOT IN ( -- No Policies split between an agent and a broker, via Z Codes - provided by Pete
							SELECT DISTINCT a.policy_number
							FROM ezapp.ezapp_weekly_full_extract a 
							    INNER JOIN teradata_prd.AGMT_CMN_VW b ON b.AGREEMENT_SOURCE_CD = a.admin_system AND a.policy_number = LTRIM(b.HLDG_KEY, '0') 
							    INNER JOIN teradata_prd.PDCR_AGMT_CMN_VW c ON c.HLDG_KEY = b.HLDG_KEY
							    INNER JOIN teradata_prd.PDCR_DEMOGRAPHICS_VW pd ON c.PRTY_ID = pd.PRTY_ID
							    INNER JOIN teradata_nb.NB_RPT_VW nb ON LTRIM(nb.HLDG_KEY,'0') = LTRIM(b.HLDG_KEY,'0')
							    INNER JOIN teradata.SLLNG_AGMT_CMN_VW SA ON SA.CHLD_BPID = pd.BUSINESS_PARTNER_ID -- Business Partner ID == Producer ID (use child ID)
																		AND DATE(nb.SUBMISSION_DATE) BETWEEN SA.REL_STRT_DT AND SA.REL_END_DT
																		AND	SA.PARENT_BPID = c.AGT_WRTG_AGY_BPID
									WHERE YEAR(transaction_date) >= 2019
										AND c.PRTY_AGMT_RLE_CD = 'AGT' -- removes agencies personified records
											Group By 1
											Having COUNT(DISTINCT CASE WHEN SA.STD_CONTR_TYP_CD IN ('Z201','Z203','Z204','Z205','Z206','Z207','Z208','Z209'
																									,'Z210','Z284','Z211','Z212','Z410','Z413','Z213','Z214') THEN 'C'
																WHEN SA.STD_CONTR_TYP_CD IN ('Z202','Z217') THEN 'B' ELSE 'Other' END
														) > 1
							) THEN 1 ELSE 0 END AS 'Policy_With_Career_And_Broker'
FROM ezapp.ezapp_weekly_full_extract a
	LEFT JOIN teradata_nb.NB_RPT_VW NB ON NB.HLDG_KEY = a.policy_number
    INNER JOIN teradata_prd.AGMT_CMN_VW b ON b.AGREEMENT_SOURCE_CD = a.admin_system AND a.policy_number = LTRIM(b.HLDG_KEY, '0')
    LEFT JOIN (
            SELECT policy_transaction_id
            , MAX(CASE WHEN party_type = 'Individual' THEN 1 ELSE 0 END) AS individual
            , MAX(CASE WHEN party_type = 'Organization' THEN 1 ELSE 0 END) AS organization
            , MAX(CASE WHEN beneficiary_type = 'Trust' THEN 1 ELSE 0 END) AS trust
            , MAX(CASE WHEN beneficiary_type = 'Other Entity' THEN 1 ELSE 0 END) AS entity
            FROM ezapp.ezapp_all_bene_party
	            GROUP BY 1
             ) bene ON a.transaction_id = bene.policy_transaction_id
    LEFT JOIN (
            SELECT ezo.primary_policy_transaction_id
            , MAX(CASE WHEN ezo.product_type IN ('Group Term', 'Group Universal Life', 'Group Variable Life', 'Group Whole Life') THEN 1 ELSE 0 END) AS replace_group
            FROM ezapp.ezapp_other_holding_policies ezo
            	WHERE ezo.relation_to_primary_holding IN ('Replaced By','1035 Exchange')
		            GROUP BY 1
            ) rplmt ON a.transaction_id = rplmt.primary_policy_transaction_id
    LEFT JOIN add_alt_hold ON a.policy_number = add_alt_hold.policy_number
	LEFT OUTER JOIN x ON LTRIM(a.policy_number,'0') = LTRIM(x.hldg_key, '0') AND a.admin_system = x.agreement_source_cd
WHERE DATE(NB.SUBMISSION_DATE) >= DATE('2019-01-01')
)
SELECT *
FROM eligibile EL

