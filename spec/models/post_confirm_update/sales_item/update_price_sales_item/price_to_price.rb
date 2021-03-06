=begin
  In price to price, we want to test for those confirmed payment. 
  
  if the final amout payable > initial amount payable => find the last payment. add the downpayment 
  
  if the final amount payable < initial amount payable 
    if the initial state == paid => change to unpaid 
    else
      do nothing
    end
  
=end

# steps: create all data + delivery + payment 

require 'spec_helper'

describe Payment do
  before(:each) do
    role = {
      :system => {
        :administrator => true
      }
    }

    Role.create!(
    :name        => ROLE_NAME[:admin],
    :title       => 'Administrator',
    :description => 'Role for administrator',
    :the_role    => role.to_json
    )
    @admin_role = Role.find_by_name ROLE_NAME[:admin]
    @admin =  User.create_main_user(   :email => "admin@gmail.com" ,:password => "willy1234", :password_confirmation => "willy1234") 
    
    @copper = Material.create :name => MATERIAL[:copper], :code => 'C'
    @customer = FactoryGirl.create(:customer,  :name => "Weyewe",
                                            :contact_person => "Willy" )  
                                            
    @bank_mandiri = CashAccount.create({
      :case =>  CASH_ACCOUNT_CASE[:bank][:value]  ,
      :name => "Bank mandiri 234325321",
      :description => "Spesial untuk non taxable payment"
    })   
                                           
    @sales_order   = SalesOrder.create_by_employee( @admin , {
      :customer_id    => @customer.id,          
      :payment_term   => PAYMENT_TERM[:cash],    
      :order_date     => Date.new(2012, 12, 15)   
    })
    
    @has_production_quantity = 50 
    @has_production_sales_item = SalesItem.create_sales_item( @admin, @sales_order,  {
      :material_id => @copper.id, 
      :vat_tax => '10',
      :is_pre_production => true , 
      :is_production     => true, 
      :is_post_production => true, 
      :is_delivered => true, 
      :delivery_address => "Perumahan Citra Garden 1 Blok AC2/3G",
      :quantity_for_production => @has_production_quantity, 
      :quantity_for_post_production => @has_production_quantity,
      :description => "Bla bla bla bla bla", 
      :delivery_address => "Yeaaah babyy", 
      :requested_deadline => Date.new(2013, 3,5 ),
      :weight_per_piece   => '15',
      :name => "Sales Item",
      :is_pending_pricing    => false, 
      :is_pricing_by_weight  => false , 
      :pre_production_price  => "100000", 
      :production_price      => "100000",
      :post_production_price => "100000"
    })
    @sales_order.confirm(@admin)
    @has_production_sales_item.reload
    @template_sales_item = @has_production_sales_item.template_sales_item 
    @initial_pending_production = @template_sales_item.pending_production
    
    @ok_production_quantity = 20
    @ok_quantity           = @ok_production_quantity
    @repairable_quantity   = 0
    @broken_quantity       = 0
    @ok_weight             = "#{@ok_quantity*10}"
    @repairable_weight     = '0'
    @broken_weight         = '0'
    @started_at            = DateTime.new(2012,12,11,23,1,1)
    @finished_at           = DateTime.new(2012,12,12,23,1,1)

    @pr = ProductionResult.create_result( @admin,  {
      :ok_quantity            => @ok_quantity          ,
      :repairable_quantity    => @repairable_quantity  ,
      :broken_quantity        => @broken_quantity      ,
      :ok_weight              => @ok_weight            ,
      :repairable_weight      => @repairable_weight    ,
      :broken_weight          => @broken_weight        ,
      :started_at             => @started_at           ,
      :finished_at            => @finished_at          ,
      :template_sales_item_id => @template_sales_item.id 
    } )
    @pr.confirm( @admin )
    @template_sales_item.reload 
    
    @ready_quantity       = @template_sales_item.ready_production 
    @ok_post_production_quantity=  10 
    @ok_quantity             =   @ok_post_production_quantity 
    @broken_quantity         =   0 
    @bad_source_quantity     =   0 
    @ok_weight               =   "#{@ok_quantity*10}" 
    @broken_weight           =   0 
    @bad_source_weight       =   0 
    @started_at              =   DateTime.new(2012,12,12,15,15 ,0 ) 
    @finished_at             =   DateTime.new(2012,12,18,15,15 ,0 ) 


    @initial_pending_post_production = @template_sales_item.pending_post_production 
    @ppr = PostProductionResult.create_result(@admin, {
      :ok_quantity         => @ok_quantity         ,
      :broken_quantity     => @broken_quantity     ,
      :bad_source_quantity => @bad_source_quantity ,
      :ok_weight           => @ok_weight           ,
      :broken_weight       => @broken_weight       ,
      :bad_source_weight   => @bad_source_weight   ,
      :started_at          => @started_at          ,
      :finished_at         => @finished_at        ,
      :template_sales_item_id => @template_sales_item.id 
    })
    
    @template_sales_item.reload
    
    @pending_post_production_pre_confirm = @template_sales_item.pending_post_production
    @ppr.confirm( @admin )
    @template_sales_item.reload
    
    @delivery   = Delivery.create_by_employee( @admin , {
      :customer_id    => @customer.id,          
      :delivery_address   => "some address",    
      :delivery_date     => Date.new(2012, 12, 15)
    })
  
   @template_sales_item = @has_production_sales_item.template_sales_item 
    @ready_post_production = @template_sales_item.ready_post_production 
    
    @quantity_sent = 1 
    # ready post production is 10
    if @ready_post_production > 5
      @quantity_sent = @ready_post_production - 5
    end
    
    @delivery_entry = DeliveryEntry.create_delivery_entry( @admin, @delivery,  {
        :quantity_sent => @quantity_sent, 
        :quantity_sent_weight => "#{@quantity_sent * 10}" ,
        :sales_item_id => @has_production_sales_item.id,
        :entry_case => DELIVERY_ENTRY_CASE[:normal], 
        :item_condition => DELIVERY_ENTRY_ITEM_CONDITION[:post_production]
      }) 
    
    @template_sales_item.reload 
    @initial_on_delivery = @template_sales_item.on_delivery 
    
    @delivery.confirm( @admin ) 
    @has_production_sales_item.reload 
    @delivery_entry.reload
    @template_sales_item.reload
    @quantity_confirmed =   @delivery_entry.quantity_sent 
    @delivery_entry.update_post_delivery(@admin, {
      :quantity_confirmed => @quantity_confirmed ,
      :quantity_confirmed_weight =>  "#{@quantity_confirmed*10 }",  
      :quantity_returned => 0 ,
      :quantity_returned_weight => '0' ,
      :quantity_lost => 0 
    }) 
    
    
    @has_production_sales_item.reload 
    @initial_on_delivery_item = @has_production_sales_item.on_delivery 
    @initial_fulfilled = @has_production_sales_item.fulfilled_post_production
    
    
    @delivery.reload 
    @delivery.finalize(@admin)
    @delivery.reload
    
    # @delivery.finalize(@admin)
    @delivery_entry.reload   
    @has_production_sales_item.reload 
    @template_sales_item.reload
    
    @guarantee_return = GuaranteeReturn.create_by_employee(@admin, {
      :customer_id => @customer.id ,
      :receival_date => Date.new( 2012,12,8)
    })
    
    # quantity_sent == 10 
    @gre_post_production = 3
    @gre_production = 1  
    @gre_production_repair = 0 
   
    
    @guarantee_return_entry = GuaranteeReturnEntry.create_guarantee_return_entry( @admin, @guarantee_return ,  {
      :sales_item_id                  => @has_production_sales_item.id ,
      :quantity_for_post_production   => @gre_post_production,
      :quantity_for_production        => @gre_production,
      :quantity_for_production_repair        => @gre_production_repair,
      :weight_for_post_production     => "#{@gre_post_production*10}", 
      :weight_for_production          => "#{@gre_production*10}",
      :weight_for_production_repair          => "#{@gre_production_repair*10}",
      :item_condition => GUARANTEE_RETURN_ENTRY_ITEM_CONDITION[:post_production]
    } )
    
    @has_production_sales_item.reload 
    @template_sales_item = @has_production_sales_item.template_sales_item 
    @initial_pending_production = @template_sales_item.pending_production 
    @initial_pending_post_production = @template_sales_item.pending_post_production 
    # @initial_number_of_guarantee_return = @template_sales_item.number_of_guarantee_return
    # @initial_pending_guarantee_return_delivery = @template_sales_item.pending_guarantee_return_delivery
    
    @guarantee_return.confirm(@admin)
    @has_production_sales_item.reload 
    @template_sales_item.reload
  end
  # 
  # context "no downpayment, invoice is fully paid" do
  #   before(:each) do
  #     @pending_payment =  @delivery.invoice.confirmed_pending_payment
  #     @total_sum = ( @pending_payment ).to_s
  #     @payment = Payment.create_by_employee(@admin, {
  #       :payment_method => PAYMENT_METHOD[:bank_transfer],
  #       :customer_id    => @customer.id , 
  #       :note           => "Dibayarkan dengan nomor transaksi AC/2323flkajfeaij",
  #       :amount_paid => @total_sum,
  #       :cash_account_id => @bank_mandiri.id,
  #       :downpayment_addition_amount => "0",
  #       :downpayment_usage_amount => "0" 
  #     })
  #     
  #     @invoice_payment = InvoicePayment.create_invoice_payment( @admin, @payment,  {
  #       :invoice_id  => @delivery.invoice.id , 
  #       :amount_paid => @total_sum
  #     } ) 
  # 
  #     @invoice_payment.should be_valid 
  #     @customer = @payment.customer 
  #     @initial_outstanding_payment = @customer.outstanding_payment
  #     @payment.confirm( @admin)
  #     @customer.reload
  #     @delivery.reload
  #     @invoice = @delivery.invoice 
  #     @payment.reload 
  #   end
  #   
  #   it 'should create payment. amount_paid == @amount_payable' do
  #     @payment.is_confirmed.should be_true 
  #     @invoice.confirmed_amount_paid.should == @invoice.amount_payable 
  #     @invoice.is_paid.should be_true 
  #     
  #     @payment.downpayment_histories.count.should == 0 
  #   end
  #   
  #   context "[post update] final amount payable > the initial amount " do
  #     before(:each) do
  #       @customer.reload
  #       @invoice.reload
  #       @initial_outstanding_payment = @customer.outstanding_payment
  #       @initial_invoice_amount_payable = @invoice.amount_payable
  #       @has_production_sales_item.post_confirm_update( @admin,  {
  #         :material_id => @copper.id, 
  #         :is_pre_production => true , 
  #         :is_production     => true, 
  #         :is_post_production => true, 
  #         :is_delivered => true, 
  #         :delivery_address => "Perumahan Citra Garden 1 Blok AC2/3G",
  #         :quantity_for_production => @has_production_quantity, 
  #         :quantity_for_post_production => @has_production_quantity,
  #         :description => "Bla bla bla bla bla", 
  #         :delivery_address => "Yeaaah babyy", 
  #         :requested_deadline => Date.new(2013, 3,5 ),
  #         :weight_per_piece   => '15',
  #         :name => "Sales Item",
  #         :is_pending_pricing    => false, 
  #         :is_pricing_by_weight  => false , 
  #         :pre_production_price  => "100000", 
  #         :production_price      => "200000",
  #         :post_production_price => "100000"
  #       })
  #       @invoice.reload
  #       @customer.reload 
  #     end
  #     
  #     it 'should not produce any errors post confirm update' do
  #       @has_production_sales_item.errors.size.should == 0 
  #     end
  #     
  #     it 'should turn is_paid status to be false payment amount' do
  #       @invoice.is_paid.should be_false 
  #     end
  # 
  #     it 'should increase the outstanding payment' do
  #       @final_outstanding_payment = @customer.outstanding_payment
  #       diff = @final_outstanding_payment - @initial_outstanding_payment
  # 
  #       @final_invoice_amount_payable = @invoice.amount_payable
  #       amount_payable_diff = @final_invoice_amount_payable - @initial_invoice_amount_payable
  #       diff.should == amount_payable_diff
  #     end
  #   end
  #    
  #   context "[post update] final amount ==  the initial  "
  #   
  #   context "[post update] final amount payable<  the initial amount payable => excess $ ..create/add downpayment history " do
  #     before(:each) do
  #       
  #       @initial_production_price = @has_production_sales_item.production_price
  #       @final_production_price = @initial_production_price/2 
  #       
  #       @customer.reload
  #       @invoice.reload 
  #       @initial_outstanding_payment = @customer.outstanding_payment
  #       @initial_remaining_downpayment = @customer.remaining_downpayment 
  #       @initial_amount_payable = @invoice.amount_payable
  #        
  #       
  #       @has_production_sales_item.post_confirm_update( @admin,  {
  #         :material_id => @copper.id, 
  #         :is_pre_production => true , 
  #         :is_production     => true, 
  #         :is_post_production => true, 
  #         :is_delivered => true, 
  #         :delivery_address => "Perumahan Citra Garden 1 Blok AC2/3G",
  #         :quantity_for_production => @has_production_quantity, 
  #         :quantity_for_post_production => @has_production_quantity,
  #         :description => "Bla bla bla bla bla", 
  #         :delivery_address => "Yeaaah babyy", 
  #         :requested_deadline => Date.new(2013, 3,5 ),
  #         :weight_per_piece   => '15',
  #         :name => "Sales Item",
  #         :is_pending_pricing    => false, 
  #         :is_pricing_by_weight  => false , 
  #         :pre_production_price  => "100000", 
  #         :production_price      => '50000',
  #         :post_production_price => "100000"
  #       })
  #       
  #       @invoice.reload 
  #       @payment.reload 
  #       @delivery_entry.reload 
  #       @customer.reload 
  #       @invoice.reload 
  #     end
  #     
  #     it 'should not produce any errors' do
  #       @has_production_sales_item.errors.size.should == 0 
  #     end
  #     # sanity check
  #     
  #     it 'should produce the correct amount of total_delivery_entry_price' do
  #       total_price = @has_production_sales_item.pre_production_price +
  #                     @has_production_sales_item.production_price + 
  #                       @has_production_sales_item.post_production_price
  #             
  #       quantity_confirmed = @delivery_entry.quantity_confirmed
  #       calculated_price = total_price*quantity_confirmed
  # 
  #       actual_price = @delivery_entry.total_delivery_entry_price
  #       actual_price.should == calculated_price
  #     end
  #     
  #     it 'should keep the status of invoice as is_paid = true ' do
  #       @invoice.is_paid.should be_true 
  #     end
  #     
  #     it 'should create a downpayment_history, of addition' do
  #       @payment.addition_downpayment.should be_valid
  #     end
  #     
  #     it 'should add amount_for_downpayment_addition in payment' do
  #       @addition_downpayment_amount = @payment.addition_downpayment.amount 
  #       @payment.downpayment_addition_amount.should == @addition_downpayment_amount
  #     end
  #     
  #     it 'should update increase downpayment' do 
  #       @final_remaining_downpayment = @customer.remaining_downpayment
  #       diff = @final_remaining_downpayment - @initial_remaining_downpayment
  #       @final_amount_payable = @invoice.amount_payable
  #       diff_actual = @initial_amount_payable - @final_amount_payable
  #       diff.should == diff_actual 
  #     end
  #     
  #     it 'should produce downpayment addition amount equal to the amount_payable diff' do
  #       @final_amount_payable = @invoice.amount_payable
  #       diff_amount_payable = @initial_amount_payable - @final_amount_payable
  #       @payment.downpayment_addition_amount.should == diff_amount_payable
  #     end
  #     
  #     it 'should keep the customer outstanding payment to be constant ' do
  #       @final_outstanding_payment = @customer.outstanding_payment
  #      diff = @final_outstanding_payment  - @initial_outstanding_payment
  #      
  #         
  #      diff.should == BigDecimal('0')
  #     end
  #   end
  # end
  
    # 
    # context "no downpayment, invoice is not fully paid"  do
    #   before(:each) do
    #     # quantity_confirmed: 5 
    #     # price per service: 100,000 + 100,000 + 100,000
    #     # 5 * 300,000 = 1,500,000 
    #     
    #     # amount_payable with tax: 1,500,000 + 150,000 = 1,650 000 
    #     @pending_payment =  @delivery.invoice.confirmed_pending_payment
    #     @diff = BigDecimal('500000')
    #     @amount_paid = BigDecimal("1100000")
    #     @diff = @pending_payment - @amount_paid
    #     @total_sum = ( @amount_paid).to_s
    #     @payment = Payment.create_by_employee(@admin, {
    #       :payment_method => PAYMENT_METHOD[:bank_transfer],
    #       :customer_id    => @customer.id , 
    #       :note           => "Dibayarkan dengan nomor transaksi AC/2323flkajfeaij",
    #       :amount_paid => @total_sum,
    #       :cash_account_id => @bank_mandiri.id,
    #       :downpayment_addition_amount => "0",
    #       :downpayment_usage_amount => "0" 
    #     })
    #     
    #     @invoice_payment = InvoicePayment.create_invoice_payment( @admin, @payment,  {
    #       :invoice_id  => @delivery.invoice.id , 
    #       :amount_paid => @total_sum
    #     } ) 
    # 
    #     @invoice_payment.should be_valid 
    #     @customer = @payment.customer 
    #     @initial_outstanding_payment = @customer.outstanding_payment
    #     @payment.confirm( @admin)
    #     @customer.reload
    #     @delivery.reload
    #     @invoice = @delivery.invoice 
    #     @payment.reload
    #   end
    #   
    #   
    #   it 'should create payment and confirmed it' do
    #     @payment.should be_valid
    #     @payment.is_confirmed.should be_true 
    #     
    #     puts "number of quantity_confirmed: #{@delivery_entry.quantity_confirmed}"
    #   end
    #   
    #   context "[post update] final amount_payable > the initial amount_payable " do
    #     before(:each) do
    #       @invoice.reload 
    #       @customer.reload
    #       @initial_outstanding_payment = @customer.outstanding_payment
    #       @initial_amount_payable = @invoice.amount_payable 
    #       @has_production_sales_item.post_confirm_update( @admin,  {
    #         :material_id => @copper.id, 
    #         :is_pre_production => true , 
    #         :is_production     => true, 
    #         :is_post_production => true, 
    #         :is_delivered => true, 
    #         :delivery_address => "Perumahan Citra Garden 1 Blok AC2/3G",
    #         :quantity_for_production => @has_production_quantity, 
    #         :quantity_for_post_production => @has_production_quantity,
    #         :description => "Bla bla bla bla bla", 
    #         :delivery_address => "Yeaaah babyy", 
    #         :requested_deadline => Date.new(2013, 3,5 ),
    #         :weight_per_piece   => '15',
    #         :name => "Sales Item",
    #         :is_pending_pricing    => false, 
    #         :is_pricing_by_weight  => false , 
    #         :pre_production_price  => "100000", 
    #         :production_price      => "200000",
    #         :post_production_price => "100000"
    #       })
    #       @customer.reload 
    #       @payment.reload 
    #       @invoice.reload 
    #     end
    #     
    #     it 'will just increase the outstanding payment'  do
    #       @final_outstanding_payment = @customer.outstanding_payment
    #       outstanding_payment_diff = @final_outstanding_payment - @initial_outstanding_payment
    #       
    #       @final_amount_payable = @invoice.amount_payable 
    #       amount_payable_diff = @final_amount_payable - @initial_amount_payable
    #       outstanding_payment_diff.should == amount_payable_diff
    #     end
    #     
    #     it 'wont create downpayment' do
    #       @payment.downpayment_histories.count.should == 0 
    #     end
    #   end
    #   
    #   
    #   context "[post update] final amount_payable == amount paid "  do
    #     before(:each) do
    #       @invoice.reload 
    #       @customer.reload
    #       @initial_outstanding_payment = @customer.outstanding_payment
    #       @initial_amount_payable = @invoice.amount_payable 
    #       @has_production_sales_item.post_confirm_update( @admin,  {
    #         :material_id => @copper.id, 
    #         :is_pre_production => true , 
    #         :is_production     => true, 
    #         :is_post_production => true, 
    #         :is_delivered => true, 
    #         :delivery_address => "Perumahan Citra Garden 1 Blok AC2/3G",
    #         :quantity_for_production => @has_production_quantity, 
    #         :quantity_for_post_production => @has_production_quantity,
    #         :description => "Bla bla bla bla bla", 
    #         :delivery_address => "Yeaaah babyy", 
    #         :requested_deadline => Date.new(2013, 3,5 ),
    #         :weight_per_piece   => '15',
    #         :name => "Sales Item",
    #         :is_pending_pricing    => false, 
    #         :is_pricing_by_weight  => false , 
    #         :pre_production_price  => "100000", 
    #         :production_price      => "0",  # we will get the condition amount_payable == amount_paid 
    #         :post_production_price => "100000"
    #       })
    #       @customer.reload 
    #       @payment.reload 
    #       @invoice.reload 
    #     end
    #     
    #     
    #     
    #     it 'will set the invoice status to be paid'  do 
    #       @invoice.is_paid.should be_true 
    #     end
    #     
    #     it 'will decrease the outstanding payment' do
    #       @final_outstanding_payment = @customer.outstanding_payment
    #       outstanding_payment_diff = @final_outstanding_payment - @initial_outstanding_payment
    #       
    #       @final_amount_payable = @invoice.amount_payable 
    #       amount_payable_diff = @final_amount_payable - @initial_amount_payable
    #       outstanding_payment_diff.should == amount_payable_diff
    #     end
    #     
    #     it 'should not create downpayment history' do
    #       @payment.downpayment_histories.count.should ==0  
    #     end
    #   end
    #   
    #   context "[post update] final amount_payable <  the initial amount_payable && final amount_payable < amount_paid"   do
    #     before(:each) do
    #       
    #       @invoice.reload 
    #       @customer.reload
    #       @initial_outstanding_payment = @customer.outstanding_payment
    #       @initial_amount_payable = @invoice.amount_payable 
    #       @initial_remaining_downpayment = @customer.remaining_downpayment
    #       @has_production_sales_item.post_confirm_update( @admin,  {
    #         :material_id => @copper.id, 
    #         :is_pre_production => true , 
    #         :is_production     => true, 
    #         :is_post_production => true, 
    #         :is_delivered => true, 
    #         :delivery_address => "Perumahan Citra Garden 1 Blok AC2/3G",
    #         :quantity_for_production => @has_production_quantity, 
    #         :quantity_for_post_production => @has_production_quantity,
    #         :description => "Bla bla bla bla bla", 
    #         :delivery_address => "Yeaaah babyy", 
    #         :requested_deadline => Date.new(2013, 3,5 ),
    #         :weight_per_piece   => '15',
    #         :name => "Sales Item",
    #         :is_pending_pricing    => false, 
    #         :is_pricing_by_weight  => false , 
    #         :pre_production_price  => "50000", 
    #         :production_price      => "50000",
    #         :post_production_price => "10000"
    #       })
    #       @customer.reload 
    #       @payment.reload 
    #       @invoice.reload
    #       
    #     end
    #     
    #     it 'should create an addition downpayment_history' do
    #       @payment.addition_downpayment.should be_valid 
    #     end
    #     
    #     it 'should set the invoice to be paid' do
    #       @invoice.is_paid.should be_true 
    #     end
    #     
    #     it 'should decrease the outstanding payment'  do
    #       @final_outstanding_payment = @customer.outstanding_payment
    #       # outstanding_payment_diff = @initial_outstanding_payment  - @final_outstanding_payment 
    #       
    #       @final_outstanding_payment.should == BigDecimal('0')
    #      
    #       
    #       # outstanding_payment_diff.should == BigDecimal("0")
    #     end
    #     
    #     
    #     it 'should increase the remaining downpayment' do 
    #       @final_remaining_downpayment = @customer.remaining_downpayment
    #       diff_remaining_downpayment = @final_remaining_downpayment - @initial_remaining_downpayment
    #       
    #       extra_for_downpayment = @payment.amount_paid  - @invoice.amount_payable 
    #       diff_remaining_downpayment.should == extra_for_downpayment
    #     end
    #   end
    # end
    # 
    
    
  context "with downpayment, invoice is fully paid"  do
    before(:each) do
      
    end
    context "[post update] final amount_payable > the initial amount_payable "
    context "[post update] final amount_payable ==  the initial amount_payable "
    context "[post update] final amount_payable <  the initial amount_payable "
  end
  
  context "with downpayment, invoice is not fully paid" do
    context "[post update] final amount_payable > the initial amount_payable "
    context "[post update] final amount_payable ==  the initial amount_payable "
    context "[post update] final amount_payable <  the initial amount_payable "
  end
  
  
  
    
end
