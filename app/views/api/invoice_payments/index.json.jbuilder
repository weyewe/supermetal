json.success true 
json.total @total
json.invoice_payments @objects do |object|
	json.id 				object.id 
	
	json.payment_id object.payment.id
	json.payment_code object.payment.code 
	
	json.invoice_id object.invoice.id
	json.invoice_code object.invoice.code

	json.amount_paid 			  object.amount_paid 
	json.is_confirmed object.is_confirmed 
end
