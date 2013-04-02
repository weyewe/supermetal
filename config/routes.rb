Supermetal::Application.routes.draw do
  devise_for :users
  devise_scope :user do
    get "sign_in", :to => "devise/sessions#new"
  end
  
  root :to => 'home#extjs'
  # match 'extjs' => 'home#extjs', :as => :extjs_version
  
  namespace :api do
    devise_for :users
    match 'authenticate_auth_token' => 'sessions#authenticate_auth_token', :as => :authenticate_auth_token
    match 'update_password' => "passwords#update" , :as => :update_password, :method => :put
    
    match 'search_customer' => 'customers#search', :as => :search_customer, :method => :get
    match 'search_employee' => 'employees#search', :as => :search_employee, :method => :get
    match 'search_vendor' => 'vendors#search', :as => :search_vendor, :method => :get
    match 'search_item' => 'items#search', :as => :search_items, :method => :get
    match 'search_material' => 'materials#search', :as => :search_materials, :method => :get
    match 'search_purchase_order_entry' => 'purchase_order_entries#search', :as => :search_purchase_order_entries, :method => :get
    match 'search_sales_order_entry' => 'sales_order_entries#search', :as => :search_sales_order_entries, :method => :get
    
    match 'search_delivery' => 'deliveries#search', :as => :search_deliveries, :method => :get
    match 'search_delivery_entry' => 'delivery_entries#search', :as => :search_delivery_entries, :method => :get
    
    match 'search_sales_items' => 'sales_items#search', :as => :search_sales_items, :method => :get
    match 'search_delivery_entry_case'  => "delivery_entries#search_entry_case" , :as => :search_delivery_entry_case, :method => :get
    match 'search_delivery_item_condition'  => "delivery_entries#search_item_condition" , :as => :search_delivery_item_condition, :method => :get
    
    match 'search_cash_account'  => "cash_accounts#search" , :as => :search_cash_account, :method => :get
    match 'search_cash_account_case'  => "cash_accounts#search_case" , :as => :search_cash_account_case, :method => :get
    
    match 'search_payment_method'  => "payments#search_payment_method" , :as => :search_cash_account, :method => :get
    
    match 'search_invoice'  => "invoices#search" , :as => :search_invoice, :method => :get
    
    resources :employees
    resources :cash_accounts
    
    resources :materials
    resources :vendors
    resources :customers
    resources :app_users 
    resources :items 
    resources :stock_migrations 
    
    resources :purchase_orders
    match 'confirm_purchase_order' => 'purchase_orders#confirm' , :as => :confirm_purchase_order, :method => :post 
    resources :purchase_order_entries 
    
    resources :purchase_receivals
    match 'confirm_purchase_receival' => 'purchase_receivals#confirm', :as => :confirm_purchase_receival, :method => :post 
    resources :purchase_receival_entries
    
    
    resources :sales_orders 
    match 'confirm_sales_order' => 'sales_orders#confirm', :as => :confirm_sales_order, :method => :post
    resources :sales_items
    
    resources :template_sales_items
    resources :pre_production_results   
    match 'confirm_pre_production_result' => 'pre_production_results#confirm' , :as => :confirm_pre_production_result, :method => :post 
    
    resources :production_results   
    match 'confirm_production_result' => 'production_results#confirm' , :as => :confirm_production_result, :method => :post
    
    resources :production_repair_results   
    match 'confirm_production_repair_result' => 'production_repair_results#confirm' , :as => :confirm_production_repair_result, :method => :post
    
    resources :post_production_results   
    match 'confirm_post_production_result' => 'post_production_results#confirm' , :as => :confirm_post_production_result, :method => :post
    
    resources :deliveries 
    match 'confirm_delivery' => 'deliveries#confirm', :as => :confirm_delivery, :method => :post
    match 'finalize_delivery' => 'deliveries#finalize', :as => :finalize_delivery, :method => :post
    
    resources :delivery_entries 
    
    resources :sales_returns
    match 'confirm_sales_return' => 'sales_returns#confirm', :as => :confirm_sales_return, :method => :post
    resources :sales_return_entries 
    
    resources :delivery_losts
    match 'confirm_delivery_lost' => 'delivery_losts#confirm', :as => :confirm_delivery_lost, :method => :post
    resources :delivery_lost_entries 
    
    resources :invoices 
    resources :payments
    match 'confirm_payment' => 'payments#confirm', :as => :confirm_payment, :method => :post
    resources :invoice_payments 
    
    
    resources :guarantee_returns
    match 'confirm_guarantee_return' => 'guarantee_returns#confirm', :as => :confirm_guarantee_return, :method => :post
    resources :guarantee_return_entries
    
    resources :item_receivals
    match 'confirm_item_receival' => 'item_receivals#confirm', :as => :confirm_item_receival, :method => :post
    resources :item_receival_entries
    
  end
  
  

  


  match 'report' => 'home#report', :as => :report 
  netzke
  
  
  resources :customers do
    resources :downpayment_histories 
  end
  resources :materials
  resources :companies 
  match 'edit_main_company' => 'companies#edit_main_company', :as => :edit_main_company, :method => :post 
  match 'update_company/:id' => 'companies#update_company', :as => :update_company, :method => :post 
  
  resources :users
  resources :app_users
  
  resources :sales_orders do 
    resources :sales_items 
  end
  
  resources :item_receivals do
    resources :item_receival_entries 
  end
  
  resources :template_sales_items do 
    resources :pre_production_results
    resources :production_results
    resources :production_repair_results
    resources :post_production_results 
  end
  
  resources :pre_production_results
  resources :production_results
  resources :production_repair_results
  resources :post_production_results
  
