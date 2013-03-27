json.success true 
json.total @total
json.records @objects do |object|
	json.value 						object[:value]
	json.text 					object[:text] 
end
