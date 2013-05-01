json.success true 
json.total @total
json.objects_length @objects.length
json.invoice_entries @objects do |object|

	  
	json.code 			object.code
	json.id 				object.id 
	json.entry_case				object.entry_case
	json.entry_case_name				object.entry_case_name
	json.item_condition   object.item_condition 
	json.item_condition_name   object.item_condition_name 
	
	json.sales_item_id				object.sales_item_id
	json.sales_item_name			object.sales_item.name
	json.sales_item_code			object.sales_item.code
	json.sales_item_description			object.sales_item.description 
	
	json.tax_amount object.tax_amount
	
	json.sales_item_is_pre_production					object.sales_item.is_pre_production  
	json.sales_item_is_production							object.sales_item.is_production		  
	json.sales_item_is_post_production				object.sales_item.is_post_production 
	json.sales_item_is_pricing_by_weight			object.sales_item.is_pricing_by_weight
	json.sales_item_pre_production_price			object.sales_item.pre_production_price	 
	json.sales_item_production_price					object.sales_item.production_price			 
	json.sales_item_post_production_price			object.sales_item.post_production_price
	
	
	
	
	
	json.billed_quantity 				object.billed_quantity
	json.billed_weight 	object.billed_weight
	json.total_delivery_entry_price object.total_delivery_entry_price
	
	
end                                 