#   GONNA TERMINATE the pre_production histories
  resources :sales_items do 
    resources :pre_production_histories
    resources :production_histories
    resources :post_production_histories
  end
  resources :pre_production_histories
  resources :production_histories
  resources :post_production_histories
  
  resources :deliveries do
    resources :delivery_entries 
  end
  
  resources :sales_returns do
    resources :sales_return_entries
  end
  
  resources :guarantee_returns do 
    resources :guarantee_return_entries 
  end
  
  resources :invoices 
  
  resources :payments  do
    resources :invoice_payments 
  end
  resources :cash_accounts
  
  
=begin
  SEARCH DATA
=end
  match 'search_customer' => "customers#search_customer", :as => :search_customer 
  
  match 'search_template_sales_item' => "template_sales_items#search_template_sales_item", :as => :search_template_sales_item 
  match 'search_sales_item' => "sales_items#search_sales_item", :as => :search_sales_item 
  match 'search_sales_order' => 'sales_orders#search_sales_order' , :as => :search_sales_order
  match 'search_delivery' => 'deliveries#search_delivery' , :as => :search_delivery
  
  match 'search_payment' => 'payments#search_payment' , :as => :search_payment
  match 'search_guarantee_return' => 'guarantee_returns#search_guarantee_return' , :as => :search_guarantee_return
  match 'search_item_receival' => 'item_receivals#search_item_receival' , :as => :search_item_receival
##################################################
##################################################
######### REPORT_ROUTES 
##################################################
##################################################
  match 'production_details/:sales_item_id' => 'home#production_details', :as => :production_details
  match 'post_production_details/:sales_item_id' => 'home#post_production_details', :as => :post_production_details
  match 'delivery_entry_details/:sales_item_id' => 'home#delivery_entry_details', :as => :delivery_entry_details
  
 
  match 'customers_with_outstanding_payment' => 'home#customers_with_outstanding_payment', :as => :customers_with_outstanding_payment
  match 'outstanding_payment_details/:customer_id' => 'home#outstanding_payment_details', :as => :outstanding_payment_details
=begin
  MASTER DATA ROUTES
=end
 

##################################################
##################################################
######### MATERIAL
##################################################
##################################################
  match 'update_material/:material_id' => 'materials#update_material', :as => :update_material , :method => :post 
  match 'delete_material' => 'materials#delete_material', :as => :delete_material , :method => :post



##################################################
##################################################
######### CUSTOMER
##################################################
##################################################
  match 'update_customer/:customer_id' => 'customers#update_customer', :as => :update_customer , :method => :post 
  match 'delete_customer' => 'customers#delete_customer', :as => :delete_customer , :method => :post


##################################################
##################################################
######### CASH_ACCOUNT
##################################################
##################################################
  match 'update_cash_account/:cash_account_id' => 'cash_accounts#update_cash_account', :as => :update_cash_account , :method => :post 
  match 'delete_cash_account' => 'cash_accounts#delete_cash_account', :as => :delete_cash_account , :method => :post


##################################################
##################################################
######### USER 
##################################################
##################################################
  match 'update_user/:user_id' => 'users#update_user', :as => :update_user , :method => :post 
  match 'delete_user' => 'users#delete_user', :as => :delete_user , :method => :post
  
##################################################
##################################################
######### APP_USER 
##################################################
##################################################
  match 'update_app_user/:user_id' => 'app_users#update_app_user', :as => :update_app_user , :method => :post 
  match 'delete_app_user' => 'app_users#delete_app_user', :as => :delete_app_user , :method => :post

