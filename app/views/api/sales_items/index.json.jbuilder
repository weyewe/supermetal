json.success true 
json.total @total
json.objects_length @objects.length
json.sales_items @objects do |object|
	json.sales_order_code object.sales_order.code 
	json.sales_order_id object.sales_order_id  
	json.code 			object.code
	json.id 				object.id 
	json.case				object.case 
	
	json.name							object.name
	json.description			object.description
	
	
	json.material_id							object.material_id
	json.weight_per_piece					object.weight_per_piece
	
	json.is_pending_pricing				object.is_pending_pricing 
	
	json.is_pre_production				object.is_pre_production  
	json.is_production						object.is_production		  
	json.is_post_production				object.is_post_production 
	
	json.is_pricing_by_weight			object.is_pricing_by_weight
	
	json.pre_production_price				object.pre_production_price	 
	json.production_price						object.production_price			 
	json.post_production_price			object.post_production_price
	
	json.quantity_for_production					object.quantity_for_production
	json.quantity_for_post_production			object.quantity_for_post_production
	
	json.is_delivered					object.is_delivered
	json.delivery_address			object.delivery_address
	
end
