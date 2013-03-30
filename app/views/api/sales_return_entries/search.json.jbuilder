json.success true 
json.total @total
json.records @objects do |object|
	json.id 						object.id
	json.name 			object.name 
	json.code 			object.code 
	json.ready_production 						object.template_sales_item.ready_production
	json.ready_post_production 				object.template_sales_item.ready_post_production
end