=begin
  SETTING
=end
  match 'edit_credential' => "passwords#edit_credential" , :as => :edit_credential
  match 'update_password' => "passwords#update" , :as => :update_password, :method => :put

##################################################
##################################################
######### SALES_ORDER
##################################################
##################################################
  match 'update_sales_order/:sales_order_id' => 'sales_orders#update_sales_order', :as => :update_sales_order , :method => :post 
  match 'delete_sales_order' => 'sales_orders#delete_sales_order', :as => :delete_sales_order , :method => :post
  match 'confirm_sales_order/:sales_order_id' => "sales_orders#confirm_sales_order", :as => :confirm_sales_order, :method => :post 

  match 'print_sales_order/:sales_order_id' => 'sales_orders#print_sales_order' , :as => :print_sales_order
  match 'sales_order_details' => 'sales_orders#details' , :as => :sales_order_details
  match 'sales_orders/generate_details' => 'sales_orders#generate_details', :as => :generate_sales_order_details

##################################################
##################################################
######### SALES_ITEM
##################################################
##################################################
  match 'update_sales_item/:sales_item_id' => 'sales_items#update_sales_item', :as => :update_sales_item , :method => :post 
  match 'delete_sales_item' => 'sales_items#delete_sales_item', :as => :delete_sales_item , :method => :post


# derivative sales item 
  match 'sales_order/:sales_order_id/derivative_sales_item' => 'sales_items#new_derivative', :as => :new_sales_order_derivative_sales_item
  match 'sales_order/:sales_order_id/create_derivative_sales_item' => 'sales_items#create_derivative', :as => :create_sales_order_derivative_sales_item, :method => :post 
  match 'sales_order/:sales_order_id/edit_derivative_sales_item/:id' => 'sales_items#edit_derivative', :as => :edit_sales_order_derivative_sales_item
  match 'sales_order/:sales_order_id/update_derivative_sales_item/:id' => 'sales_items#update_derivative', :as => :update_derivative_sales_item, :method => :post 

##################################################
##################################################
######### PRE_PRODUCTION_HISTORY
##################################################
##################################################
  match 'update_pre_production_history/:pre_production_history_id' => 'pre_production_histories#update_pre_production_history', :as => :update_pre_production_history , :method => :post 
  match 'delete_pre_production_history' => 'pre_production_histories#delete_pre_production_history', :as => :delete_pre_production_history, :method => :post
  match 'confirm_pre_production_history/:pre_production_history_id' => "pre_production_histories#confirm_pre_production_history", :as => :confirm_pre_production_history, :method => :post 

  match 'generate_pre_production_history' => 'pre_production_histories#generate_pre_production_history', :as => :generate_pre_production_history, :method => :post 
  
 
##################################################
##################################################
######### PRE_PRODUCTION_REPAIR_RESULT
##################################################
##################################################
  match 'update_pre_production_result/:pre_production_result_id' => 'pre_production_results#update_pre_production_result', :as => :update_pre_production_result , :method => :post 
  match 'delete_pre_production_result' => 'pre_production_results#delete_pre_production_result', :as => :delete_pre_production_result, :method => :post
  match 'confirm_pre_production_result/:pre_production_result_id' => "pre_production_results#confirm_pre_production_result", :as => :confirm_pre_production_result, :method => :post 

  match 'generate_pre_production_result' => 'pre_production_results#generate_result', :as => :generate_pre_production_result, :method => :post



##################################################
##################################################
######### PRODUCTION_HISTORY
##################################################
##################################################
  match 'update_production_history/:production_history_id' => 'production_histories#update_production_history', :as => :update_production_history , :method => :post 
  match 'delete_production_history' => 'production_histories#delete_production_history', :as => :delete_production_history, :method => :post
  match 'confirm_production_history/:production_history_id' => "production_histories#confirm_production_history", :as => :confirm_production_history, :method => :post 

  match 'generate_production_history' => 'production_histories#generate_production_history', :as => :generate_production_history, :method => :post

##################################################
##################################################
######### PRODUCTION_RESULT
##################################################
##################################################
  match 'update_production_result/:production_result_id' => 'production_results#update_production_result', :as => :update_production_result , :method => :post 
  match 'delete_production_result' => 'production_results#delete_production_result', :as => :delete_production_result, :method => :post
  match 'confirm_production_result/:production_result_id' => "production_results#confirm_production_result", :as => :confirm_production_result, :method => :post 

  match 'generate_production_result' => 'production_results#generate_result', :as => :generate_production_result, :method => :post


