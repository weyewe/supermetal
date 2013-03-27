json.success true 
json.total @total
json.objects_length @objects.length
json.delivery_entries @objects do |object|
	json.delivery_code object.delivery.code 
	json.delivery_id object.delivery_id
	  
	json.code 			object.code
	json.id 				object.id 
	json.entry_case				object.entry_case
	json.entry_case_name				object.entry_case_name
	json.item_condition   object.item_condition 
	json.item_condition_name   object.item_condition_name 
	
	json.sales_item_id				object.sales_item_id
	json.sales_item_name			object.sales_item.name
	
	json.quantity_sent 				object.quantity_sent
	json.quantity_confirmed 	object.quantity_confirmed
	json.quantity_returned 		object.quantity_returned
	json.quantity_lost 				object.quantity_lost 
	
	json.quantity_sent_weight						object.quantity_sent_weight
	json.quantity_returned_weight       object.quantity_returned_weight
	json.quantity_confirmed_weight      object.quantity_confirmed_weight
	
	json.is_confirmed		object.is_confirmed
	json.is_finalized		object.is_finalized 
end                                 
