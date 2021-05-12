
SELECT DISTINCT mp.policy_id
, mp.policyNumber
, CASE WHEN iq.paymentFrequency = 'Monthly' THEN 12 ELSE 1 END *
	(COALESCE(iq.premium,0) + COALESCE(iq.waiverOfPremiumAmount,0) + COALESCE(rider.quoteRiderPremium,0))
	AS AnnualizedQuotePremium
FROM haven_analytics.main_policy mp
	LEFT JOIN (
		SELECT pol._id AS policy_id
			, CASE WHEN pol.productType <> iq.productType THEN iqj._id ELSE iq._id END AS quoteId -- getting the right quote_id for joint apps
		FROM haven.policy pol
			INNER JOIN haven.application app ON app._id = pol.application_id
			INNER JOIN haven.insurance_quotes iq ON iq._id = app.insurance_quotes_id
			LEFT JOIN haven.insurance_quotes iqj ON iqj._id = iq.insurance_quotes_id
		) quote ON quote.policy_id = mp.policy_id
	LEFT JOIN haven.insurance_quotes iq ON iq._id = quote.quoteId
	LEFT JOIN (
		SELECT iqr.insurance_quotes_id
			, SUM(COALESCE(iqr.premiumBase,0) + COALESCE(iqr.premiumWaiver,0)) AS quoteRiderPremium
		FROM haven.insurance_quotes_rider iqr
		GROUP BY 1
		) rider ON rider.insurance_quotes_id = quote.quoteId -- structured to include all future riders
WHERE mp.channel = 'CAS'
	AND mp.policy_id IS NOT NULL