##################################################
##################################################
######### PRODUCTION_REPAIR_RESULT
##################################################
##################################################
  match 'update_production_repair_result/:production_repair_result_id' => 'production_repair_results#update_production_repair_result', :as => :update_production_repair_result , :method => :post 
  match 'delete_production_repair_result' => 'production_repair_results#delete_production_repair_result', :as => :delete_production_repair_result, :method => :post
  match 'confirm_production_repair_result/:production_repair_result_id' => "production_repair_results#confirm_production_repair_result", :as => :confirm_production_repair_result, :method => :post 

  match 'generate_production_repair_result' => 'production_repair_results#generate_result', :as => :generate_production_repair_result, :method => :post




##################################################
##################################################
######### POST_PRODUCTION_HISTORY
##################################################
##################################################
  match 'update_post_production_history/:post_production_history_id' => 'post_production_histories#update_post_production_history', :as => :update_post_production_history , :method => :post 
  match 'delete_post_production_history' => 'post_production_histories#delete_post_production_history', :as => :delete_post_production_history, :method => :post
  match 'confirm_post_production_history/:post_production_history_id' => "post_production_histories#confirm_post_production_history", :as => :confirm_post_production_history, :method => :post 

  match 'generate_post_production_history' => 'post_production_histories#generate_post_production_history', :as => :generate_post_production_history, :method => :post
  
##################################################
##################################################
######### POST_PRODUCTION_RESULT
##################################################
##################################################
  match 'update_post_production_result/:post_production_result_id' => 'post_production_results#update_post_production_result', :as => :update_post_production_result , :method => :post 
  match 'delete_post_production_result' => 'post_production_results#delete_post_production_result', :as => :delete_post_production_result, :method => :post
  match 'confirm_post_production_result/:post_production_result_id' => "post_production_results#confirm_post_production_result", :as => :confirm_post_production_result, :method => :post 

  match 'generate_post_production_result' => 'post_production_results#generate_result', :as => :generate_post_production_result, :method => :post

  
##################################################
##################################################
######### DELIVERY
##################################################
##################################################
  match 'update_delivery/:delivery_id' => 'deliveries#update_delivery', :as => :update_delivery , :method => :post 
  match 'delete_delivery' => 'deliveries#delete_delivery', :as => :delete_delivery , :method => :post
  match 'confirm_delivery/:delivery_id' => "deliveries#confirm_delivery", :as => :confirm_delivery, :method => :post
  match 'finalize_delivery/:delivery_id' => "deliveries#finalize_delivery", :as => :finalize_delivery, :method => :post
  
  match 'delivery_details' => 'deliveries#details' , :as => :delivery_details
  match 'deliveries/generate_details' => 'deliveries#generate_details', :as => :generate_delivery_details
  
  match 'print_delivery/:delivery_id' => 'deliveries#print_delivery' , :as => :print_delivery
##################################################
##################################################
######### DELIVERY_ENTRY
##################################################
##################################################
  match 'update_delivery_entry/:delivery_entry_id' => 'delivery_entries#update_delivery_entry', :as => :update_delivery_entry , :method => :post 
  match 'delete_delivery_entry' => 'delivery_entries#delete_delivery_entry', :as => :delete_delivery_entry , :method => :post
  match 'edit_post_delivery_delivery_entry/:delivery_entry_id'  => 'delivery_entries#edit_post_delivery_delivery_entry', :as => :edit_post_delivery_delivery_entry , :method => :get
  match 'update_post_delivery_delivery_entry/:delivery_entry_id'  => 'delivery_entries#update_post_delivery_delivery_entry', :as => :update_post_delivery_delivery_entry , :method => :post
  
  match 'new_special_delivery_entry/:delivery_id' => 'delivery_entries#new_special_delivery_entry', :as => :new_special_delivery_entry 
  match 'create_special_delivery_entry/:delivery_id' => 'delivery_entries#create_special_delivery_entry', :as => :create_special_delivery_entry, :method => :post  
  
  match 'edit_special_delivery_entry/:id' => 'delivery_entries#edit_special_delivery_entry', :as => :edit_special_delivery_entry 
  match 'update_special_delivery_entry/:delivery_entry_id' => 'delivery_entries#update_special_delivery_entry', :as => :update_special_delivery_entry , :method => :post  
  
  
##################################################
##################################################
######### Sales RETURN
##################################################
##################################################
  match 'confirm_sales_return/:sales_return_id' => "sales_returns#confirm_sales_return", :as => :confirm_sales_return, :method => :post
  
##################################################
##################################################
######### Sales RETURN Entry
##################################################
##################################################
  match 'update_sales_return_entry/:sales_return_entry_id' => 'sales_return_entries#update_sales_return_entry', :as => :update_sales_return_entry , :method => :post 
  


