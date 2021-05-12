

SELECT paPol.policyNumber
, MIN(invt.createdTime) AS ReportedDate
FROM haven_pa.policy paPol
	INNER JOIN haven_pa.billing bill ON bill.policy_id = paPol._id
	INNER JOIN haven_pa.invoice inv ON inv.billing_id = bill._id
		AND inv.status IN ('Success','Transferred')
		AND inv."type" IN ('InitialPremium','TLICRollOver','RecurringPremium','Combined')
	INNER JOIN haven_pa.invoice_transaction invt ON invt.invoice_id = inv._id
		AND invt.status IN ('Success','Transferred')
GROUP BY 1