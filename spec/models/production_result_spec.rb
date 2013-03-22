require 'spec_helper'

describe ProductionResult do
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
  end
  
  it 'sanity check: confirmed + template sales item' do
    @has_production_sales_item.is_confirmed.should be_true 
    @template_sales_item.should be_valid 
    @has_production_sales_item.template_sales_item_id.should == @template_sales_item.id 
  end
  
  it 'should able to create production result' do
    ok_quantity           = 10
    repairable_quantity   = 0
    broken_quantity       = 0
    ok_weight             = "#{ok_quantity*10}"
    repairable_weight     = '0'
    broken_weight         = '0'
    started_at            = DateTime.new(2012,12,11,23,1,1)
    finished_at           = DateTime.new(2012,12,12,23,1,1)
    
    
    
    
    
    
    pr = ProductionResult.create_result( @admin,  {
      :ok_quantity            => ok_quantity          ,
      :repairable_quantity    => repairable_quantity  ,
      :broken_quantity        => broken_quantity      ,
      :ok_weight              => ok_weight            ,
      :repairable_weight      => repairable_weight    ,
      :broken_weight          => broken_weight        ,
      :started_at             => started_at           ,
      :finished_at            => finished_at          ,
      :template_sales_item_id => @template_sales_item.id 

    } ) 
    
    pr.should be_valid 
  end
  
  it 'should not allow 2 unconfirmed production results' do
    
    ok_quantity           = 10
    repairable_quantity   = 0
    broken_quantity       = 0
    ok_weight             = "#{ok_quantity*10}"
    repairable_weight     = '0'
    broken_weight         = '0'
    started_at            = DateTime.new(2012,12,11,23,1,1)
    finished_at           = DateTime.new(2012,12,12,23,1,1)
    
    pr = ProductionResult.create_result( @admin,  {
      :ok_quantity            => ok_quantity          ,
      :repairable_quantity    => repairable_quantity  ,
      :broken_quantity        => broken_quantity      ,
      :ok_weight              => ok_weight            ,
      :repairable_weight      => repairable_weight    ,
      :broken_weight          => broken_weight        ,
      :started_at             => started_at           ,
      :finished_at            => finished_at          ,
      :template_sales_item_id => @template_sales_item.id 

    } ) 
    
    pr.should be_valid
    
    pr = ProductionResult.create_result( @admin,  {
      :ok_quantity            => ok_quantity          ,
      :repairable_quantity    => repairable_quantity  ,
      :broken_quantity        => broken_quantity      ,
      :ok_weight              => ok_weight            ,
      :repairable_weight      => repairable_weight    ,
      :broken_weight          => broken_weight        ,
      :started_at             => started_at           ,
      :finished_at            => finished_at          ,
      :template_sales_item_id => @template_sales_item.id 

    } ) 
    
    pr.should be_nil 
  end
  
  context "post create production result [all ok]" do
    before(:each) do
      @ok_quantity           = 10
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
    end
    
    it 'should not reduce pending production if it is not confirmed yet' do
      @final_pending_production = @template_sales_item.pending_production 
      diff = @initial_pending_production - @final_pending_production
      diff.should == 0 
    end
    
    context 'post confirm production result' do
      before(:each) do
        @pending_production_pre_confirm = @template_sales_item.pending_production
        @pr.confirm( @admin )
        @template_sales_item.reload
      end
      
      it 'should be confirmed' do
        @pr.is_confirmed.should be_true 
      end
      
      it 'should produce production ready' do
        @template_sales_item.ready_production.should == @ok_quantity
      end
      
      it 'should not allow for double confirmation' do
        @pr.confirm(@admin).should be_nil 
      end
      
      it 'should deduct the pending production' do
        @pending_production_post_confirm = @template_sales_item.pending_production
        diff = @pending_production_pre_confirm - @pending_production_post_confirm
        diff.should == @ok_quantity
      end
      
    end # 'post confirm production result' 
    
  end #  "post create production result [all ok]"
  
  
  
  context "post create production result [all + repairable quantity]" do
    before(:each) do
      @ok_quantity           = 10
      @repairable_quantity   = 5 
      @broken_quantity       = 0
      @ok_weight             = "#{@ok_quantity*10}"
      @repairable_weight     = "#{@repairable_quantity *10}"
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
    end
    
    it 'should not reduce pending production if it is not confirmed yet' do
      @final_pending_production = @template_sales_item.pending_production 
      diff = @initial_pending_production - @final_pending_production
      diff.should == 0 
    end
    
    context 'post confirm production result' do
      before(:each) do
        @pending_production_pre_confirm = @template_sales_item.pending_production
        @pr.confirm( @admin )
      end
      
      it 'should be confirmed' do
        @pr.is_confirmed.should be_true 
      end
      
      it 'should not allow for double confirmation' do
        @pr.confirm(@admin).should be_nil 
      end
      
      it 'should deduct the pending production' do
        @pending_production_post_confirm = @template_sales_item.pending_production
        diff = @pending_production_pre_confirm - @pending_production_post_confirm
        diff.should == @ok_quantity  + @repairable_quantity
      end
      
      it 'should create pending production repair' do
        @template_sales_item.pending_production_repair.should == @repairable_quantity 
      end
      
      it 'should create ready_production' do
        @template_sales_item.ready_production.should == @ok_quantity
      end
      
      it 'should create production_repair_order' do
        ProductionRepairOrder.where(
          :template_sales_item_id => @template_sales_item.id, 
          :source_document_entry_id => @pr.id ,
          :source_document_entry => @pr.class.to_s,
          :case                     => PRODUCTION_REPAIR_ORDER[:production_repair]
        ).count.should == 1 
      end
      
    end # 'post confirm production result' 
    
  end #  "post create production result [all + repairable quantity]"
  
  
  
  context "post create production result [all + repairable quantity + broken quantity]" do
    before(:each) do
      @ok_quantity           = 10
      @repairable_quantity   = 5 
      @broken_quantity       = 5
      @ok_weight             = "#{@ok_quantity*10}"
      @repairable_weight     = "#{@repairable_quantity *10}"
      @broken_weight         = "#{@broken_quantity *10}"
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
    end
    
    it 'should not reduce pending production if it is not confirmed yet' do
      @final_pending_production = @template_sales_item.pending_production 
      diff = @initial_pending_production - @final_pending_production
      diff.should == 0 
    end
    
    context 'post confirm production result' do
      before(:each) do
        @pending_production_pre_confirm = @template_sales_item.pending_production
        @pr.confirm( @admin )
        @template_sales_item.reload 
      end
      
      it 'should be confirmed' do
        @pr.is_confirmed.should be_true 
      end
      
      it 'should not allow for double confirmation' do
        @pr.confirm(@admin).should be_nil 
      end
      
      it 'should deduct the pending production' do
        @pending_production_post_confirm = @template_sales_item.pending_production
        diff = @pending_production_pre_confirm - @pending_production_post_confirm
        diff.should == @ok_quantity  + @repairable_quantity
      end
      
      it 'should create ready_production' do
        @template_sales_item.ready_production.should == @ok_quantity 
      end
      
      it 'should not change pending production' do
        @template_sales_item.pending_post_production.should == @has_production_quantity
      end
      
      it 'should create production_repair_order' do
        ProductionRepairOrder.where(
          :template_sales_item_id => @template_sales_item.id, 
          :source_document_entry_id => @pr.id ,
          :source_document_entry => @pr.class.to_s,
          :case                     => PRODUCTION_REPAIR_ORDER[:production_repair]
        ).count.should == 1 
      end
      
      it 'should create production order, case : production failure' do
        ProductionOrder.where(
          :template_sales_item_id => @template_sales_item.id, 
          :source_document_entry_id => @pr.id ,
          :source_document_entry => @pr.class.to_s,
          :case                     => PRODUCTION_ORDER[:production_failure] 
        ).count.should == 1
      end
      
    end # 'post confirm production result' 
    
  end #  "post create production result [all + repairable quantity + broken quantity] "
end