##################################################
##################################################
######### Guarantee Return
##################################################
##################################################
  match 'update_guarantee_return/:guarantee_return_id' => 'guarantee_returns#update_guarantee_return', :as => :update_guarantee_return , :method => :post 
  match 'delete_guarantee_return' => 'guarantee_returns#delete_guarantee_return', :as => :delete_guarantee_return , :method => :post
  match 'confirm_guarantee_return/:guarantee_return_id' => "guarantee_returns#confirm_guarantee_return", :as => :confirm_guarantee_return, :method => :post
  
  match 'guarantee_return_details' => 'guarantee_returns#details' , :as => :guarantee_return_details
  match 'guarantee_returns/generate_details' => 'guarantee_returns#generate_details', :as => :generate_guarantee_return_details
  
  
  # match 'finalize_delivery/:delivery_id' => "deliveries#finalize_delivery", :as => :finalize_delivery, :method => :post
  # 
  # 
  # match 'print_delivery/:delivery_id' => 'deliveries#print_delivery' , :as => :print_delivery
##################################################
##################################################
######### Guarantee Return Entry
##################################################
##################################################
  match 'update_guarantee_return_entry/:guarantee_return_entry_id' => 'guarantee_return_entries#update_guarantee_return_entry', :as => :update_guarantee_return_entry , :method => :post 
  match 'delete_guarantee_return_entry' => 'guarantee_return_entries#delete_guarantee_return_entry', :as => :delete_guarantee_return_entry , :method => :post
  # match 'edit_post_delivery_delivery_entry/:delivery_entry_id'  => 'delivery_entries#edit_post_delivery_delivery_entry', :as => :edit_post_delivery_delivery_entry , :method => :get
  # match 'update_post_delivery_delivery_entry/:delivery_entry_id'  => 'delivery_entries#update_post_delivery_delivery_entry', :as => :update_post_delivery_delivery_entry , :method => :post



##################################################
##################################################
######### Item Receival
##################################################
##################################################
  match 'update_item_receival/:item_receival_id' => 'item_receivals#update_item_receival', :as => :update_item_receival , :method => :post 
  match 'delete_item_receival' => 'item_receivals#delete_item_receival', :as => :delete_item_receival , :method => :post
  match 'confirm_item_receival/:item_receival_id' => "item_receivals#confirm_item_receival", :as => :confirm_item_receival, :method => :post
  
  
  match 'item_receival_details' => 'item_receivals#details' , :as => :item_receival_details
  match 'item_receivals/generate_details' => 'item_receivals#generate_details', :as => :generate_item_receival_details
##################################################
##################################################
######### Item Receival Entry
##################################################
##################################################
  match 'update_item_receival_entry/:item_receival_entry_id' => 'item_receival_entries#update_item_receival_entry', :as => :update_item_receival_entry , :method => :post 
  match 'delete_item_receival_entry' => 'item_receival_entries#delete_item_receival_entry', :as => :delete_item_receival_entry , :method => :post
  

##################################################
##################################################
######### Invoice
##################################################
##################################################
  match 'update_invoice/:invoice_id' => 'invoices#update_invoice', :as => :update_invoice , :method => :post 
  match 'confirm_invoice/:invoice_id' => "invoices#confirm_invoice", :as => :confirm_invoice, :method => :post

  match 'print_invoice/:invoice_id' => 'invoices#print_invoice' , :as => :print_invoice


##################################################
##################################################
######### PAYMENT
##################################################
##################################################
  match 'update_payment/:payment_id' => 'payments#update_payment', :as => :update_payment , :method => :post 
  match 'delete_payment' => 'payments#delete_payment', :as => :delete_payment , :method => :post
  match 'confirm_payment/:payment_id' => "payments#confirm_payment", :as => :confirm_payment, :method => :post
  match 'finalize_payment/:payment_id' => "payments#finalize_payment", :as => :finalize_payment, :method => :post

  match 'payment_details' => 'payments#details' , :as => :payment_details
  match 'payments/generate_details' => 'payments#generate_details', :as => :generate_payment_details

  match 'print_payment/:payment_id' => 'payments#print_payment' , :as => :print_payment
  
   
##################################################
##################################################
######### Invoice Payments
##################################################
##################################################
  match 'update_invoice_payment/:invoice_payment_id' => 'invoice_payments#update_invoice_payment', :as => :update_invoice_payment , :method => :post 
  match 'delete_invoice_payment' => 'invoice_payments#delete_invoice_payment', :as => :delete_invoice_payment , :method => :post

end
