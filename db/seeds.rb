role = {
  :system => {
    :administrator => true
  }
}

# new role for data entry 
new_role_hash = {
  

  # factory 
  :item_receivals => {
    :index => true 
  },
  :template_sales_items => {
    :index => true 
  },
  
  # sales 
  :customers => {
    :index => true 
  },
  :sales_orders => {
    :index => true 
  },
  :deliveries => {
    :index => true 
  },
  :sales_returns => {
    :index => true 
  },
  :guarantee_returns => {
    :index => true 
  },
  
  # payments
  
  :invoices => {
    :index => true 
  },
  :payments => {
    :index => true 
  }
}

# new_role_hash = {
#   :materials => {
#     :index => false
#   }
# }

Role.create!(
:name        => ROLE_NAME[:admin],
:title       => 'Administrator',
:description => 'Role for administrator',
:the_role    => role.to_json
)
admin_role = Role.find_by_name ROLE_NAME[:admin]
first_role = Role.first

data_entry_role = {
  :customers => {
    :new => true,
    :create => true, 
    :edit => true, 
    :update_customer => true ,
    :delete_customer => true  
  },
  :sales_orders => {
    :new => true,
    :create => true, 
    :edit => true, 
    :update_sales_order => true ,
    :delete_sales_order => true ,
    :confirm_sales_order => true,
    :print_sales_order => true 
  },
      :sales_items => {
        :new => true,
        :create => true, 
        :edit => true, 
        :update_sales_item => true ,
        :delete_sales_item => true ,
        :confirm_sales_item => true,
        :new_derivative => true, 
        :create_derivative => true ,
        :edit_derivative => true,
        :update_derivative => true  
      },
  :pre_production_histories => {
    :new => true,
    :create => true, 
    :edit => true, 
    :update_pre_production_history => true ,
    :delete_pre_production_history => true,
    :confirm_pre_production_history => true
  },
  :production_histories => {
    :new => true,
    :create => true, 
    :edit => true, 
    :update_production_history => true ,
    :delete_production_history => true,
    :confirm_production_history => true
  },
  :post_production_histories => {
    :new => true,
    :create => true, 
    :edit => true, 
    :update_post_production_history => true ,
    :delete_post_production_history => true,
    :confirm_post_production_history => true
  },
  :deliveries => {
    :new => true,
    :create => true, 
    :edit => true, 
    :update_delivery => true ,
    :delete_delivery => true,
    :confirm_delivery => true,
    :finalize_delivery => true ,
    :print_delivery => true 
  },
      :delivery_entries => {
        :new => true,
        :create => true, 
        :edit => true, 
        :update_delivery_entry => true ,
        :delete_delivery_entry => true,
        :confirm_delivery_entry => true,
        :edit_post_delivery_delivery_entry => true ,
        :update_post_delivery_delivery_entry => true 
      },
      
  :sales_returns => {
    :new => true,
    :create => true, 
    :edit => true, 
    :update_sales_return => true ,
    :delete_sales_return => true,
    :confirm_sales_return => true
  },
      :sales_return_entries => {
        :new => true,
        :create => true, 
        :edit => true, 
        :update_sales_return_entry => true ,
        :delete_sales_return_entry => true 
      },
  
  :guarantee_returns => {
    :new => true,
    :create => true, 
    :edit => true, 
    :update_guarantee_return => true ,
    :delete_guarantee_return => true,
    :confirm_guarantee_return => true
  },
      :guarantee_return_entries => {
        :new => true,
        :create => true, 
        :edit => true, 
        :update_guarantee_return_entry => true ,
        :delete_guarantee_return_entry => true 
      },    
   
  :item_receivals => {
    :new => true,
    :create => true, 
    :edit => true, 
    :update_item_receival => true ,
    :delete_item_receival => true,
    :confirm_item_receival => true
  },
      :item_receival_entries => {
        :new => true,
        :create => true, 
        :edit => true, 
        :update_item_receival_entry => true ,
        :delete_item_receival_entry => true 
      },
  
  :invoices => {
    :new => true,
    :create => true, 
    :edit => true, 
    :update_invoice => true ,
    :delete_invoice => true,
    :confirm_invoice => true,
    :print_invoice => true 
  }, 
  
  :payments => {
    :new => true,
    :create => true, 
    :edit => true, 
    :update_payment => true ,
    :delete_payment => true,
    :confirm_payment => true,
    :print_payment => true 
  },
      :invoice_payments => {
        :new => true,
        :create => true, 
        :edit => true, 
        :update_invoice_payment => true ,
        :delete_invoice_payment => true 
      }
}


