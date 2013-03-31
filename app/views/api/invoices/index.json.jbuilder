json.success true 
json.total @total
json.invoices @objects do |object|
	json.id 				object.id 
	json.code 			object.code
	
	json.delivery_code object.delivery.code
	json.customer_name object.customer.name 
	
	json.due_date 					format_date( object.due_date )  
	
	json.amount_payable 						object.amount_payable
	json.base_amount_payable 				object.base_amount_payable
	json.tax_amount_payable 				object.tax_amount_payable 	
	
	
	json.confirmed_pending_payment object.confirmed_pending_payment 
	json.is_confirmed object.is_confirmed 
end
 