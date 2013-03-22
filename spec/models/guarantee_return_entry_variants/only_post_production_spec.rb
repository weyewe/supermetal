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
    
    @initial_pending_item_receival_ready = @template_sales_item.item_receival_ready_for_post_production
    @item_receival.confirm(@admin)
    @item_receival.reload
    @item_receival_entry.reload 
    @only_post_production_sales_item.reload 
    @template_sales_item.reload 
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
    @delivery   = Delivery.create_by_employee( @admin , {
      :customer_id    => @customer.id,          
      :delivery_address   => "some address",    
      :delivery_date     => Date.new(2012, 12, 15)
    })
    
    @quantity_sent = 4
    @delivery_entry = DeliveryEntry.create_delivery_entry( @admin, @delivery, {
        :quantity_sent => @quantity_sent , 
        :quantity_sent_weight => "#{@quantity_sent*10}",
        :sales_item_id =>  @only_post_production_sales_item.id, # for pricing 
        :entry_case => DELIVERY_ENTRY_CASE[:normal],  # pricing level 
        :item_condition => DELIVERY_ENTRY_ITEM_CONDITION[:post_production]  # quantity deduction 
      })
      
    @template_sales_item.reload
    @initial_ready_post_production = @template_sales_item.ready_post_production_only_post_production
    @initial_pending_delivery_bad_source = @template_sales_item.pending_delivery_bad_source
    @delivery.confirm(@admin)
    @delivery.reload 
    @delivery_entry.reload 
    @template_sales_item.reload
    @only_post_production_sales_item.reload 
    
    @guarantee_return = GuaranteeReturn.create_by_employee(@admin, {
      :customer_id => @customer.id ,
      :receival_date => Date.new( 2012,12,8)
    })
  end
  
  it 'should have receivable post production' do
    @only_post_production_sales_item.normal_post_production_delivery.should == @quantity_sent
  end
  
  
  it 'should not receiving production item_condition' do
    @gre_post_production = 3
    @gre_production = 1  
    @gre_production_repair = 1 
   
    
    @guarantee_return_entry = GuaranteeReturnEntry.create_guarantee_return_entry( @admin, @guarantee_return ,  {
      :sales_item_id                  => @only_post_production_sales_item.id ,
      :quantity_for_post_production   => @gre_post_production,
      :quantity_for_production        => @gre_production,
      :quantity_for_production_repair        => @gre_production_repair,
      :weight_for_post_production     => "#{@gre_post_production*10}", 
      :weight_for_production          => "#{@gre_production*10}",
      :weight_for_production_repair          => "#{@gre_production_repair*10}",
      :item_condition => DELIVERY_ENTRY_ITEM_CONDITION[:production]
    } )
    
    @guarantee_return_entry.should_not be_valid
  end
  
  it 'should not allow production repair treatment' do
    @gre_post_production = 0
    @gre_production = 0  
    @gre_production_repair = 1 
   
    
    @guarantee_return_entry = GuaranteeReturnEntry.create_guarantee_return_entry( @admin, @guarantee_return ,  {
      :sales_item_id                  => @only_post_production_sales_item.id ,
      :quantity_for_post_production   => @gre_post_production,
      :quantity_for_production        => @gre_production,
      :quantity_for_production_repair        => @gre_production_repair,
      :weight_for_post_production     => "#{@gre_post_production*10}", 
      :weight_for_production          => "#{@gre_production*10}",
      :weight_for_production_repair          => "#{@gre_production_repair*10}",
      :item_condition => DELIVERY_ENTRY_ITEM_CONDITION[:post_production]
    } )
    
    @guarantee_return_entry.should_not be_valid
  end
  
  it 'should not allow production  treatment (because not made in house)' do
    @gre_post_production = 0
    @gre_production = 1  
    @gre_production_repair = 0 
   
    
    @guarantee_return_entry = GuaranteeReturnEntry.create_guarantee_return_entry( @admin, @guarantee_return ,  {
      :sales_item_id                  => @only_post_production_sales_item.id ,
      :quantity_for_post_production   => @gre_post_production,
      :quantity_for_production        => @gre_production,
      :quantity_for_production_repair        => @gre_production_repair,
      :weight_for_post_production     => "#{@gre_post_production*10}", 
      :weight_for_production          => "#{@gre_production*10}",
      :weight_for_production_repair          => "#{@gre_production_repair*10}",
      :item_condition => DELIVERY_ENTRY_ITEM_CONDITION[:post_production]
    } )
    
    @guarantee_return_entry.should_not be_valid
  end
  
  it 'should create post production repair' do
    @gre_post_production = 1
    @gre_production = 0 
    @gre_production_repair = 0 
   
    
    @guarantee_return_entry = GuaranteeReturnEntry.create_guarantee_return_entry( @admin, @guarantee_return ,  {
      :sales_item_id                  => @only_post_production_sales_item.id ,
      :quantity_for_post_production   => @gre_post_production,
      :quantity_for_production        => @gre_production,
      :quantity_for_production_repair        => @gre_production_repair,
      :weight_for_post_production     => "#{@gre_post_production*10}", 
      :weight_for_production          => "#{@gre_production*10}",
      :weight_for_production_repair          => "#{@gre_production_repair*10}",
      :item_condition => DELIVERY_ENTRY_ITEM_CONDITION[:post_production]
    } )
    
    
    puts "Total errors: #{@guarantee_return_entry.errors.size}"
    @guarantee_return_entry.errors.messages.each do |msg|
      puts "MSG: #{msg}}"
    end
    @guarantee_return_entry.should be_valid
  end
  
  
  context "creating the guarantee return entry: for post production, no production repair" do
    before(:each) do
      @gre_post_production = 3
      @gre_production = 0   
      @gre_production_repair = 0 
  
  
      @guarantee_return_entry = GuaranteeReturnEntry.create_guarantee_return_entry( @admin, @guarantee_return ,  {
        :sales_item_id                  => @only_post_production_sales_item.id ,
        :quantity_for_post_production   => @gre_post_production,
        :quantity_for_production        => @gre_production,
        :quantity_for_production_repair        => @gre_production_repair,
        :weight_for_post_production     => "#{@gre_post_production*10}", 
        :weight_for_production          => "#{@gre_production*10}",
        :weight_for_production_repair          => "#{@gre_production_repair*10}",
        :item_condition => DELIVERY_ENTRY_ITEM_CONDITION[:post_production]
      } )
      
    end
    
    it 'should create guarantee return entry' do
      @guarantee_return_entry.should be_valid
    end
  
    context 'confirm guarantee return' do
      before(:each) do
        @template_sales_item.reload
    
        @initial_pending_production = @template_sales_item.pending_production
        @initial_pending_post_production = @template_sales_item.pending_post_production_only_post_production
        @initial_pending_production_repair =  @template_sales_item.pending_production_repair
        @initial_pending_guarantee_return = @template_sales_item.pending_guarantee_return 
        @guarantee_return.confirm(@admin)
        @only_post_production_sales_item.reload 
        @template_sales_item.reload
        @guarantee_return_entry.reload 
      end
    
      it 'should confirm guarantee return' do
        @guarantee_return.is_confirmed.should be_true 
      end
    
      it 'should confirm guarantee return entry' do
        @guarantee_return_entry.is_confirmed.should be_true 
      end
    
      it 'should NOT generate production order' do
        ProductionOrder.where(
          :source_document_entry => @guarantee_return_entry.class.to_s,
          :source_document_entry_id => @guarantee_return_entry.id,
          :case => PRODUCTION_ORDER[:guarantee_return]  
        ).count.should == 0 
      end
    
      it 'should NOT generate production repair order' do
        ProductionRepairOrder.where(
          :source_document_entry => @guarantee_return_entry.class.to_s,
          :source_document_entry_id => @guarantee_return_entry.id,
          :case => PRODUCTION_REPAIR_ORDER[:guarantee_return]  
        ).count.should ==0 
      end
      
      it 'should   generate post production repair order' do
        PostProductionOrder.where(
          :source_document_entry => @guarantee_return_entry.class.to_s,
          :source_document_entry_id => @guarantee_return_entry.id,
          :case => POST_PRODUCTION_ORDER[:guarantee_return] 
        ).count.should == 1
      end
    
      it 'should  NOT increase pending production' do
        @final_pending_production = @template_sales_item.pending_production
        diff = @final_pending_production - @initial_pending_production
        diff.should ==  0 
      end
      
      it 'should NOT  increase pending production repair ' do
        @final_pending_production_repair = @template_sales_item.pending_production_repair
        diff = @final_pending_production_repair - @initial_pending_production_repair
        diff.should == 0
      end
    
      it 'should  increase pending post production' do
        @final_pending_post_production = @template_sales_item.pending_post_production_only_post_production
        diff = @final_pending_post_production  - @initial_pending_post_production
    
        diff.should == @gre_post_production
      end
    
      it 'should increase the number of pending return guarantee return' do
        @final_pending_guarantee_return = @template_sales_item.pending_guarantee_return 
        diff = @final_pending_guarantee_return - @initial_pending_guarantee_return
    
        diff.should ==  @gre_post_production  + @gre_production  + @gre_production_repair 
      end
    end
      
      
  
  end
  
end