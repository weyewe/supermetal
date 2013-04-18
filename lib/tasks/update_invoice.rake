desc "This task is called by the Heroku cron add-on"
task :update_sales_item_confirmation => :environment do
  admin = User.find_by_email("admin@gmail.com")
  SalesItem.includes(:sales_order).where{
		( is_deleted.eq false )  & 
		( sales_order.is_confirmed.eq true ) & 
		( is_confirmed.eq false )
	}.each {|x| x.confirm }
end

task :update_outstanding_payment => :environment do
  Invoice.includes(:delivery, :customer).where{
		( delivery.is_deleted.eq true)  	
	}.each do |invoice|
		customer = invoice.customer 
		invoice.destroy 
		customer.update_outstanding_payment
	end
end


task :update_invoice_amount => :environment do
  SalesItem.includes(:sales_order).where{
  	( is_deleted.eq false )  & 
  	( sales_order.is_confirmed.eq true ) & 
  	( is_confirmed.eq false )
  }.each do |x|

  	x.update_invoice
  	x.update_work_order
  end
end




