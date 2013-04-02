json.success true 
json.total @total
json.guarantee_returns @objects do |object|
	json.id 					object.id 
	json.code 				object.code 
	
	json.customer_id object.customer.id
	json.customer_name object.customer.name 


	json.receival_date 			format_date( 	object.receival_date  )  
	json.is_confirmed object.is_confirmed 
end
