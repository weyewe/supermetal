json.success true 
json.total @total
json.post_production_results @objects do |object|
	json.id 				object.id 
	json.is_confirmed 				object.is_confirmed 
	
	json.ok_quantity 				object.ok_quantity
	json.broken_quantity 		object.broken_quantity
	json.bad_source_quantity 		object.bad_source_quantity
	json.in_progress_quantity 				object.in_progress_quantity
	
	json.ok_weight 				object.ok_weight
	json.broken_weight 		object.broken_weight
	json.bad_source_weight 		object.bad_source_weight
	
 

	json.template_sales_item_id   		object.template_sales_item.id
	json.template_sales_item_code   	object.template_sales_item.code
	json.template_sales_item_name  		object.template_sales_item.name

	json.started_at  format_datetime( object.started_at ) 
	json.finished_at format_datetime( object.finished_at )
	 
end
