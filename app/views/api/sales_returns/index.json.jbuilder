json.success true 
json.total @total
json.sales_returns @objects do |object|
	json.id 				object.id 
	json.code 			object.code
	
	json.customer_name object.delivery.customer.name 
	json.delivery_id object.delivery_id
	json.delivery_code object.delivery.code 
	json.is_confirmed object.is_confirmed 
end
