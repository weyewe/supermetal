require 'spec_helper'

describe SalesReturnEntry do
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
    
    @copper = Material.create :name => MATERIAL[:copper]
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
      :is_pre_production => true , 
      :is_production     => true, 
      :is_post_production => true, 
      :is_delivered => true, 
      :delivery_address => "Perumahan Citra Garden 1 Blok AC2/3G",
      :quantity => @has_production_quantity,
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
    # create delivery 
    @delivery   = Delivery.create_by_employee( @admin , {
      :customer_id    => @customer.id,          
      :delivery_address   => "some address",    
      :delivery_date     => Date.new(2012, 12, 15)
    })
    
    @template_sales_item = @has_production_sales_item.template_sales_item 
    @ready_post_production = @template_sales_item.ready_post_production 
    
    @quantity_sent = 1 
    if @ready_post_production > 1 
      @quantity_sent = @ready_post_production - 1 
    end
    
    @delivery_entry = DeliveryEntry.create_delivery_entry( @admin, @delivery,  {
        :quantity_sent => @quantity_sent, 
        :quantity_sent_weight => "#{@quantity_sent * 10}" ,
        :sales_item_id => @has_production_sales_item.id,
        :entry_case => DELIVERY_ENTRY_CASE[:normal], 
        :item_condition => DELIVERY_ENTRY_ITEM_CONDITION[:post_production]
      })
      
    @delivery.confirm( @admin ) 
    @has_production_sales_item.reload 
    @delivery_entry.reload
    @template_sales_item.reload
  end
  
  context 'no returned sales item' do
    before(:each) do 
      # create finalization
      @quantity_returned = 0  
      @quantity_confirmed =   @delivery_entry.quantity_sent - @quantity_returned

      # puts "quantity_confirmed: #{@quantity_confirmed}"
      # puts "quantity_returned: #{@quantity_returned}"

      @delivery_entry.update_post_delivery(@admin, {
        :quantity_confirmed => @quantity_confirmed , 
        :quantity_confirmed_weight =>  "#{@quantity_confirmed*10 }", 
        :quantity_returned => @quantity_returned ,
        :quantity_returned_weight => "#{@quantity_returned*20}" ,
        :quantity_lost => 0 
      }) 


      @has_production_sales_item.reload 
      @initial_on_delivery_item = @has_production_sales_item.on_delivery 
      @initial_fulfilled = @has_production_sales_item.fulfilled_order


      @delivery.reload 
      @delivery.finalize(@admin)
      @delivery.reload

      # @delivery.finalize(@admin)  
      @has_production_sales_item.reload

      @sales_return = @delivery.sales_return 
      # @sales_return_entry = @sales_return.sales_return_entries.first
    end
    
    it 'should have no sales return ' do
      @sales_return.should be_nil 
    end
    
    it 'should be finalized' do
      @delivery.is_finalized.should be_true 
    end
  end
  
  context 'has returned sales item' do
    before(:each) do 
      # create finalization
      @quantity_returned = 5 
      @quantity_confirmed =   @delivery_entry.quantity_sent - @quantity_returned
  
      # puts "quantity_confirmed: #{@quantity_confirmed}"
      # puts "quantity_returned: #{@quantity_returned}"
  
      @delivery_entry.update_post_delivery(@admin, {
        :quantity_confirmed => @quantity_confirmed , 
        :quantity_confirmed_weight =>  "#{@quantity_confirmed*10 }", 
        :quantity_returned => @quantity_returned ,
        :quantity_returned_weight => "#{@quantity_returned*20}" ,
        :quantity_lost => 0 
      }) 
  
  
      @has_production_sales_item.reload 
      @initial_on_delivery_item = @has_production_sales_item.on_delivery 
      @initial_fulfilled = @has_production_sales_item.fulfilled_order
  
  
      @delivery.reload 
      @delivery.finalize(@admin)
      @delivery.reload
  
      # @delivery.finalize(@admin)  
      @has_production_sales_item.reload
  
      @sales_return = @delivery.sales_return 
      @sales_return_entry = @sales_return.sales_return_entries.first
    end
    
    it 'should have one sales return entry' do
      @sales_return.sales_return_entries.count.should == 1 
      @sales_return_entry.should be_valid 
    end
    
    it 'should  be allowed to be confirmed if total_sum of production + post_production  == quantity_returned' do
      sales_return_repair_post_production_quantity = 1
      sales_return_production_repair_quantity = 1  
      sales_return_production_quantity =  @quantity_returned - sales_return_repair_post_production_quantity
      @sales_return_entry.update_return_handling( {
        :quantity_for_production => sales_return_production_quantity, 
        :weight_for_production => "#{sales_return_production_quantity*7}",
        :quantity_for_production_repair => sales_return_production_repair_quantity, 
        :weight_for_production_repair => "#{sales_return_production_repair_quantity*7}",
        
        :quantity_for_post_production => sales_return_repair_post_production_quantity,
        :weight_for_post_production => "#{sales_return_repair_post_production_quantity*7}"
      })
      
      @sales_return_entry.validate_return_handling 
      @sales_return_entry.errors.size.should == 0 
    end
    
    it 'should not allow negative value' do
      sales_return_repair_post_production_quantity = -1 
      sales_return_production_quantity =  4  #@quantity_returned - sales_return_repair_post_production_quantity
      sales_return_production_repair_quantity =1
      @sales_return_entry.update_return_handling( {
        :quantity_for_production => sales_return_production_quantity, 
        :weight_for_production => "#{sales_return_production_quantity*7}",
        
        :quantity_for_production_repair => sales_return_production_repair_quantity, 
        :weight_for_production_repair => "#{sales_return_production_repair_quantity*7}",
        
        :quantity_for_post_production => sales_return_repair_post_production_quantity,
        :weight_for_post_production => "#{1*7}"
      })
      
      @sales_return_entry.validate_return_handling 
      @sales_return_entry.errors.size.should_not == 0
    end
    
    it 'should not allow production + post production != quantity_returned' do
      sales_return_repair_post_production_quantity = 1
      sales_return_production_repair_quantity = 1 
      extra_for_error  = 1 
      sales_return_production_quantity =  @quantity_returned - 
                                          sales_return_repair_post_production_quantity + 
                                          sales_return_production_repair_quantity + 
                                          extra_for_error
                                          
      @sales_return_entry.update_return_handling( {
        :quantity_for_production => sales_return_production_quantity, 
        :weight_for_production => "#{sales_return_production_quantity*7}",
        
        :quantity_for_production_repair => sales_return_production_repair_quantity, 
        :weight_for_production_repair => "#{sales_return_production_repair_quantity*7}",
        
        :quantity_for_post_production => sales_return_repair_post_production_quantity,
        :weight_for_post_production => "#{sales_return_repair_post_production_quantity*7}"
      })
      
      @sales_return_entry.validate_return_handling 
      @sales_return_entry.errors.size.should_not == 0
    end
    
    context 'sales_return confirmation' do
      before(:each) do
        @has_production_sales_item.reload 
        @initial_pending_production = @has_production_sales_item.pending_production
        @initial_pending_post_production = @has_production_sales_item.pending_post_production
       
        
        @sales_return_repair_post_production_quantity = 1 
        @sales_return_production_repair_quantity =  1 
        @sales_return_production_quantity =  @quantity_returned - 
                    @sales_return_repair_post_production_quantity - 
                    @sales_return_production_repair_quantity
        @sales_return_entry.update_return_handling( {
          :quantity_for_production => @sales_return_production_quantity, 
          :weight_for_production => "#{@sales_return_production_quantity*7}",
          
          :quantity_for_production_repair => @sales_return_production_repair_quantity, 
          :weight_for_production_repair => "#{@sales_return_production_repair_quantity*7}",
    
          :quantity_for_post_production => @sales_return_repair_post_production_quantity,
          :weight_for_post_production => "#{@sales_return_repair_post_production_quantity*7}"
        })
        
        
        
        @sales_return.confirm( @admin )
        @sales_return.reload
        @sales_return_entry.reload 
        @has_production_sales_item.reload 
        
        @template_sales_item.reload 
     
      end
      
      it 'should have  confirmed sales return' do 
        @sales_return.is_confirmed.should be_true  
      end
      
      it 'should have confirmed sales_return_entry' do
        puts "Total errors: #{@sales_return_entry.errors.size}"
        @sales_return_entry.errors.messages.each do |msg|
          puts "msg: #{msg}"
        end
        @sales_return_entry.is_confirmed.should be_true 
      end
      
      # it 'should have increased the pending production' do
      #   
      #   @final_pending_production = @has_production_sales_item.pending_production
      #  
      #   
      #   diff = @final_pending_production - @initial_pending_production
      #   
      #   diff.should == @sales_return_production_quantity
      # end
      # 
      # it 'should have increased the pending post production'  do
      #     
      #   
      #   @final_pending_post_production = @has_production_sales_item.pending_post_production
      #   diff =  @final_pending_post_production - @initial_pending_post_production
      #   
      #   diff.should == @sales_return_repair_post_production_quantity
      # end
    end
  end
  
  
end