
SELECT A.policyNumber
, CASE WHEN MAX(A.ReplacementType) <> MIN(A.ReplacementType) = 1 THEN 'Combination' -- If not True, then it is a 1 and O therefore both internal and external
	WHEN MAX(A.ReplacementType) = 1 THEN 'Internal'
	ELSE 'Exernal'END AS ReplacementType
FROM (
	SELECT DISTINCT p.policyNumber
	, CASE WHEN LOWER(e.companyName) IN ('mass mutual','massmutual','mass mututal','massmutual life insurance co.','northwestern mutual') THEN 1
		ELSE 0
		END as 'ReplacementType' -- 1 = Internal, 0 = External
	FROM haven.existing_policy e
		LEFT JOIN haven.existing_policies x on e.existing_policies_id = x._id
		LEFT JOIN haven.applicant a on a.existingPolicies_id = x._id
		LEFT JOIN haven.policy p on p.insured_id = a._id
	WHERE e.isReplacement = True
		AND p.policyNumber IS NOT NULL
	) A
GROUP BY 1



/*
400003307
400004321
400005741
400006493
400009374
400011071
*/