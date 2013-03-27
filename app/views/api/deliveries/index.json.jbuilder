json.success true 
json.total @total
json.deliveries @objects do |object|
	json.code 			object.code
	json.customer_name object.customer.name 
	json.customer_id   object.customer_id 
	json.id 				object.id 
	json.is_confirmed object.is_confirmed 
	json.is_finalized object.is_finalized
	
	json.delivery_address object.delivery_address
	json.delivery_date object.delivery_date 
end
