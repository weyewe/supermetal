require 'spec_helper'

describe Delivery do
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
  end
   
  it 'should have ready production and ready post production' do
    @template_sales_item.ready_production.should == @ok_production_quantity - @ppr.processed_quantity
    @template_sales_item.ready_post_production.should == @ok_post_production_quantity
  end
  
  it 'should not allow sales order creation if there is no employee' do 
    delivery   = Delivery.create_by_employee( nil , {
      :customer_id    => @customer.id,          
      :delivery_address   => "some address",    
      :delivery_date     => Date.new(2012, 12, 15) 
    })
    
    delivery.should be_nil 
  end
  
  it 'should allow creation if there is employee' do 
    
    delivery   = Delivery.create_by_employee( @admin , {
      :customer_id    => @customer.id,          
      :delivery_address   => "some address",    
      :delivery_date     => Date.new(2012, 12, 15)   
    })
    
    delivery.should be_valid
  end
  
  context "post sales order creation" do
    before(:each) do
      @delivery   = Delivery.create_by_employee( @admin , {
        :customer_id    => @customer.id,          
        :delivery_address   => "some address",    
        :delivery_date     => Date.new(2012, 12, 15)
      })
    end
    
    it 'should not be confirmable if there is no sales item' do
      @delivery.confirm( @admin ) 
      @delivery.is_confirmed.should be_false 
    end 
    
    context 'creating delivery with 1 delivery entry ' do
      before(:each) do
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
      end
      
      it 'should have 1 delivery_entry' do
        @delivery.delivery_entries.count.should == 1 
      end
      
      it 'should be confirmable' do 
        @delivery.confirm( @admin ) 
        @delivery.is_confirmed.should be_true
      end
      
      it 'should not be finalizeable if no confirmation' do
        result = @delivery.finalize( @admin ) 
        result.should be_nil 
        @delivery.is_finalized.should be_false 
      end
      
      context "on delivery confirmation: UPDATE THE FINALIZED STATUS, SALES RETURN and LOST DELIVERY" do
        before(:each) do
          @template_sales_item.reload 
          @initial_on_delivery = @template_sales_item.on_delivery 
          
          @delivery.confirm( @admin ) 
          @has_production_sales_item.reload 
          @delivery_entry.reload
          @template_sales_item.reload
        end
        
        it 'should add the on_delivery status and deduct the ready status' do
          @final_on_delivery = @template_sales_item.on_delivery
          delta = @final_on_delivery  - @initial_on_delivery  
          
          
          delta.should == @quantity_sent
        end
        
        
        it 'should not finalize if there is returned weight, but 0 returned quantity'  do
          @delivery_entry.update_post_delivery(@admin, {
            :quantity_confirmed => @delivery_entry.quantity_sent , 
            :quantity_confirmed_weight =>  "#{@delivery_entry.quantity_sent*10 }", 
            :quantity_returned => 0 ,
            :quantity_returned_weight => '10' ,
            :quantity_lost => 0
          })
          
          
          @delivery_entry.reload 
          @delivery_entry.errors.size.should_not == 0 
          
          #  fuck, not fail..
          @delivery.finalize(@admin)
          @delivery.reload 
          @delivery.is_finalized.should be_false
        end
        
               
        
        
        it 'should not finalize if quantity_sent != quantity_confirmed + quantity return + quantity loss ' do
          @delivery_entry.update_post_delivery(@admin, {
            :quantity_confirmed => @delivery_entry.quantity_sent , 
            :quantity_confirmed_weight =>  "#{@delivery_entry.quantity_sent*10 }", 
            :quantity_returned => 1 ,
            :quantity_returned_weight => '10' ,
            :quantity_lost => 1
          })
          
          # we are doing this errors checking because we can't use valid? 
          # it will reset the errors, and run through all validations 
          @delivery_entry.reload 
          @delivery_entry.errors.size.should_not == 0
          
          #  fuck, not fail..
          @delivery.finalize(@admin)
          @delivery.reload 
          @delivery.is_finalized.should be_false 
        end
        
        it 'should finalize if everything is normal' do
          @quantity_confirmed =   @delivery_entry.quantity_sent  
          @delivery_entry.update_post_delivery(@admin, {
            :quantity_confirmed => @quantity_confirmed , 
            :quantity_confirmed_weight =>  "#{@quantity_confirmed*10 }", 
            :quantity_returned => 0 ,
            :quantity_returned_weight => '0' ,
            :quantity_lost => 0 
          })
          
          
          @delivery_entry.errors.size.should == 0
         
          @delivery_entry.reload 
          
          @delivery_entry.quantity_confirmed.should == @quantity_confirmed
          @delivery_entry.quantity_returned.should == 0
          @delivery_entry.quantity_lost.should == 0
          
          @delivery.reload 
          @delivery.finalize(@admin)
          @delivery.reload 
          @delivery.is_finalized.should be_true 
         
        end
        
         
         
        context "FINALIZE: confirm all" do
          before(:each) do
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
            @has_production_sales_item.reload 
            @template_sales_item.reload
          end 
          
          it 'should finalize the delivery' do
            @delivery.is_finalized.should be_true 
          end
          
          it 'should increase the fulfilled quantity by the quantity on_delivery ' do
            @final_on_delivery_item = @has_production_sales_item.on_delivery 
            @delivery_entry.reload 
           
            delta = @initial_on_delivery_item - @final_on_delivery_item
            delta.should == @quantity_confirmed
          end
          
          it 'should not deduct the quantity of fulfilled order: optimistic!' do
            puts "Gonna call the fulfilled order\n"*10
            @final_fulfilled = @has_production_sales_item.fulfilled_post_production
            
            delta = @final_fulfilled - @initial_fulfilled
            puts "The final fulfilled: #{@final_fulfilled}"
            delta.should == 0 
            
          end 
        end # end of "confirm all"

        context "FINALIZE: confirm partial, return partial" do
          before(:each) do
            # puts "\n"
            # puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@ The starting of partial confirmed and partial return\n "*10
            # 
            # puts "The quantity sent: #{@delivery_entry.quantity_sent}\n"*5
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
            @initial_fulfilled = @has_production_sales_item.fulfilled_post_production
            
            
            @delivery.reload 
            @delivery.finalize(@admin)
            @delivery.reload
            
            # @delivery.finalize(@admin)  
            @has_production_sales_item.reload 
          end 
          
          it 'should finalize the delivery' do
            
            @delivery.is_finalized.should be_true 
          end
          
          it 'should increase the fulfilled quantity by the quantity on_delivery ' do
            
            @final_on_delivery_item = @has_production_sales_item.on_delivery 
            @delivery_entry.reload 
            
            puts "initial_on_delivery_item :#{@initial_on_delivery_item}"
            puts "reload : #{@final_on_delivery_item}"
               
            delta = @initial_on_delivery_item - @final_on_delivery_item  - @quantity_returned
            delta.should == @quantity_confirmed
          end
          
          it 'should deduct the quantity of confirmed item' do
            @final_fulfilled = @has_production_sales_item.fulfilled_post_production
        
            delta = @initial_fulfilled - @final_fulfilled  
            delta.should == @quantity_returned
          end
          
          it 'should create a sales return with the corresponding sales entry' do
            @delivery.has_sales_return?.should be_true 
          end
          
          it 'should have the same number of sales return entries as the returned delivery entries' do
            total_returned_delivery_entries = @delivery.delivery_entries.
                                                  where{( quantity_returned.not_eq 0)}.count 
                                                  
            total_sales_return_entries = @delivery.sales_return.sales_return_entries.count 
            
            total_sales_return_entries.should == total_returned_delivery_entries
          end
          
          # go in detail in sales_return_spec => confirming the sales return, produce the shite 
        end # end of "confirm partial, return partial"
        
        
        context "non generic: only lost delivery and delivery lost" do
          before(:each) do
            puts "\n"
            # puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@ The starting of delivery finalize: generic case \n"*10
            
            puts "The quantity sent: #{@delivery_entry.quantity_sent}\n"*5
            @quantity_returned = 0 
            @quantity_lost = 3 
            @quantity_confirmed =   @delivery_entry.quantity_sent - @quantity_returned  - @quantity_lost 
        
            
            @delivery_entry.update_post_delivery(@admin, {
              :quantity_confirmed => @quantity_confirmed , 
              :quantity_confirmed_weight =>  "#{@quantity_confirmed*10 }", 
              :quantity_returned => @quantity_returned ,
              :quantity_returned_weight => "#{@quantity_returned*20}" ,
              :quantity_lost => @quantity_lost  
            }) 
            
            
            @has_production_sales_item.reload 
            @initial_on_delivery_item = @has_production_sales_item.on_delivery 
            @initial_fulfilled = @has_production_sales_item.fulfilled_post_production
            @initial_fulfilled_production = @has_production_sales_item.fulfilled_production
            
            
            @delivery.reload 
            @delivery.finalize(@admin)
            @delivery.reload
            
            # @delivery.finalize(@admin)  
            @has_production_sales_item.reload
            @delivery_lost = @delivery.delivery_lost 
          end
          
          it 'should finalize the delivery' do
            @delivery.is_finalized.should be_true 
          end
          
          it 'should reduce the fulfilled order because of quantity returned and quantity lost' do
            @final_fulfilled = @has_production_sales_item.fulfilled_post_production
            diff = @initial_fulfilled -  @final_fulfilled 
            diff.should == @quantity_lost 
          end
          
          it 'should not change the fulfilled_production' do
            @final_fulfilled_production =  @has_production_sales_item.fulfilled_production
            diff = @final_fulfilled_production - @initial_fulfilled_production
            @initial_fulfilled_production.should == 0 
            @final_fulfilled_production.should == 0 
            diff.should == 0 
            
          end
        
          
          # for LOST DELIVERY SPECIFIC CODE
          
          it 'should generate DeliveryLost with corresponding DeliveryLostEntry' do
            
            @delivery_lost.should be_valid 
          end
          
          it 'should have the same number of delivery_lost_entries as the lost quantity in delivery finalization' do
            total_delivery_lost_entry = @delivery_lost.delivery_lost_entries.count
            total_delivery_entry_with_quantity_lost = @delivery.delivery_entries.where{(quantity_lost.not_eq 0 )}.count 
            
            total_delivery_lost_entry.should == total_delivery_entry_with_quantity_lost
          end
          
        end # "generic_case: with confirmation, sales return and lost delivery"
           
        
        
      end # end of "on delivery confirmation" context
      
    end # context 'creating delivery with 1 delivery entry , including production'
  end
   
end