data_entry_role = Role.create!(
:name        => ROLE_NAME[:data_entry],
:title       => 'Data Entry',
:description => 'Role for data entry',
:the_role    => data_entry_role.to_json
)


company = Company.create(:name => "Super metal", :address => "Tanggerang", :phone => "209834290840932")
admin = User.create_main_user(   :email => "admin@gmail.com" ,:password => "willy1234", :password_confirmation => "willy1234") 

admin.set_as_main_user

data_entry = User.create_by_employee(admin, {
  :name => "Data Entry",
  :email => "rajakuraemas@gmail.com",
  :role_id => data_entry_role.id 
})
data_entry.password = 'willy1234'
data_entry.password_confirmation = 'willy1234'
data_entry.save




customer_1 = Customer.create :name => "Dixzell"
customer_2 = Customer.create :name => "Bangka Terbang"
# copper = Material.create :name => MATERIAL[:copper], :code => "C"
# alumunium = Material.create :name => MATERIAL[:alumunium], :code => "A"
# iron = Material.create :name => MATERIAL[:iron], :code => "B"

MATERIAL_CODE.each do |material_code|
  Material.create :name => material_code[:name], :code => material_code[:value]
end

copper = Material.all[0]
alumunium = Material.all[1]
iron = Material.all[2]

bank_mandiri = CashAccount.create({
  :case =>  CASH_ACCOUNT_CASE[:bank][:value]  ,
  :name => "Bank mandiri 234325321",
  :description => "Spesial untuk non taxable payment"
})

