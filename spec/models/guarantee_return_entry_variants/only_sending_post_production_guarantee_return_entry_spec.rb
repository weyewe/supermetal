require 'spec_helper'

describe GuaranteeReturnEntry do
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
  end
  
  it 'should finalize the delivery ' do
    @delivery.is_finalized.should be_true 
  end
  
  it 'should finalze delivery entry' do
    puts "Total error: #{@delivery_entry.errors.size}"
    @delivery_entry.errors.messages.each do |msg|
      puts "The error messasge is : #{msg}"
    end
    @delivery_entry.is_finalized.should be_true 
  end
  
  
  
  context "[Previously: sending post production item]: doing the guarantee return" do
    before(:each) do
      @guarantee_return = GuaranteeReturn.create_by_employee(@admin, {
        :customer_id => @customer.id ,
        :receival_date => Date.new( 2012,12,8)
      })
      
      
     
    end
    
    it 'should create guarantee return entry, receiving post production ' do
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
      @guarantee_return_entry.should be_valid 
    end
    
    it 'should not create guarantee entry, receiving production, while didnt send out any' do
      # quantity_sent == 10 
      @gre_post_production = 0
      @gre_production = 1  
      @gre_production_repair = 1
      
      @guarantee_return_entry = GuaranteeReturnEntry.create_guarantee_return_entry( @admin, @guarantee_return ,  {
        :sales_item_id                  => @has_production_sales_item.id ,
        :quantity_for_post_production   => @gre_post_production,
        :quantity_for_production        => @gre_production,
        :quantity_for_production_repair        => @gre_production_repair,
        :weight_for_post_production     => "#{@gre_post_production*10}", 
        :weight_for_production          => "#{@gre_production*10}",
        :weight_for_production_repair          => "#{@gre_production_repair*10}",
        :item_condition => GUARANTEE_RETURN_ENTRY_ITEM_CONDITION[:production]
      } )
      @guarantee_return_entry.should_not be_valid
    end
    
    it 'should not create guarantee entry, receiving post production, but the gre production repair is not 0' do
      @gre_post_production = 3
      @gre_production = 1  
      @gre_production_repair = 1
      
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
      @guarantee_return_entry.should_not be_valid
    end
    
    it 'should not create guarantee entry, receiving post production, but the total production + post production exceed quantity sent' do
      
      @gre_post_production = @quantity_sent
      @gre_production = 0 
      @gre_production_repair = 1
      
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
      @guarantee_return_entry.should_not be_valid
    end
    
    context "post confirm guarantee return" do
      before(:each) do
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
        @guarantee_return_entry.should be_valid
        
        @template_sales_item = @has_production_sales_item.template_sales_item 
        @initial_pending_post_production = @template_sales_item.pending_post_production
        @initial_pending_production = @template_sales_item.pending_production
        @initial_receivable_post_production_guarantee_return = @has_production_sales_item.receivable_guarantee_return_normal_post_production
        @guarantee_return.confirm(@admin)
        @template_sales_item.reload 
        @has_production_sales_item.reload 
      end
      
      it 'should increase number of pending post production' do
        @final_pending_post_production = @template_sales_item.pending_post_production
        diff = @final_pending_post_production - @initial_pending_post_production
        diff.should == @gre_post_production
      end
      
      it 'should increase number of pending production'  do
        @final_pending_production = @template_sales_item.pending_production
        diff = @final_pending_production - @initial_pending_production
        diff.should  == @gre_production
      end
      
      it 'should deduct number of receivable post production guarantee return'  do
        @final_receivable_post_production_guarantee_return = @has_production_sales_item.receivable_guarantee_return_normal_post_production
        diff =  @initial_receivable_post_production_guarantee_return - @final_receivable_post_production_guarantee_return
        diff.should == @gre_production + @gre_post_production
      end
    end
    
  end
    
end