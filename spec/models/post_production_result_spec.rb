require 'spec_helper'

describe PostProductionResult do
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
    
    @ok_quantity           = 20
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
  end
  
  it 'should produce production ready' do
    @template_sales_item.ready_production.should == @ok_quantity
  end
  
  it 'should produce relevant template sales item' do
    @template_sales_item.is_internal_production.should be_true 
  end
  
  it 'should not change the pending post production' do
    @template_sales_item.pending_post_production.should == @has_production_quantity
  end
  
  it 'should create post production result' do
    @ready_quantity       = @template_sales_item.ready_production 
    @ok_quantity             =   10 
    @broken_quantity         =   0 
    @bad_source_quantity     =   0 
    @ok_weight               =   "#{@ok_quantity*10}" 
    @broken_weight           =   0 
    @bad_source_weight       =   0 
    @started_at              =   DateTime.new(2012,12,12,15,15 ,0 ) 
    @finished_at             =   DateTime.new(2012,12,18,15,15 ,0 ) 
    
    ppr = PostProductionResult.create_result(@admin, {
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
    
    ppr.should be_valid 
    
  end
  
  it 'should not create double (if there is unconfirmed)' do
    @ready_quantity       = @template_sales_item.ready_production 
    @ok_quantity             =   10 
    @broken_quantity         =   0 
    @bad_source_quantity     =   0 
    @ok_weight               =   "#{@ok_quantity*10}" 
    @broken_weight           =   0 
    @bad_source_weight       =   0 
    @started_at              =   DateTime.new(2012,12,12,15,15 ,0 ) 
    @finished_at             =   DateTime.new(2012,12,18,15,15 ,0 ) 
    
    ppr = PostProductionResult.create_result(@admin, {
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
    
    ppr.should be_valid
    
    ppr = PostProductionResult.create_result(@admin, {
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
    
    ppr.should be_nil
  end
  
  it 'should not allow creation if the quantity processed exceed the pending post production' do
    @ready_quantity       = @template_sales_item.ready_production 
    @ok_quantity             =   @ready_quantity 
    @broken_quantity         =   2
    @bad_source_quantity     =   0 
    @ok_weight               =   "#{@ok_quantity*10}" 
    @broken_weight           =   0 
    @bad_source_weight       =   0 
    @started_at              =   DateTime.new(2012,12,12,15,15 ,0 ) 
    @finished_at             =   DateTime.new(2012,12,18,15,15 ,0 ) 
    
    ppr = PostProductionResult.create_result(@admin, {
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
    
    ppr.should_not be_valid
  end
  
  context "post create production result [all ok]" do
    before(:each) do
      @ready_quantity       = @template_sales_item.ready_production 
      @ok_quantity             =   10 
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
    end
    
   
    it 'should not reduce pending production if it is not confirmed yet' do
      @final_pending_post_production = @template_sales_item.pending_post_production 
      diff = @initial_pending_post_production - @final_pending_post_production
      diff.should == 0 
    end
    
    context 'post confirm production result' do
      before(:each) do
        @pending_post_production_pre_confirm = @template_sales_item.pending_post_production
        @ppr.confirm( @admin )
        @template_sales_item.reload
      end
      
      it 'should be confirmed' do
        @pr.is_confirmed.should be_true 
      end
      
      it 'should produce production ready' do
        @template_sales_item.ready_post_production.should == @ok_quantity
      end
      
      it 'should not allow for double confirmation' do
        @ppr.confirm(@admin).should be_nil 
      end
      
      it 'should deduct the pending production' do
        @pending_post_production_post_confirm = @template_sales_item.pending_post_production
        diff = @pending_post_production_pre_confirm - @pending_post_production_post_confirm
        diff.should == @ok_quantity
      end
      
    end # 'post confirm production result' 
    
  end #  "post create production result [all ok]"
  
  context "post create production result [all ok + bad source + technical failure]" do
    before(:each) do
      @ready_quantity       = @template_sales_item.ready_production 
      @ok_quantity             =   10 
      @broken_quantity         =   2
      @bad_source_quantity     =   1 
      @ok_weight               =   "#{@ok_quantity*10}" 
      @broken_weight           =   "#{@broken_quantity*10}"  
      @bad_source_weight       =   "#{@bad_source_quantity*10}" 
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
    end
    
   
    it 'should not reduce pending production if it is not confirmed yet' do
      @final_pending_post_production = @template_sales_item.pending_post_production 
      diff = @initial_pending_post_production - @final_pending_post_production
      diff.should == 0 
    end
    
    context 'post confirm production result' do
      before(:each) do
        @pending_post_production_pre_confirm = @template_sales_item.pending_post_production
        @pending_production_pre_confirm_ppr = @template_sales_item.pending_production
        @ready_post_production_pre_confirm_ppr = @template_sales_item.ready_post_production
        @ppr.confirm( @admin )
        @template_sales_item.reload
      end
      
      it 'should be confirmed' do
        @ppr.is_confirmed.should be_true 
      end
      
      it 'should produce production ready' do
        @template_sales_item.ready_post_production.should == @ok_quantity
      end
      
      it 'should not allow for double confirmation' do
        @ppr.confirm(@admin).should be_nil 
      end
      
      it 'should deduct the pending production' do
        @pending_post_production_post_confirm = @template_sales_item.pending_post_production
        diff = @pending_post_production_pre_confirm - @pending_post_production_post_confirm
        diff.should == @ok_quantity
      end
      
      it 'should create production order with case: bad_source' do
        ProductionOrder.where(
          :template_sales_item_id    => @ppr.template_sales_item_id,
          :case                     => PRODUCTION_ORDER[:post_production_failure_bad_source],
          :source_document_entry    => @ppr.class.to_s ,
          :source_document_entry_id    => @ppr.id
        ).count.should == 1 
      end
      
      it 'should create production order with case: technical_failure' do
        ProductionOrder.where(
          :template_sales_item_id    => @ppr.template_sales_item_id,
          :case                     => PRODUCTION_ORDER[:post_production_failure_technical_failure],
          :source_document_entry    => @ppr.class.to_s ,
          :source_document_entry_id    => @ppr.id
        ).count.should == 1
      end
      
      it 'should increase the pending production' do
        @pending_production_post_confirm_ppr = @template_sales_item.pending_production
        diff = @pending_production_post_confirm_ppr - @pending_production_pre_confirm_ppr
        diff.should == @broken_quantity + @bad_source_quantity 
      end
      
      it 'should increase the ready post production' do
        @ready_post_production_post_confirm_ppr = @template_sales_item.ready_post_production
        diff = @ready_post_production_post_confirm_ppr - @ready_post_production_pre_confirm_ppr
        diff.should == @ok_quantity 
      end
      
    end # 'post confirm production result' 
    
  end #  "post create production result [all ok + broken + bad source]"
end