## ADDING SALES ORDER + SALES ITEMS 
# 
# sales_order   = SalesOrder.create_by_employee( admin , {
#   :customer_id    => customer_1.id,          
#   :payment_term   => PAYMENT_TERM[:cash],    
#   :order_date     => Date.new(2012, 12, 15)   
# })
# 
# quantity_in_sales_item = 50 
# has_production_sales_item = SalesItem.create_sales_item( admin, sales_order,  {
#     :material_id => copper.id, 
#     :is_pre_production => true , 
#     :is_production     => true, 
#     :is_post_production => true, 
#     :is_delivered => true, 
#     :delivery_address => "Perumahan Citra Garden 1 Blok AC2/3G",
#     :quantity_for_production => quantity_in_sales_item,
#     :quantity_for_post_production => quantity_in_sales_item,
#     :description => "Bla bla bla bla bla", 
#     :delivery_address => "Yeaaah babyy", 
#     :requested_deadline => Date.new(2013, 3,5 ),
#     :weight_per_piece   => '15',
#     :name => "Sales Item Ini" ,
#     :is_pending_pricing    => false, 
#     :is_pricing_by_weight  => false , 
#     :pre_production_price  => "50000", 
#     :production_price      => "20000",
#     :post_production_price => "150000"
#   })
#   
#   
#   
# pp_sales_order   = SalesOrder.create_by_employee( admin , {
#   :customer_id    => customer_1.id,          
#   :payment_term   => PAYMENT_TERM[:cash],    
#   :order_date     => Date.new(2012, 12, 15)   
# })
# 
#  
#    
#  puts "BEFORE CONFIRM the sales order code: #{sales_order.code}\n"*10
#  sales_order.confirm( admin )
#  pp_sales_order.confirm(admin)
#  puts "AFTER CONFIRM the sales order code: #{sales_order.code}\n"*10
#  
#  has_production_sales_item.reload 
#  template_sales_item = has_production_sales_item.template_sales_item 
# 
# 
#  pr = ProductionResult.create_result( admin,  {
#    :ok_quantity            => 20          ,
#    :repairable_quantity    => 0  ,
#    :broken_quantity        => 0      ,
#    :ok_weight              => "#{20*10}"            ,
#    :repairable_weight      => '0'    ,
#    :broken_weight          => '0'        ,
#    :started_at             => DateTime.new(2012,12,10,20,5,5)           ,
#    :finished_at            => DateTime.new(2012,12,15,20,5,5)           ,
#    :template_sales_item_id => template_sales_item.id 
# 
#  } )
#  
#  
# ppr = PostProductionResult.create_result(admin, {
#  :ok_quantity         => 10       ,
#  :broken_quantity     => 1    ,
#  :bad_source_quantity => 0  ,
#  :ok_weight           => '90'          ,
#  :broken_weight       => '8'        ,
#  :bad_source_weight   => '0'  ,
#  :started_at          =>  DateTime.new(2012,12,11,23,1,1)       ,
#  :finished_at         => DateTime.new(2012,12,15,23,1,1)    ,
#  :template_sales_item_id => template_sales_item.id 
# })
# 
# ppr.confirm( admin )
# 
# # ADDING DELIVERY 
# delivery = Delivery.create_by_employee( admin, {
#   :customer_id => customer_1.id ,
#   :delivery_address => "This is delivery address",
#   :delivery_date    => Date.new( 2012,12,12)
# } )  
# 
# has_production_sales_item.reload 
# template_sales_item.reload 
# # ok quantity = 10
# # quantity sent = ok_quantity - 5 
# # quantity sent = 5 
# 
# puts "Total ready post production: #{template_sales_item.ready_post_production}"
# quantity_sent = template_sales_item.ready_post_production - 5
# 
# delivery_entry = DeliveryEntry.create_delivery_entry( admin, delivery,  {
#   :sales_item_id => has_production_sales_item.id ,
#   :quantity_sent => quantity_sent,
#   :quantity_sent_weight =>  (quantity_sent*20).to_s,
#   :item_condition => DELIVERY_ENTRY_ITEM_CONDITION[:post_production],
#   :entry_case => DELIVERY_ENTRY_CASE[:normal]
# } ) 
# 
# puts "This is the message:* ************************"
# delivery_entry.errors.messages.each do |msg|
#   puts "The message: #{msg}"
# end
#  
#  
# delivery.confirm( admin )  
# delivery.reload 
# delivery_entry.reload 
# 
# 
# puts "Before update post delivery\n"*10
# delivery_entry.update_post_delivery(admin, {
#   :quantity_confirmed => quantity_sent , 
#   :quantity_confirmed_weight => "#{quantity_sent * 20}",
#   :quantity_returned => 0 ,
#   :quantity_returned_weight => '0' ,
#   :quantity_lost => 0
# })
# 
# delivery_entry.reload 
#  
# delivery.reload 
# delivery.finalize(admin)
# 
# delivery.reload
# pending_payment =  delivery.invoice.confirmed_pending_payment
# total_sum = ( pending_payment*0.5 ).to_s
# payment = Payment.create_by_employee(admin, {
#   :payment_method => PAYMENT_METHOD[:bank_transfer],
#   :customer_id    => customer_1.id , 
#   :note           => "Dibayarkan dengan nomor transaksi AC/2323flkajfeaij",
#   :amount_paid => total_sum,
#   :cash_account_id => bank_mandiri.id,
#   :downpayment_addition_amount => "0",
#   :downpayment_usage_amount => "0" 
# })
# 
# invoice_payment = InvoicePayment.create_invoice_payment( admin, payment,  {
#   :invoice_id  => delivery.invoice.id , 
#   :amount_paid => total_sum
# } )
# 
# payment.confirm( admin)

