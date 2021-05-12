-- Copy Code
SELECT cust._id
, cust.channel
, cust.createdtime
, COALESCE(cust.passwordhash IS NOT NULL OR ID.provider IS NOT NULL,FALSE) AS 'AccountCreate_ir'
FROM haven.customer cust
	LEFT JOIN haven.account_authorization aau ON aau.managedEntityId = cust._id
	LEFT JOIN haven."identity" id ON id.account_id = aau.account_id
		AND ID.provider IN ('auth0','amc')
		AND ID.isActive = TRUE