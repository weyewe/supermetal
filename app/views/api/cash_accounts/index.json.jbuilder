json.success true 
json.total @total
json.cash_accounts @objects do |object|
	json.id 				object.id 
	
	json.case				object.case
	json.case_name  object.case_name 
	json.name 			object.name
	
	json.description 			object.description
	 
end
