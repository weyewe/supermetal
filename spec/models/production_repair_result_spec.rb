require 'spec_helper'

describe ProductionRepairResult do
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
    @pr.confirm(@admin)
    @pr.reload
    @template_sales_item.reload 
  end
  
  it 'should increase the pending production repair' do
    @template_sales_item.pending_production_repair.should == @repairable_quantity 
  end
  
  it 'should create the production_repair_result if the processed quantity is less than or equal to the pending' do
    @ok_quantity          = 3
    @broken_quantity      = 0 
    @ok_weight            = "#{@ok_quantity*10}"
    @broken_weight        = "#{@broken_quantity*10}"
    @started_at           = DateTime.new(2012,12,11,23,1,1)
    @finished_at          = DateTime.new(2012,12,12,23,1,1)
    
    @prr = ProductionRepairResult.create_result( @admin,  {
      :ok_quantity            => @ok_quantity          ,
      :broken_quantity        => @broken_quantity      ,
      :ok_weight              => @ok_weight            ,
      :broken_weight          => @broken_weight        ,
      :started_at             => @started_at           ,
      :finished_at            => @finished_at          ,
      :template_sales_item_id => @template_sales_item.id 
    } )
    
    @prr.should be_valid 
  end
  
  it 'should not produce more than one unconfirmed object' do
    @ok_quantity          = 3
    @broken_quantity      = 0 
    @ok_weight            = "#{@ok_quantity*10}"
    @broken_weight        = "#{@broken_quantity*10}"
    @started_at           = DateTime.new(2012,12,11,23,1,1)
    @finished_at          = DateTime.new(2012,12,12,23,1,1)
    
    @prr = ProductionRepairResult.create_result( @admin,  {
      :ok_quantity            => @ok_quantity          ,
      :broken_quantity        => @broken_quantity      ,
      :ok_weight              => @ok_weight            ,
      :broken_weight          => @broken_weight        ,
      :started_at             => @started_at           ,
      :finished_at            => @finished_at          ,
      :template_sales_item_id => @template_sales_item.id 
    } )
    
    @prr.should be_valid 
    
    @prr = ProductionRepairResult.create_result( @admin,  {
      :ok_quantity            => @ok_quantity          ,
      :broken_quantity        => @broken_quantity      ,
      :ok_weight              => @ok_weight            ,
      :broken_weight          => @broken_weight        ,
      :started_at             => @started_at           ,
      :finished_at            => @finished_at          ,
      :template_sales_item_id => @template_sales_item.id 
    } )
    
    @prr.should  be_nil
  end
  
  it 'should not create the production_repair_result if the processed quantity is more than pending production repair' do
    
    @ok_quantity          = @template_sales_item.pending_production_repair  + 1 
    @broken_quantity      = 0 
    @ok_weight            = "#{@ok_quantity*10}"
    @broken_weight        = "#{@broken_quantity*10}"
    @started_at           = DateTime.new(2012,12,11,23,1,1)
    @finished_at          = DateTime.new(2012,12,12,23,1,1)
    
    @prr = ProductionRepairResult.create_result( @admin,  {
      :ok_quantity            => @ok_quantity          ,
      :broken_quantity        => @broken_quantity      ,
      :ok_weight              => @ok_weight            ,
      :broken_weight          => @broken_weight        ,
      :started_at             => @started_at           ,
      :finished_at            => @finished_at          ,
      :template_sales_item_id => @template_sales_item.id 
    } )
    
    @prr.should_not be_valid 
  end
  
  context "post create production_repair result [all ok]" do
    before(:each) do
      @ok_quantity           = 3
      @broken_quantity       = 0
      @ok_weight             = "#{@ok_quantity*10}"
      @broken_weight         = '0'
      @started_at            = DateTime.new(2012,12,11,23,1,1)
      @finished_at           = DateTime.new(2012,12,12,23,1,1)

      @prr = ProductionRepairResult.create_result( @admin,  {
        :ok_quantity            => @ok_quantity          ,
        :broken_quantity        => @broken_quantity      ,
        :ok_weight              => @ok_weight            ,
        :broken_weight          => @broken_weight        ,
        :started_at             => @started_at           ,
        :finished_at            => @finished_at          ,
        :template_sales_item_id => @template_sales_item.id 

      } )
      @template_sales_item.reload
      @initial_pending_repair = @template_sales_item.pending_production_repair
      @initial_ready_production = @template_sales_item.ready_production
    end
    
    it 'should not reduce pending production if it is not confirmed yet' do
      @final_pending_repair = @template_sales_item.pending_production_repair 
      diff = @final_pending_repair - @initial_pending_repair
      diff.should == 0 
    end
    
    it 'should not add ready production if it is not confirmed yet' do
      @final_ready_production = @template_sales_item.ready_production
      diff  = @final_ready_production - @initial_ready_production
      diff.should ==0 
    end
    
    context 'post confirm production result' do
      before(:each) do
        @ready_production_pre_confirm = @template_sales_item.ready_production
        @pending_production_repair_pre_confirm = @template_sales_item.pending_production_repair
        @prr.confirm( @admin )
        @template_sales_item.reload
      end
      
      it 'should be confirmed' do
        @prr.is_confirmed.should be_true 
      end
      
      it 'should increase production ready' do
        @ready_production_post_confirm = @template_sales_item.ready_production
        diff = @ready_production_post_confirm - @ready_production_pre_confirm
        diff.should == @ok_quantity 
      end
      
      it 'should not allow for double confirmation' do
        @prr.confirm(@admin).should be_nil 
      end
      
      it 'should deduct the pending production repair' do
        @pending_production_repair_post_confirm = @template_sales_item.pending_production_repair
        diff = @pending_production_repair_pre_confirm - @pending_production_repair_post_confirm
        diff.should == @ok_quantity
      end
      
    end # 'post confirm production repair result' 
    
  end #  "post create production_repair result [all ok]"
  
  context "post create production_repair result [ ok + fail]" do
    before(:each) do
      @ok_quantity           = 3
      @broken_quantity       = 2
      @ok_weight             = "#{@ok_quantity*10}"
      @broken_weight         = "#{@broken_quantity*10}"
      @started_at            = DateTime.new(2012,12,11,23,1,1)
      @finished_at           = DateTime.new(2012,12,12,23,1,1)
  
      @prr = ProductionRepairResult.create_result( @admin,  {
        :ok_quantity            => @ok_quantity          ,
        :broken_quantity        => @broken_quantity      ,
        :ok_weight              => @ok_weight            ,
        :broken_weight          => @broken_weight        ,
        :started_at             => @started_at           ,
        :finished_at            => @finished_at          ,
        :template_sales_item_id => @template_sales_item.id 
      } )
      
      @template_sales_item.reload
      @initial_pending_repair = @template_sales_item.pending_production_repair
      @initial_ready_production = @template_sales_item.ready_production
    end
    
    it 'should not reduce pending production if it is not confirmed yet' do
      @final_pending_repair = @template_sales_item.pending_production_repair 
      diff = @final_pending_repair - @initial_pending_repair
      diff.should == 0 
    end
    
    it 'should not add ready production if it is not confirmed yet' do
      @final_ready_production = @template_sales_item.ready_production
      diff  = @final_ready_production - @initial_ready_production
      diff.should ==0 
    end
    
    context 'post confirm production result' do
      before(:each) do
        @pending_production_pre_confirm = @template_sales_item.pending_production
        @ready_production_pre_confirm = @template_sales_item.ready_production
        @pending_production_repair_pre_confirm = @template_sales_item.pending_production_repair
        @prr.confirm( @admin )
        @template_sales_item.reload
      end
      
      it 'should be confirmed' do
        @prr.is_confirmed.should be_true 
      end
      
      it 'should increase production ready' do
        @ready_production_post_confirm = @template_sales_item.ready_production
        diff = @ready_production_post_confirm - @ready_production_pre_confirm
        diff.should == @ok_quantity 
      end
      
      it 'should increase pending_production' do
        @pending_production_post_confirm = @template_sales_item.pending_production
        diff = @pending_production_post_confirm - @pending_production_pre_confirm
        diff.should == @broken_quantity 
      end
      
      it 'should not allow for double confirmation' do
        @prr.confirm(@admin).should be_nil 
      end
      
      it 'should deduct the pending production repair' do
        @pending_production_repair_post_confirm = @template_sales_item.pending_production_repair
        diff = @pending_production_repair_pre_confirm - @pending_production_repair_post_confirm
        diff.should == @ok_quantity + @broken_quantity 
      end
      
    end # 'post confirm production repair result' 
    
  end #  "post create production_repair result [all ok]"
  
end