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
    
    @quantity_for_production      = @has_production_quantity
    @quantity_for_post_production = @has_production_quantity
    @is_pending_pricing           = false
    @is_pricing_by_weight         = false 
    @is_pre_production            = true 
    @is_production                = true 
    @is_post_production           = true 
    @pre_production_price         = "50000"
    @production_price             = "20000"
    @post_production_price        = "150000"
    @requested_deadline           = Date.new(2013, 3,5 )
    @name                         = "Sales Item"
    @description                  = "Bla bla bla bla bla"
    @delivery_address             = "Yeaaah babyy"
    
    @has_production_sales_item = SalesItem.create_sales_item( @admin, @sales_order,  {
      :material_id => @copper.id, 
      :is_pre_production => true , 
      :is_production     => true, 
      :is_post_production => true, 
      :is_delivered => true, 
      :delivery_address => "Perumahan Citra Garden 1 Blok AC2/3G",
      :quantity_for_production => @has_production_quantity, 
      :quantity_for_post_production => @has_production_quantity,
      :description => @description, 
      :delivery_address => @delivery_address, 
      :requested_deadline => Date.new(2013, 3,5 ),
      :weight_per_piece   => '15',
      :name => @name,
      :is_pending_pricing    => false, 
      :is_pricing_by_weight  => false , 
      :pre_production_price  => "50000", 
      :production_price      => "20000",
      :post_production_price => "150000"
    })
    @sales_order.confirm(@admin)
    @has_production_sales_item.reload 
    @template_sales_item = @has_production_sales_item.template_sales_item
  end
  
  it 'should confirm sales item' do
    @has_production_sales_item.is_confirmed.should be_true 
  end
  
  it 'should create template sales item' do
    @template_sales_item.should be_valid 
  end
  
  it 'should not allow update where post production quantity > pre production quantity' do
    @quantity_for_production          =  70
    @quantity_for_post_production =  80 
  
    @has_production_sales_item.post_confirm_update(@admin,  {
      :quantity_for_production      =>      @quantity_for_production     ,                                 
      :quantity_for_post_production =>      @quantity_for_post_production,                                 
      :is_pending_pricing           =>      @is_pending_pricing          ,                                 
      :is_pricing_by_weight         =>      @is_pricing_by_weight        ,                                 
      :is_pre_production            =>      @is_pre_production           ,                                 
      :is_production                =>      @is_production               ,                                 
      :is_post_production           =>      @is_post_production          ,                                 
      :pre_production_price         =>      @pre_production_price        ,                                 
      :production_price             =>      @production_price            , 
      :weight_per_piece   => '15',                                
      :post_production_price        =>      @post_production_price       ,                                 
      :requested_deadline           =>      @requested_deadline          ,                                 
      :name                         =>      @name                        ,                                 
      :description                  =>      @description                 ,
      :delivery_address => @delivery_address
    })
    
    @has_production_sales_item.errors.size.should_not == 0 
  end
  
  it 'should not allow not is_post_production, but the quantity!= 0 ' do
    @quantity_for_production          =  70
    @quantity_for_post_production =  80 
  
    @has_production_sales_item.post_confirm_update(@admin,  {
      :quantity_for_production      =>      @quantity_for_production     ,                                 
      :quantity_for_post_production =>      @quantity_for_post_production,                                 
      :is_pending_pricing           =>      @is_pending_pricing          ,                                 
      :is_pricing_by_weight         =>      @is_pricing_by_weight        ,                                 
      :is_pre_production            =>      @is_pre_production           ,                                 
      :is_production                =>      @is_production               ,                                 
      :is_post_production           =>      false           ,                                 
      :pre_production_price         =>      @pre_production_price        ,                                 
      :production_price             =>      @production_price            ,                                 
      :post_production_price        =>      @post_production_price       ,    
      :weight_per_piece   => '15',                             
      :requested_deadline           =>      @requested_deadline          ,                                 
      :name                         =>      @name                        ,                                 
      :description                  =>      @description                 ,
      :delivery_address => @delivery_address
    })
    
    @has_production_sales_item.errors.size.should_not == 0
  end
  
  it 'should not allow switching from production + post production to only post production' do
    @quantity_for_production          =  0
    @quantity_for_post_production =  80 
    
 

    @has_production_sales_item.post_confirm_update(@admin,  {
      :quantity_for_production      =>      @quantity_for_production     ,                                 
      :quantity_for_post_production =>      @quantity_for_post_production,                                 
      :is_pending_pricing           =>      @is_pending_pricing          ,                                 
      :is_pricing_by_weight         =>      @is_pricing_by_weight        ,                                 
      :is_pre_production            =>      false           ,                                 
      :is_production                =>      false              ,                                 
      :is_post_production           =>      true           ,                                 
      :pre_production_price         =>      @pre_production_price        ,                                 
      :production_price             =>      @production_price            ,                                 
      :post_production_price        =>      @post_production_price       ,                                 
      :requested_deadline           =>      @requested_deadline          ,                                 
      :name                         =>      @name                        ,                                 
      :description                  =>      @description                 ,
      :delivery_address => @delivery_address
    })
    
    @has_production_sales_item.errors.size.should_not == 0
  end
  
   
  
  context "update quantity" do
    before(:each) do
    
      @sales_production_order = ProductionOrder.where(
        :source_document_entry => @has_production_sales_item.class.to_s,
        :source_document_entry_id => @has_production_sales_item.id , 
        :case                     => PRODUCTION_ORDER[:sales_order]
      ).first 
      
      @sales_post_production_order = PostProductionOrder.where(
        :source_document_entry => @has_production_sales_item.class.to_s,
        :source_document_entry_id => @has_production_sales_item.id , 
        :case                     => POST_PRODUCTION_ORDER[:sales_order]
      ).first
      
      
      
      @quantity_for_production          =  70
      @quantity_for_post_production = 55
  
      @has_production_sales_item.post_confirm_update(@admin,  {
        :quantity_for_production      =>      @quantity_for_production     ,                                 
        :quantity_for_post_production =>      @quantity_for_post_production,                                 
        :is_pending_pricing           =>      @is_pending_pricing          ,                                 
        :is_pricing_by_weight         =>      @is_pricing_by_weight        ,                                 
        :is_pre_production            =>      @is_pre_production           ,                                 
        :is_production                =>      @is_production               ,                                 
        :is_post_production           =>      @is_post_production          ,                                 
        :pre_production_price         =>      @pre_production_price        ,                                 
        :production_price             =>      @production_price            ,                                 
        :post_production_price        =>      @post_production_price       , 
        :weight_per_piece   => '15',                                
        :requested_deadline           =>      @requested_deadline          ,                                 
        :name                         =>      @name                        ,                                 
        :description                  =>      @description                 ,
        :delivery_address => @delivery_address
      })
      
      @sales_production_order.reload 
      @sales_post_production_order.reload 
    end
    
    it 'should not produce any error on update' do
      @has_production_sales_item.errors.size.should == 0 
    end
    
    it 'should change the production order quantity' do
      @sales_production_order.quantity.should == @quantity_for_production
    end
    
    it 'should change the post production order quantity ' do
      @sales_post_production_order.quantity.should == @quantity_for_post_production
    end
  end
   
   
end