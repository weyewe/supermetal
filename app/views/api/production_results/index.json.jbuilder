json.success true 
json.total @total
json.production_results @objects do |object|
	json.id 				object.id 
	json.is_confirmed 				object.is_confirmed 
	
	json.ok_quantity 				object.ok_quantity
	json.broken_quantity 		object.broken_quantity
	json.processed_quantity 		object.processed_quantity
	json.repairable_quantity 		object.repairable_quantity
	
	json.ok_weight 				object.ok_weight
	json.broken_weight 		object.broken_weight
	json.repairable_weight 		object.repairable_weight
	
	json.ok_tap_weight 				object.ok_tap_weight
	json.repairable_tap_weight 		object.repairable_tap_weight

	json.template_sales_item_id   		object.template_sales_item.id
	json.template_sales_item_code   	object.template_sales_item.code
	json.template_sales_item_name  		object.template_sales_item.name

	json.started_at  format_datetime( object.started_at ) 
	json.finished_at format_datetime( object.finished_at )
	 
end