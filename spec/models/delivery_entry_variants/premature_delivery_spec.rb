# it 'should consider sending premature item as delivery fulfilment: 
  # reduce post production and add fulfilled order'

# what if the premature delivery spec is lost? 
# => production order must increase and post production order must increase 
# => fulfilled == reduced

# what if the premature delivery spec is returned?
# => 1. for those going for production repair 
# => 2. for those going for production
# => 3. for those going for post production 
# => GENERAL POLICY on sales return of premature item (can only go for production or post production):
  # => 1.Production  ( remake ) 
  # => 2. Post Production ( fix it )  
  # NO PRODUCTION REPAIR (based on visual assestment, such thing is impossible)
  
# what will happen on such lost shite? remake it. 
# =>  on template_sales_item.pending_production => will be increased because of production order 
# => on sales_item.fulfilled_production => will be decreased ( contribution from the confirmation)
  

# it can't be selected for production only or post production only 
# it can't exceed the quantity of pending fulfilled order from the related sales item 
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
      # :quantity => @has_production_quantity,
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

    @quantity_sent = 5 
     

    
  end
  
  it 'should allow normal delivery + condition post production' do
    @delivery_entry = DeliveryEntry.create_delivery_entry( @admin, @delivery,  {
      :quantity_sent => @quantity_sent, 
      :quantity_sent_weight => "#{@quantity_sent * 10}" ,
      :sales_item_id => @has_production_sales_item.id,
      :entry_case => DELIVERY_ENTRY_CASE[:normal], 
      :item_condition => DELIVERY_ENTRY_ITEM_CONDITION[:post_production]
      })
    @delivery_entry.should be_valid 
  end
  
  it 'should not allow normal delivery + condition  production' do
    @delivery_entry = DeliveryEntry.create_delivery_entry( @admin, @delivery,  {
      :quantity_sent => @quantity_sent, 
      :quantity_sent_weight => "#{@quantity_sent * 10}" ,
      :sales_item_id => @has_production_sales_item.id,
      :entry_case => DELIVERY_ENTRY_CASE[:normal], 
      :item_condition => DELIVERY_ENTRY_ITEM_CONDITION[:production]
      })
    @delivery_entry.should_not be_valid
  end
  
  it 'should allow premature delivery' do
    @delivery_entry = DeliveryEntry.create_delivery_entry( @admin, @delivery,  {
      :quantity_sent => @quantity_sent, 
      :quantity_sent_weight => "#{@quantity_sent * 10}" ,
      :sales_item_id => @has_production_sales_item.id,
      :entry_case => DELIVERY_ENTRY_CASE[:premature], 
      :item_condition => DELIVERY_ENTRY_ITEM_CONDITION[:production]
      })
    @delivery_entry.should be_valid
  end
  
  context "post confirm premature delivery" do
    before(:each) do
      @delivery_entry = DeliveryEntry.create_delivery_entry( @admin, @delivery,  {
        :quantity_sent => @quantity_sent, 
        :quantity_sent_weight => "#{@quantity_sent * 10}" ,
        :sales_item_id => @has_production_sales_item.id,
        :entry_case => DELIVERY_ENTRY_CASE[:premature], 
        :item_condition => DELIVERY_ENTRY_ITEM_CONDITION[:production]
        })
      @has_production_sales_item.reload 
      @template_sales_item = @has_production_sales_item.template_sales_item
      @initial_ready_production = @template_sales_item.ready_production
      @initial_fulfilled_post_production = @has_production_sales_item.fulfilled_post_production 
      @delivery.confirm(@admin)
      @delivery.reload 
      @has_production_sales_item.reload 
      @template_sales_item.reload 
      @delivery_entry.reload 
    end
    
    
    it 'should confirm the delivery' do
      @delivery.is_confirmed.should be_true 
    end
    
    
    it 'should confirm the delivery entry' do
      @delivery_entry.is_confirmed.should be_true 
    end
    
    it 'should increase the  fulfilled_post_production' do 
      @final_fulfilled_post_production = @has_production_sales_item.fulfilled_post_production 
      diff = @final_fulfilled_post_production - @initial_fulfilled_post_production
      diff.should == @quantity_sent
    end
    
    it 'should decrease the template_sales_item.ready_production' do
      @final_ready_production = @template_sales_item.ready_production
      diff = @initial_ready_production - @final_ready_production
      diff.should == @quantity_sent 
    end
    
    context " finalize premature delivery: no sales return" do
      before(:each) do
        @has_production_sales_item.reload 
        @template_sales_item = @has_production_sales_item.template_sales_item
        @initial_ready_production = @template_sales_item.ready_production
        @initial_fulfilled_post_production = @has_production_sales_item.fulfilled_post_production 
        @delivery_entry.update_post_delivery(@admin, {
          :quantity_confirmed => @delivery_entry.quantity_sent , 
          :quantity_confirmed_weight =>  "#{@delivery_entry.quantity_sent*10 }", 
          :quantity_returned => 0 ,
          :quantity_returned_weight => '0' ,
          :quantity_lost => 0
        })
        @delivery.finalize(@admin)
        @delivery.reload 
        @has_production_sales_item.reload 
        @template_sales_item.reload 
        @delivery_entry.reload
      end
      
      it 'should not update the template_sales_item.ready_production' do
        @final_ready_production = @template_sales_item.ready_production
        diff = @final_ready_production - @initial_ready_production
        diff.should == 0
      end
      
      it 'should be finalized ' do
        puts "The errors in delivery: #{@delivery.errors.size}"
        puts "The errors in delivery_entry: #{@delivery_entry.errors.size}"
        @delivery.is_finalized.should be_true 
        @delivery_entry.is_finalized.should be_true 
      end
      
      it 'should not change the number of fulfilled post production' do
        @final_fulfilled_post_production = @has_production_sales_item.fulfilled_post_production 
        diff = @final_fulfilled_post_production - @initial_fulfilled_post_production
        diff.should == 0 
      end
    end # " finalize premature delivery: no sales return"
    
    context " finalize premature delivery:  with sales return " do
      before(:each) do
        @has_production_sales_item.reload 
        @template_sales_item = @has_production_sales_item.template_sales_item
        @initial_ready_production = @template_sales_item.ready_production
        @initial_fulfilled_post_production = @has_production_sales_item.fulfilled_post_production
        @quantity_returned = 1  
        @delivery_entry.update_post_delivery(@admin, {
          :quantity_confirmed => @delivery_entry.quantity_sent - @quantity_returned , 
          :quantity_confirmed_weight =>  "#{@delivery_entry.quantity_sent*10 }", 
          :quantity_returned => @quantity_returned ,
          :quantity_returned_weight => "#{@quantity_returned*10}" ,
          :quantity_lost => 0
        })
        
        @delivery.finalize(@admin)
        @delivery.reload 
        @has_production_sales_item.reload 
        @template_sales_item.reload 
        @delivery_entry.reload
      end
      
      it 'should not update the template_sales_item.ready_production' do
        @final_ready_production = @template_sales_item.ready_production
        diff = @final_ready_production - @initial_ready_production
        diff.should == 0
      end
      
      it 'should be finalized ' do
        puts "The errors in delivery: #{@delivery.errors.size}"
        puts "The errors in delivery_entry: #{@delivery_entry.errors.size}"
        @delivery.is_finalized.should be_true 
        @delivery_entry.is_finalized.should be_true 
      end
      
      # before confirming the sales return (hence, no production/production_repair) order
      # it will increase. 
      it 'should  change the number of fulfilled post production' do
        @final_fulfilled_post_production = @has_production_sales_item.fulfilled_post_production 
        diff = @initial_fulfilled_post_production  - @final_fulfilled_post_production
        diff.should == @quantity_returned
      end
      
      it 'should produce sales_return  and sales_return entry' do
        @delivery.sales_return.should be_valid 
        @delivery_entry.sales_return_entry.should be_valid 
      end
    end # " finalize premature delivery: with sales return"
    
    context " finalize premature delivery:  with sales lost " do
      before(:each) do
        @has_production_sales_item.reload 
        @template_sales_item = @has_production_sales_item.template_sales_item
        @initial_ready_production = @template_sales_item.ready_production
        @initial_fulfilled_post_production = @has_production_sales_item.fulfilled_post_production 
        @quantity_lost = 1  
        @quantity_returned = 0 
        @delivery_entry.update_post_delivery(@admin, {
          :quantity_confirmed => @delivery_entry.quantity_sent - @quantity_lost , 
          :quantity_confirmed_weight =>  "#{@delivery_entry.quantity_sent*10 }", 
          :quantity_returned => @quantity_returned ,
          :quantity_returned_weight => "#{@quantity_returned*10}" ,
          :quantity_lost => @quantity_lost
        })
        
        @initial_pending_production = @template_sales_item.pending_production 
        @delivery.finalize(@admin)
        @delivery.reload 
        @has_production_sales_item.reload 
        @template_sales_item.reload 
        @delivery_entry.reload
      end
      
      it 'should not update the template_sales_item.ready_production' do
        @final_ready_production = @template_sales_item.ready_production
        diff = @final_ready_production - @initial_ready_production
        diff.should == 0
      end
      
      it 'should be finalized ' do
        puts "The errors in delivery: #{@delivery.errors.size}"
        puts "The errors in delivery_entry: #{@delivery_entry.errors.size}"
        @delivery.is_finalized.should be_true 
        @delivery_entry.is_finalized.should be_true 
      end
      
      # before confirming the sales return (hence, no production/production_repair) order
      # it will increase. 
      it 'should  change the number of fulfilled post production' do
        @final_fulfilled_post_production = @has_production_sales_item.fulfilled_post_production 
        diff = @initial_fulfilled_post_production  - @final_fulfilled_post_production
        diff.should == @quantity_lost 
      end
      
      it 'should produce sales_return  and sales_return entry' do
        @delivery.delivery_lost.should be_valid 
        @delivery_lost  = @delivery.delivery_lost 
        @delivery_lost.delivery_lost_entries.count.should == 1 
        @delivery_entry.delivery_lost_entry.should be_valid 
      end
      
      it 'should increase pending production' do
        @final_pending_production = @template_sales_item.pending_production 
        diff = @final_pending_production - @initial_pending_production
        diff.should == @quantity_lost 
      end
    end # " finalize premature delivery:  with sales lost "
    
    
  end # context "post confirm premature delivery"
  
  
end