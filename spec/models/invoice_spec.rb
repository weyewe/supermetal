require 'spec_helper'

describe GuaranteeReturn do
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
      :pre_production_price  => "50000", 
      :production_price      => "20000",
      :post_production_price => "150000"
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
  
  it 'should create invoice on delivery confirm' do
    @delivery.invoice.should be_valid  # the base first delivery 
  end
  
  
  it 'should not create invoice if the delivery entry is all non billable' do
    @quantity_sent = 1 
    @delivery   = Delivery.create_by_employee( @admin , {
      :customer_id    => @customer.id,          
      :delivery_address   => "some address",    
      :delivery_date     => Date.new(2012, 12, 15)
    })
    
    @delivery_entry = DeliveryEntry.create_delivery_entry( @admin, @delivery,  {
        :quantity_sent => @quantity_sent, 
        :quantity_sent_weight => "#{@quantity_sent * 10}" ,
        :sales_item_id => @has_production_sales_item.id,
        :entry_case => DELIVERY_ENTRY_CASE[:guarantee_return], 
        :item_condition => DELIVERY_ENTRY_ITEM_CONDITION[:post_production]
      })
      
    @delivery.confirm(@admin)
    @delivery.should be_valid 
    @delivery.invoice.should be_nil 
  end
  
  context "normal delivery: send 1 item, only production" do
    before(:each) do
      @quantity_sent = 1 
      @delivery   = Delivery.create_by_employee( @admin , {
        :customer_id    => @customer.id,          
        :delivery_address   => "some address",    
        :delivery_date     => Date.new(2012, 12, 15)
      })

      @delivery_entry = DeliveryEntry.create_delivery_entry( @admin, @delivery,  {
          :quantity_sent => @quantity_sent, 
          :quantity_sent_weight => "#{@quantity_sent * 10}" ,
          :sales_item_id => @has_production_sales_item.id,
          :entry_case => DELIVERY_ENTRY_CASE[:normal], 
          :item_condition => DELIVERY_ENTRY_ITEM_CONDITION[:post_production]
        })
        
      @delivery.confirm(@admin)
      @delivery_entry.reload 
      @invoice = @delivery.invoice
    end
    
    it 'should produce amount to be paid based on the delivered goods' do
      puts "amount payable: #{@invoice.amount_payable.to_s}"
      puts "delivery_entry_price: #{@delivery_entry.total_delivery_entry_price}"
      base_payable = @delivery_entry.total_delivery_entry_price.to_f
      tax =  (0.1)*base_payable
      
      @invoice.amount_payable.should == BigDecimal( (base_payable + tax).to_s )
    end
  end
  
  
  it 'should create invoice if the delivery entry is mixed: invoicable and non invoicable' do
    @guarantee_return_quantity_sent = 1 
    @normal_post_production_quantity_sent = 1 
    @delivery   = Delivery.create_by_employee( @admin , {
      :customer_id    => @customer.id,          
      :delivery_address   => "some address",    
      :delivery_date     => Date.new(2012, 12, 15)
    })
    
    @delivery_entry = DeliveryEntry.create_delivery_entry( @admin, @delivery,  {
        :quantity_sent => @guarantee_return_quantity_sent, 
        :quantity_sent_weight => "#{@guarantee_return_quantity_sent * 10}" ,
        :sales_item_id => @has_production_sales_item.id,
        :entry_case => DELIVERY_ENTRY_CASE[:guarantee_return], 
        :item_condition => DELIVERY_ENTRY_ITEM_CONDITION[:post_production]
      })
      
    @delivery_entry = DeliveryEntry.create_delivery_entry( @admin, @delivery,  {
        :quantity_sent => @normal_post_production_quantity_sent, 
        :quantity_sent_weight => "#{@normal_post_production_quantity_sent * 10}" ,
        :sales_item_id => @has_production_sales_item.id,
        :entry_case => DELIVERY_ENTRY_CASE[:normal], 
        :item_condition => DELIVERY_ENTRY_ITEM_CONDITION[:post_production]
      })
      
    @delivery.confirm(@admin)
    @delivery.should be_valid 
    @delivery.invoice.should be_valid 
  end
  
  context "mixed delivery: invoicable and non invoicable " do
    before(:each) do
      @guarantee_return_quantity_sent = 1 
      @normal_post_production_quantity_sent = 1 
      @delivery   = Delivery.create_by_employee( @admin , {
        :customer_id    => @customer.id,          
        :delivery_address   => "some address",    
        :delivery_date     => Date.new(2012, 12, 15)
      })
  
      @delivery_entry_gr = DeliveryEntry.create_delivery_entry( @admin, @delivery,  {
          :quantity_sent => @guarantee_return_quantity_sent, 
          :quantity_sent_weight => "#{@guarantee_return_quantity_sent * 10}" ,
          :sales_item_id => @has_production_sales_item.id,
          :entry_case => DELIVERY_ENTRY_CASE[:guarantee_return], 
          :item_condition => DELIVERY_ENTRY_ITEM_CONDITION[:post_production]
        })
  
      @delivery_entry_normal = DeliveryEntry.create_delivery_entry( @admin, @delivery,  {
          :quantity_sent => @normal_post_production_quantity_sent, 
          :quantity_sent_weight => "#{@normal_post_production_quantity_sent * 10}" ,
          :sales_item_id => @has_production_sales_item.id,
          :entry_case => DELIVERY_ENTRY_CASE[:normal], 
          :item_condition => DELIVERY_ENTRY_ITEM_CONDITION[:post_production]
        })
  
      @delivery.confirm(@admin)
      @delivery_entry_gr.reload 
      @delivery_entry_normal.reload 
      
      @delivery.should be_valid 
      @delivery.invoice.should be_valid
      @invoice = @delivery.invoice
    end
    
    it 'should produce amount to be paid based on the delivered goods' do
      puts "amount payable: #{@invoice.amount_payable.to_s}"
      puts "delivery_entry_price: #{@delivery_entry.total_delivery_entry_price}"
      # @invoice.amount_payable.should == ( 1.1)*(  @delivery_entry_gr.total_delivery_entry_price +  @delivery_entry_normal.total_delivery_entry_price )
      
      base_payable = (@delivery_entry_gr.total_delivery_entry_price +  @delivery_entry_normal.total_delivery_entry_price ).to_f
      tax =  (0.1)*base_payable
      
      @invoice.amount_payable.should == BigDecimal( (base_payable + tax).to_s )
      
      @delivery_entry_gr.total_delivery_entry_price.should == BigDecimal('0')
    end
    
    
  end
  
  
  
  # non invoicable delivery should not be mixed with invoice-able delivery? 
  # so, if the non invoice is transformed to the invoice, can't make any delivery 
  
  # pay => free, no problem, just change the invoice value to 0 
  # free => pay => fucking big problem. The invoice number? 
  # case => ah, we sent the wrong shite. How? uppps.. just cancel the delivery
  # create new delivery. send it again, this time with the billing. no problemo.
  
  # case : partial bill, all billing 
  
=begin
  If in 1 invoice, there are several invoice entries
  
  Some of them are without price. Invoice will still be created. But the invoice can't be paid. 
  # pay to the downpayment. 
  # if a delivery entry is cancelled, the invoice will have less delivery entry billed. So? 
  # they must have the 2 versions (old version printed) and the new version attached to the old version
=end

=begin
  How about for those invoice with pricing, then changed to be no pricing? 
  Solution? 
  
  # can't change the is_pricing status if invoice has been created 
=end
  
    
end