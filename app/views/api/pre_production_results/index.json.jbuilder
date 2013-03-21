json.success true 
json.total @total
json.pre_production_results @objects do |object|
	json.id 				object.id 
	json.name 			object.name
	
	json.ok_quantity 				object.ok_quantity
	json.broken_quantity 		object.broken_quantity
	json.processed_quantity 		object.processed_quantity
	
	json.template_sales_item_id   	object.template_sales_item_id
	json.template_sales_item_code   	object.template_sales_item_code
	json.template_sales_item_name  	object.template_sales_item_name
	 
end
