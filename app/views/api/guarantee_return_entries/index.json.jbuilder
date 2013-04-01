json.success true 
json.total @total
json.guarantee_return_entries @objects do |object|
	json.id 					object.id 
	json.code 				object.code 
	
	json.guarantee_return_id 					object.guarantee_return.id 
	json.guarantee_return_code 				object.guarantee_return.code 
	
	json.sales_item_id 		object.sales_item.id
	json.sales_item_code 	object.sales_item.code 
	json.sales_item_name 	object.sales_item.name 
	
	json.item_condition 			object.item_condition
	json.item_condition_name 	object.item_condition_name
 

	json.quantity_for_production 			object.quantity_for_production
	json.weight_for_production 				object.weight_for_production
	
	json.quantity_for_production_repair 			object.quantity_for_production_repair
	json.weight_for_production_repair 				object.weight_for_production_repair
	
	json.quantity_for_post_production 			object.quantity_for_post_production
	json.weight_for_post_production 				object.weight_for_post_production

end
