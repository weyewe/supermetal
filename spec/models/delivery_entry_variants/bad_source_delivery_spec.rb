# IF THERE IS DELIVERY LOST, how would  you handle it? 
# TECHNICAL FAILURE OR DELIVERY LOST:  
# FOR BOTH of technical failure or bad source => no sales return allowed. must be confirmed. 
# what if it is lost? fuck.

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
    
    @only_post_production_sales_item_quantity = 50 
    @only_post_production_sales_item = SalesItem.create_sales_item( @admin, @sales_order,  {
      :material_id => @copper.id, 
      :vat_tax => '10',
      :is_pre_production => false , 
      :is_production     => false, 
      :is_post_production => true, 
      :is_delivered => true, 
      :delivery_address => "Perumahan Citra Garden 1 Blok AC2/3G",
      :quantity_for_production => 0 ,
      :quantity_for_post_production => @only_post_production_sales_item_quantity, 
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
    @only_post_production_sales_item.reload
    @template_sales_item = @only_post_production_sales_item.template_sales_item 
    
    @item_receival = ItemReceival.create_by_employee( @admin, {
      :customer_id => @customer.id 
    } ) 
    @received_quantity = 10 
    
    @item_receival_entry = ItemReceivalEntry.create_item_receival_entry( @admin, @item_receival,  {
      :quantity => @received_quantity, 
      :sales_item_id => @only_post_production_sales_item.id
    } )
  end
  # sanity check
  it 'should have item receival and item receival entry' do
    @item_receival.should be_valid 
    @item_receival_entry.should be_valid 
  end
  
  it 'should be internal production template sales item' do
    @template_sales_item.is_internal_production.should be_false 
  end
  
  it 'should create post production order' do
    @template_sales_item.pending_post_production_only_post_production.should == @only_post_production_sales_item_quantity
  end
  
  
  context "confirming item receival" do
    before(:each) do
      @initial_pending_item_receival_ready = @template_sales_item.item_receival_ready_for_post_production
      @item_receival.confirm(@admin)
      @item_receival.reload
      @item_receival_entry.reload 
      @only_post_production_sales_item.reload 
      @template_sales_item.reload 
    end
    
    it 'should confirm item receival'  do
      @item_receival.is_confirmed.should be_true 
      @item_receival_entry.is_confirmed.should be_true 
      @item_receival_entry.sales_item_id.should == @only_post_production_sales_item.id 
    end
    
    it 'should increase item receival ready for post production by : quantity = 10' do
      
      @final_pending_item_receival_ready = @template_sales_item.item_receival_ready_for_post_production
      diff = @final_pending_item_receival_ready - @initial_pending_item_receival_ready
      diff.should == @received_quantity
    end
    
    it 'should create post production order with type: sales_order_only_post_production' do
      PostProductionOrder.where(
        :template_sales_item_id => @template_sales_item.id ,
        :source_document_entry_id => @item_receival_entry.id, 
        :source_document_entry => @item_receival_entry.class.to_s
      ).count.should == 0 
    end
    
    context "do the post production work with broken quantity" do
      before(:each) do
        # @received_quantity  = 10
        @ok_quantity         =  5
        @broken_quantity     =  0 
        @bad_source_quantity =  1 
        @ok_weight           = "#{@ok_quantity*10}"
        @broken_weight       = "0"
        @bad_source_weight   = "#{@bad_source_quantity*10}"
        @started_at          = DateTime.new(2012,12,10,12,12,0)
        @finished_at         = DateTime.new(2012,12,15,12,12,0)

        @ppr = PostProductionResult.create_result(@admin, {
          :ok_quantity         => @ok_quantity         ,
          :broken_quantity     => @broken_quantity     ,
          :bad_source_quantity => @bad_source_quantity ,
          :ok_weight           => @ok_weight           ,
          :broken_weight       => @broken_weight       ,
          :bad_source_weight   => @bad_source_weight           ,
          :started_at          => @started_at                 ,
          :finished_at         => @finished_at               ,
          :template_sales_item_id => @template_sales_item.id 
        })
        
        @ppr.should be_valid 
        @template_sales_item.reload
        @initial_pending_post_production_only_post_production = @template_sales_item.pending_post_production_only_post_production
        @initial_item_receival_ready_for_post_production = @template_sales_item.item_receival_ready_for_post_production
        @initial_pending_delivery_bad_source = @template_sales_item.pending_delivery_bad_source
        @ppr.confirm(@admin)
        @template_sales_item.reload 
      end
      
      it 'should be valid ppr' do
        puts "Total error: #{@ppr.errors.size}"
        @ppr.errors.messages.each do |msg|
          puts "The error: #{msg}"
        end
        @ppr.should be_valid
      end
      
      
      
      
      it 'should confirm the post production result' do
        @ppr.is_confirmed.should be_true
        @ppr.template_sales_item_id.should == @template_sales_item.id  
      end
      
      it 'should reduce the item receival ready for post production ' do
        @template_sales_item.reload 
    
        @final_item_receival_ready_for_post_production = @template_sales_item.item_receival_ready_for_post_production
        diff = @initial_item_receival_ready_for_post_production - @final_item_receival_ready_for_post_production
        diff.should == @ok_quantity + @bad_source_quantity + @broken_quantity 
      end
      
      it 'should reduce the pending opst production by the quantity worked' do
        @final_pending_post_production_only_post_production = @template_sales_item.pending_post_production_only_post_production
        diff = @initial_pending_post_production_only_post_production - @final_pending_post_production_only_post_production
        diff.should == @ok_quantity + @bad_source_quantity + @broken_quantity 
      end
      
      it 'should increase the pending delivery bad source by 1 ' do
        @final_pending_delivery_bad_source = @template_sales_item.pending_delivery_bad_source
        diff = @final_pending_delivery_bad_source - @initial_pending_delivery_bad_source
        diff.should == @bad_source_quantity
      end
      
      
      context "sending the bad source delivery" do
        before(:each) do
          @delivery   = Delivery.create_by_employee( @admin , {
            :customer_id    => @customer.id,          
            :delivery_address   => "some address",    
            :delivery_date     => Date.new(2012, 12, 15)
          })
        end
        
        it 'should not allow delivery of bad source if the item condition is production' do
          @quantity_sent = 1
          @delivery_entry = DeliveryEntry.create_delivery_entry( @admin, @delivery, {
              :quantity_sent => @quantity_sent , 
              :quantity_sent_weight => "#{@quantity_sent*10}",
              :sales_item_id =>  @only_post_production_sales_item.id, # for pricing 
              :entry_case => DELIVERY_ENTRY_CASE[:bad_source_fail_post_production],  # pricing level 
              :item_condition => DELIVERY_ENTRY_ITEM_CONDITION[:production]  # quantity deduction 
            })
            
          @delivery_entry.should_not be_valid 
        end
        
        it 'should allow delivery of bad source if the item condition is post production' do
          @quantity_sent = 1
          @delivery_entry = DeliveryEntry.create_delivery_entry( @admin, @delivery, {
              :quantity_sent => @quantity_sent , 
              :quantity_sent_weight => "#{@quantity_sent*10}",
              :sales_item_id =>  @only_post_production_sales_item.id, # for pricing 
              :entry_case => DELIVERY_ENTRY_CASE[:bad_source_fail_post_production],  # pricing level 
              :item_condition => DELIVERY_ENTRY_ITEM_CONDITION[:post_production]  # quantity deduction 
            })
            
          @delivery_entry.should be_valid
        end
        
        context "confirming delivery" do
          before(:each) do
            @quantity_sent = 1
            @delivery_entry = DeliveryEntry.create_delivery_entry( @admin, @delivery, {
                :quantity_sent => @quantity_sent , 
                :quantity_sent_weight => "#{@quantity_sent*10}",
                :sales_item_id =>  @only_post_production_sales_item.id, # for pricing 
                :entry_case => DELIVERY_ENTRY_CASE[:bad_source_fail_post_production],  # pricing level 
                :item_condition => DELIVERY_ENTRY_ITEM_CONDITION[:post_production]  # quantity deduction 
              })
              
            @template_sales_item.reload
            @initial_ready_post_production = @template_sales_item.ready_post_production_only_post_production
            @initial_pending_delivery_bad_source = @template_sales_item.pending_delivery_bad_source
            @delivery.confirm(@admin)
            @delivery.reload 
            @delivery_entry.reload 
            @template_sales_item.reload
          end
          
          it 'should confirm delivery' do
            @delivery.is_confirmed.should be_true
          end
          
          
          it 'should  confirm delivery_entry' do
            puts "Total delivery_entry  errors: #{@delivery_entry.errors.size}"
            @delivery_entry.errors.messages.each do |msg|
              puts "The msg: #{msg}"
            end
            
            puts "Total delivery  errors: #{@delivery.errors.size}"
            @delivery.errors.messages.each do |msg|
              puts "The msg: #{msg}"
            end
            
            @delivery_entry.is_confirmed.should be_true
          end
          
          it 'should reduce the number of bad source (because we are  sending bad source)' do
            @final_pending_delivery_bad_source = @template_sales_item.pending_delivery_bad_source
            diff = @initial_pending_delivery_bad_source - @final_pending_delivery_bad_source
            diff.should == @quantity_sent 
          end
          
          it 'should  reduce the number of ready post production (we dont send any good item)' do
            @final_ready_post_production = @template_sales_item.ready_post_production_only_post_production
            diff = @initial_ready_post_production  - @final_ready_post_production
            diff.should == 0 
          end
          
              
          
        end # "confirming delivery" 
        
      end # context "sending the bad source delivery"
                  
    end # "do the post production work"
  end # context "confirming item receival" 
  
end