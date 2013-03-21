json.success true 
json.total @total
json.template_sales_items @objects do |object|
	json.id 				object.id 
	json.name 			object.name
	
	json.pending_production 				object.pending_production
	json.pending_production_repair 	object.pending_production_repair
	json.pending_post_production   	object.pending_post_production 
	
	json.ready_production   			object.ready_production 
	json.ready_post_production   	object.ready_post_production 
end
