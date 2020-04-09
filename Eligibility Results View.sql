DROP VIEW haven_analytics.CoverPathEligibilityResults;

CREATE VIEW haven_analytics.CoverPathEligibilityResults AS

WITH Eligibility as (
Select CPER.policyNumber
--, CPER.TransactionDate
, CPER.SubmittedDate
, EZCP.StartDate
, EZCP.EndDate
, CASE WHEN CPER.Product_Type_Whole_or_Term_Life                    >= EZCP.Product_Type_Whole_or_Term_Life                    	THEN 1 ELSE 0 END AS 'Product_Type_Whole_or_Term_Life'
, CASE WHEN CPER.Plan_Name_not_like_Vantage_Term_ART                >= EZCP.Plan_Name_not_like_Vantage_Term_ART                	THEN 1 ELSE 0 END AS 'Plan_Name_not_like_Vantage_Term_ART'
, CASE WHEN CPER.Plan_Name_Not_Whole_Life_Legacy_10_Pay             >= EZCP.Plan_Name_Not_Whole_Life_Legacy_10_Pay             	THEN 1 ELSE 0 END AS 'Plan_Name_Not_Whole_Life_Legacy_10_Pay'
, CASE WHEN CPER.Plan_Name_Not_Whole_Life_Legacy_12_Pay             >= EZCP.Plan_Name_Not_Whole_Life_Legacy_12_Pay             	THEN 1 ELSE 0 END AS 'Plan_Name_Not_Whole_Life_Legacy_12_Pay' --
, CASE WHEN CPER.Plan_Name_Not_Whole_Life_Legacy_15_Pay             >= EZCP.Plan_Name_Not_Whole_Life_Legacy_15_Pay             	THEN 1 ELSE 0 END AS 'Plan_Name_Not_Whole_Life_Legacy_15_Pay' --
, CASE WHEN CPER.Plan_Name_not_like_Whole_Life_Legacy_20            >= EZCP.Plan_Name_not_like_Whole_Life_Legacy_20            	THEN 1 ELSE 0 END AS 'Plan_Name_not_like_Whole_Life_Legacy_20'
, CASE WHEN CPER.Product_Type_not_Whole_Life_or_Term_Life           >= EZCP.Product_Type_not_Whole_Life_or_Term_Life           	THEN 1 ELSE 0 END AS 'Product_Type_not_Whole_Life_or_Term_Life'
, CASE WHEN CPER.Plan_Name_not_Like_Whole_Life_Legacy_65            >= EZCP.Plan_Name_not_Like_Whole_Life_Legacy_65            	THEN 1 ELSE 0 END AS 'Plan_Name_not_Like_Whole_Life_Legacy_65'
, CASE WHEN CPER.Plan_Name_not_Like_Survivorship                    >= EZCP.Plan_Name_not_Like_Survivorship                    	THEN 1 ELSE 0 END AS 'Plan_Name_not_Like_Survivorship'
, CASE WHEN CPER.Plan_Name_not_Like_CareChoice                      >= EZCP.Plan_Name_not_Like_CareChoice                      	THEN 1 ELSE 0 END AS 'Plan_Name_not_Like_CareChoice'
, CASE WHEN CPER.Plan_Name_not_Like_HECV                            >= EZCP.Plan_Name_not_Like_HECV                            	THEN 1 ELSE 0 END AS 'Plan_Name_not_Like_HECV'
, CASE WHEN CPER.Plan_Name_not_Like_ECP                             >= EZCP.Plan_Name_not_Like_ECP                             	THEN 1 ELSE 0 END AS 'Plan_Name_not_Like_ECP'
, CASE WHEN CPER.Plan_Name_not_Like_25                              >= EZCP.Plan_Name_not_Like_25                              	THEN 1 ELSE 0 END AS 'Plan_Name_not_Like_25'
, CASE WHEN CPER.Plan_Name_not_Like_30                              >= EZCP.Plan_Name_not_Like_30                              	THEN 1 ELSE 0 END AS 'Plan_Name_not_Like_30'
, CASE WHEN CPER.Plan_Name_not_Like_15                              >= EZCP.Plan_Name_not_Like_15                              	THEN 1 ELSE 0 END AS 'Plan_Name_not_Like_15'
, CASE WHEN CPER.Additional_Holding_Prod_Type_excluding_Term_Life   >= EZCP.Additional_Holding_Prod_Type_excluding_Term_Life   	THEN 1 ELSE 0 END AS 'Additional_Holding_Prod_Type_excluding_Term_Life'
, CASE WHEN CPER.Additional_Holding_Prod_Type_excluding_Whole_Life  >= EZCP.Additional_Holding_Prod_Type_excluding_Whole_Life  	THEN 1 ELSE 0 END AS 'Additional_Holding_Prod_Type_excluding_Whole_Life'
, CASE WHEN CPER.Additional_Holding_doesnt_exist                    >= EZCP.Additional_Holding_doesnt_exist                    	THEN 1 ELSE 0 END AS 'Additional_Holding_doesnt_exist'
, CASE WHEN CPER.Alternative_Holding_Prod_Type_excluding_Whole_Life >= EZCP.Alternative_Holding_Prod_Type_excluding_Whole_Life 	THEN 1 ELSE 0 END AS 'Alternative_Holding_Prod_Type_excluding_Whole_Life'
, CASE WHEN CPER.Alternative_Holding_Prod_Type_excluding_Term_Life  >= EZCP.Alternative_Holding_Prod_Type_excluding_Term_Life  	THEN 1 ELSE 0 END AS 'Alternative_Holding_Prod_Type_excluding_Term_Life'
, CASE WHEN CPER.Alternative_Holding_doesnt_exist                   >= EZCP.Alternative_Holding_doesnt_exist                   	THEN 1 ELSE 0 END AS 'Alternative_Holding_doesnt_exist'
, CASE WHEN CPER.DI_Concur_is_Null                                  >= EZCP.DI_Concur_is_Null                                  	THEN 1 ELSE 0 END AS 'DI_Concur_is_Null'
, CASE WHEN CPER.Entity_is_0                                        >= EZCP.Entity_is_0                                        	THEN 1 ELSE 0 END AS 'Entity_is_0'
, CASE WHEN CPER.Organization_is_0                                  >= EZCP.Organization_is_0                                  	THEN 1 ELSE 0 END AS 'Organization_is_0'
, CASE WHEN CPER.Is_Non_Resident                                    >= EZCP.Is_Non_Resident                                     THEN 1 ELSE 0 END AS 'Is_Non_Resident' --
, CASE WHEN CPER.Is_Resident_Or_Alien                               >= EZCP.Is_Resident_Or_Alien                                THEN 1 ELSE 0 END AS 'Is_Resident_Or_Alien' --
, CASE WHEN CPER.Intent_to_Sell                                     >= EZCP.Intent_to_Sell                                     	THEN 1 ELSE 0 END AS 'Intent_to_Sell'
, CASE WHEN CPER.Collateral_is_Not_Assigned                         >= EZCP.Collateral_is_Not_Assigned                         	THEN 1 ELSE 0 END AS 'Collateral_is_Not_Assigned'
, CASE WHEN CPER.No_Economic_Incentive                              >= EZCP.No_Economic_Incentive                              	THEN 1 ELSE 0 END AS 'No_Economic_Incentive'
, CASE WHEN CPER.Insured_Over_64                    				>= EZCP.Insured_Over_64                    				   	THEN 1 ELSE 0 END AS 'Insured_Over_64' --
, CASE WHEN CPER.Insured_Under_18                    				>= EZCP.Insured_Under_18                    				THEN 1 ELSE 0 END AS 'Insured_Under_18' --
, CASE WHEN CPER.Face_Amount_Under_3Million                    		>= EZCP.Face_Amount_Under_3Million                    		THEN 1 ELSE 0 END AS 'Face_Amount_Under_3Million' --
, CASE WHEN CPER.Insured_Age_61_To_64_Over_1_Million                >= EZCP.Insured_Age_61_To_64_Over_1_Million                 THEN 1 ELSE 0 END AS 'Insured_Age_61_To_64_Over_1_Million' --
, CASE WHEN CPER.Source_of_Funds_not_like_Premium_Financing         >= EZCP.Source_of_Funds_not_like_Premium_Financing         	THEN 1 ELSE 0 END AS 'Source_of_Funds_not_like_Premium_Financing'
, CASE WHEN CPER.sponsoring_plan_type_A1000_and_A2000_are_not_1     >= EZCP.sponsoring_plan_type_A1000_and_A2000_are_not_1     	THEN 1 ELSE 0 END AS 'sponsoring_plan_type_A1000_and_A2000_are_not_1'
, CASE WHEN CPER.Not_a_Quick_Close                                  >= EZCP.Not_a_Quick_Close                                  	THEN 1 ELSE 0 END AS 'Not_a_Quick_Close'
, CASE WHEN CPER.Conversion_is_0                                    >= EZCP.Conversion_is_0                                    	THEN 1 ELSE 0 END AS 'Conversion_is_0'
, CASE WHEN CPER.Not_Whole_Policy_With_Replacement                  >= EZCP.Not_Whole_Policy_With_Replacement                   THEN 1 ELSE 0 END AS 'Not_Whole_Policy_With_Replacement' --
, CASE WHEN CPER.Not_Term_Policy_With_Replacement                   >= EZCP.Not_Term_Policy_With_Replacement                    THEN 1 ELSE 0 END AS 'Not_Term_Policy_With_Replacement' --
, CASE WHEN CPER.Holding_Type_Not_Like_1035                         >= EZCP.Holding_Type_Not_Like_1035                         	THEN 1 ELSE 0 END AS 'Holding_Type_Not_Like_1035'
, CASE WHEN CPER.Permanant_Table_Rating_doesnt_exist                >= EZCP.Permanant_Table_Rating_doesnt_exist                	THEN 1 ELSE 0 END AS 'Permanant_Table_Rating_doesnt_exist'
, CASE WHEN CPER.Max_Flat_Extra_On_Parent_doesnt_exist              >= EZCP.Max_Flat_Extra_On_Parent_doesnt_exist              	THEN 1 ELSE 0 END AS 'Max_Flat_Extra_On_Parent_doesnt_exist'
--, CASE WHEN CPER.rider_doesnt_exist_or_is_Waiver_of_Premium         >= EZCP.rider_doesnt_exist_or_is_Waiver_of_Premium         	THEN 1 ELSE 0 END AS 'rider_doesnt_exist_or_is_Waiver_of_Premium'
, CASE WHEN CPER.No_Owner_Number_2                                  >= EZCP.No_Owner_Number_2                                  	THEN 1 ELSE 0 END AS 'No_Owner_Number_2'
, CASE WHEN CPER.Not_Trust_or_Organization_as_Primary_Owner         >= EZCP.Not_Trust_or_Organization_as_Primary_Owner         	THEN 1 ELSE 0 END AS 'Not_Trust_or_Organization_as_Primary_Owner'
, CASE WHEN CPER.Owner_must_be_US_Citizen                           >= EZCP.Owner_must_be_US_Citizen                           	THEN 1 ELSE 0 END AS 'Owner_must_be_US_Citizen'
, CASE WHEN CPER.Exclude_Business_Purpose_Intent_for_Insurance      >= EZCP.Exclude_Business_Purpose_Intent_for_Insurance      	THEN 1 ELSE 0 END AS 'Exclude_Business_Purpose_Intent_for_Insurance'
, CASE WHEN CPER.Exclude_Residency_States_for_Insured_FL            >= EZCP.Exclude_Residency_States_for_Insured_FL            	THEN 1 ELSE 0 END AS 'Exclude_Residency_States_for_Insured_FL'
, CASE WHEN CPER.Exclude_Residency_States_for_Insured_NY     		>= EZCP.Exclude_Residency_States_for_Insured_NY     	   	THEN 1 ELSE 0 END AS 'Exclude_Residency_States_for_Insured_NY' --
, CASE WHEN CPER.Exclude_Residency_States_for_Insured_PR     		>= EZCP.Exclude_Residency_States_for_Insured_PR     	   	THEN 1 ELSE 0 END AS 'Exclude_Residency_States_for_Insured_PR' --
, CASE WHEN CPER.Exclude_Residency_States_for_Insured_6_States      >= EZCP.Exclude_Residency_States_for_Insured_6_States      	THEN 1 ELSE 0 END AS 'Exclude_Residency_States_for_Insured_6_States'
, CASE WHEN CPER.Accelerated_Death_Benefit_Rider					>= EZCP.Accelerated_Death_Benefit_Rider						THEN 1 ELSE 0 END AS 'Accelerated_Death_Benefit_Rider'
, CASE WHEN CPER.Additional_Life_Insurance_Rider					>= EZCP.Additional_Life_Insurance_Rider						THEN 1 ELSE 0 END AS 'Additional_Life_Insurance_Rider'
, CASE WHEN CPER.Estate_Protection_Rider							>= EZCP.Estate_Protection_Rider								THEN 1 ELSE 0 END AS 'Estate_Protection_Rider'
, CASE WHEN CPER.Extended_LTC_Benefits_Rider_Amount					>= EZCP.Extended_LTC_Benefits_Rider_Amount					THEN 1 ELSE 0 END AS 'Extended_LTC_Benefits_Rider_Amount'
, CASE WHEN CPER.Guaranteed_Insurability_Rider						>= EZCP.Guaranteed_Insurability_Rider						THEN 1 ELSE 0 END AS 'Guaranteed_Insurability_Rider'
, CASE WHEN CPER.Life_Insurance_Supplement_Rider					>= EZCP.Life_Insurance_Supplement_Rider						THEN 1 ELSE 0 END AS 'Life_Insurance_Supplement_Rider'
, CASE WHEN CPER.Long_Term_Care										>= EZCP.Long_Term_Care										THEN 1 ELSE 0 END AS 'Long_Term_Care'
, CASE WHEN CPER.Planned_Additional_Life_Insurance_Rider			>= EZCP.Planned_Additional_Life_Insurance_Rider				THEN 1 ELSE 0 END AS 'Planned_Additional_Life_Insurance_Rider'
, CASE WHEN CPER.Renewable_Term_Rider								>= EZCP.Renewable_Term_Rider								THEN 1 ELSE 0 END AS 'Renewable_Term_Rider'
, CASE WHEN CPER.Waiver_Of_Premium									>= EZCP.Waiver_Of_Premium									THEN 1 ELSE 0 END AS 'Waiver_Of_Premium'
, CASE WHEN CPER.Exclude_Policies_with_Multiple_Agency_IDs          >= EZCP.Exclude_Policies_with_Multiple_Agency_IDs          	THEN 1 ELSE 0 END AS 'Exclude_Policies_with_Multiple_Agency_IDs'
, CASE WHEN CPER.Policy_With_Career_And_Broker                      >= EZCP.Policy_With_Career_And_Broker                      	THEN 1 ELSE 0 END AS 'Policy_With_Career_And_Broker'
FROM haven_analytics.CoverPathEligibilityRules CPER -- Per Policy, 1 or 0 on each rule
	INNER JOIN haven_analytics.EZ_APP_CoverPath_Eligibility_Reference EZCP -- Rules Table which includes 1 or 0 if rule needs to be followed, by time range
		ON CPER.SubmittedDate BETWEEN EZCP.StartDate AND EZCP.EndDate
		--ON CPER.TransactionDate BETWEEN EZCP.StartDate AND EZCP.EndDate
)
, Rules AS (
Select EL.*
,  Product_Type_Whole_or_Term_Life
+ Plan_Name_not_like_Vantage_Term_ART
+ Plan_Name_Not_Whole_Life_Legacy_10_Pay
+ Plan_Name_Not_Whole_Life_Legacy_12_Pay
+ Plan_Name_Not_Whole_Life_Legacy_15_Pay
+ Plan_Name_not_like_Whole_Life_Legacy_20
+ Product_Type_not_Whole_Life_or_Term_Life
+ Plan_Name_not_Like_Whole_Life_Legacy_65
+ Plan_Name_not_Like_Survivorship
+ Plan_Name_not_Like_CareChoice
+ Plan_Name_not_Like_HECV
+ Plan_Name_not_Like_ECP
+ Plan_Name_not_Like_25
+ Plan_Name_not_Like_30
+ Plan_Name_not_Like_15
+ Additional_Holding_Prod_Type_excluding_Term_Life
+ Additional_Holding_Prod_Type_excluding_Whole_Life
+ Additional_Holding_doesnt_exist
+ Alternative_Holding_Prod_Type_excluding_Whole_Life
+ Alternative_Holding_Prod_Type_excluding_Term_Life
+ Alternative_Holding_doesnt_exist
+ DI_Concur_is_Null
+ Entity_is_0
+ Organization_is_0
+ Is_Non_Resident
+ Is_Resident_Or_Alien                                  
+ Intent_to_Sell                                      
+ Collateral_is_Not_Assigned                               
+ No_Economic_Incentive                                
+ Insured_Over_64                                     
+ Insured_Under_18                                      
+ Face_Amount_Under_3Million                           
+ Insured_Age_61_To_64_Over_1_Million                  
+ Source_of_Funds_not_like_Premium_Financing              
+ sponsoring_plan_type_A1000_and_A2000_are_not_1           
+ Not_a_Quick_Close                                        
+ Conversion_is_0                                         
+ Not_Whole_Policy_With_Replacement                     
+ Not_Term_Policy_With_Replacement                      
+ Holding_Type_Not_Like_1035                               
+ Permanant_Table_Rating_doesnt_exist                      
+ Max_Flat_Extra_On_Parent_doesnt_exist                    
--+ rider_doesnt_exist_or_is_Waiver_of_Premium               
+ No_Owner_Number_2                                        
+ Not_Trust_or_Organization_as_Primary_Owner               
+ Owner_must_be_US_Citizen                                 
+ Exclude_Business_Purpose_Intent_for_Insurance            
+ Exclude_Residency_States_for_Insured_FL                  
+ Exclude_Residency_States_for_Insured_NY              
+ Exclude_Residency_States_for_Insured_PR               
+ Exclude_Residency_States_for_Insured_6_States            
+ Accelerated_Death_Benefit_Rider
+ Additional_Life_Insurance_Rider
+ Estate_Protection_Rider
+ Extended_LTC_Benefits_Rider_Amount
+ Guaranteed_Insurability_Rider
+ Life_Insurance_Supplement_Rider
+ Long_Term_Care
+ Planned_Additional_Life_Insurance_Rider
+ Renewable_Term_Rider                     
+ Waiver_Of_Premium
+ Exclude_Policies_with_Multiple_Agency_IDs
+ Policy_With_Career_And_Broker
	AS 'RulesPassed'
FROM Eligibility EL
)
Select R.*
, CASE WHEN R.RulesPassed = 62 THEN 1 ELSE 0 END AS 'EligibleFlg'
FROM Rules R