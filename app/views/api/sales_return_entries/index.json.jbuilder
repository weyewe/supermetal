json.success true 
json.total @total
json.objects_length @objects.length
json.sales_return_entries @objects do |object|
 
	json.id object.id
	json.sales_return_code object.sales_return.code
	json.sales_return_id object.sales_return_id 
	
	json.sales_item_name object.sales_item.name 
	json.sales_item_code object.sales_item.code 
	json.sales_item_id object.sales_item_id 
	
	json.delivery_entry_id object.delivery_entry_id 
	json.delivery_entry_code object.delivery_entry.code 
	
	json.quantity_returned object.delivery_entry.quantity_returned 
	
	json.delivery_entry_entry_case_name object.delivery_entry.entry_case_name
	json.delivery_entry_item_condition_name object.delivery_entry.item_condition_name 
	
	json.quantity_for_post_production object.quantity_for_post_production
	json.quantity_for_production object.quantity_for_production
	json.quantity_for_production_repair object.quantity_for_production_repair
	
	json.weight_for_post_production object.weight_for_post_production
	json.weight_for_production object.weight_for_production
	json.weight_for_production_repair object.weight_for_production_repair 
	
	 
end
