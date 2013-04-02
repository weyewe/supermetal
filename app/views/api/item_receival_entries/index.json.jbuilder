json.success true 
json.total @total
json.item_receival_entries @objects do |object|
	json.id 					object.id 
	json.code 				object.code 
	
	json.item_receival_id 					object.item_receival.id 
	json.item_receival_code 				object.item_receival.code 
	
	json.sales_item_id 		object.sales_item.id
	json.sales_item_code 	object.sales_item.code 
	json.sales_item_name 	object.sales_item.name 

	json.is_confirmed 				object.is_confirmed 

end
