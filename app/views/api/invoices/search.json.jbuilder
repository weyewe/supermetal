json.success true 
json.total @total
json.records @objects do |object|
	json.id 						object.id
	json.code 			object.code 
	json.customer_name 						object.customer.name 
	
	json.confirmed_pending_payment object.confirmed_pending_payment 
end
