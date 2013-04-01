json.success true 
json.total @total
json.payments @objects do |object|
json.id 				object.id 
	json.code 			object.code
	
	json.customer_name object.customer.name 
	json.customer_id   object.customer_id 
	
	json.cash_account_name object.cash_account.name 
	json.cash_account_id   object.cash_account_id
	
	json.payment_method_name object.payment_method_name 
	json.payment_method		   object.payment_method
	
	json.is_confirmed object.is_confirmed 
	json.confirmed_at format_date( object.confirmed_at ) 
	
	json.note object.note
	
	json.amount_paid 										object.amount_paid 
	json.downpayment_usage_amount 			object.downpayment_usage_amount 
	json.downpayment_addition_amount 		object.downpayment_addition_amount 
end
