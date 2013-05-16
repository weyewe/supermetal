json.success true 
json.total @total
json.pre_production_results @objects do |object|
	json.id 				object.id 
	json.is_confirmed 				object.is_confirmed 
	
	json.in_progress_quantity 				object.in_progress_quantity
	
	
	json.ok_quantity 				object.ok_quantity
	json.broken_quantity 		object.broken_quantity
	json.processed_quantity 		object.processed_quantity
	
	json.template_sales_item_id   		object.template_sales_item.id
	json.template_sales_item_code   	object.template_sales_item.code
	json.template_sales_item_name  		object.template_sales_item.name
	
	json.started_at  format_datetime( object.started_at ) 
	json.finished_at format_datetime( object.finished_at ) 
	 
end
