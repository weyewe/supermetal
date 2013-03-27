class TemplateSalesItem < ActiveRecord::Base
  # attr_accessible :title, :body
  
  has_many :sales_items 
  has_many :sales_item_subcriptions
  has_many :customers, :through => :sales_item_subcriptions 
  has_many :production_orders   # , :post_production_orders
  has_many :pre_production_results
  has_many :production_results
  has_many :production_repair_results
  has_many :post_production_results 
  
  has_many :production_orders
  has_many :production_repair_orders
  has_many :post_production_orders 
  
  has_many :delivery_entries 
  
  validates_presence_of :code 
  
  
  def has_unconfirmed_pre_production_result?
    self.pre_production_results.where(:is_confirmed => false ).count != 0 
  end
  
  
  def has_unconfirmed_production_result?
    self.production_results.where(:is_confirmed => false ).count != 0 
  end
  
  def has_unconfirmed_post_production_result?
    self.post_production_results.where(:is_confirmed => false ).count != 0 
  end
  
  def has_unconfirmed_production_repair_result?
    self.production_repair_results.where(:is_confirmed => false).count != 0 
  end
  
  def self.create_based_on_sales_item( sales_item )
    new_object = self.new
    new_object.code = sales_item.code 
    new_object.main_sales_item_id = sales_item.id 
    new_object.name = sales_item.name
    new_object.description = sales_item.description
    new_object.weight_per_piece = sales_item.weight_per_piece
    new_object.material_id = sales_item.material_id 
  
    
    if not sales_item.is_production? and sales_item.is_post_production? 
      new_object.is_internal_production  = false 
    elsif sales_item.is_production?  
      new_object.is_internal_production = true 
    end
    
    new_object.save 
    
    return new_object 
  end
  
  def update_from_sales_item(sales_item) 
    self.name = sales_item.name
    self.description = sales_item.description 
    self.weight_per_piece =  sales_item.weight_per_piece
    self.material_id = sales_item.material_id
    self.save 
  end
  
  def confirmed_sales_items
    self.sales_items.where(:is_confirmed => true ).order("created_at ASC")
  end
  
  
  def ok_pre_production
    self.pre_production_results.where(:is_confirmed => true).sum("ok_quantity")
  end
  
  def broken_pre_production
    self.pre_production_results.where(:is_confirmed => true).sum("broken_quantity")
  end
  
  
  def ready_production
    total_quantity_finished = self.production_results.where(:is_confirmed => true ) .sum("ok_quantity") +
                              self.production_repair_results.where(:is_confirmed => true ) .sum("ok_quantity")
     
    total_quantity_going_out = self.delivery_entries.where( 
              :item_condition => DELIVERY_ENTRY_ITEM_CONDITION[:production],  
              :is_confirmed => true,
              :is_finalized => false,
              :is_deleted => false   ).sum("quantity_sent")             
                  
    confirmed_total_quantity_going_out = self.delivery_entries.where(
              :item_condition => DELIVERY_ENTRY_ITEM_CONDITION[:production], 
              :is_confirmed => true,
              :is_finalized => true,
              :is_deleted => false  ).sum("quantity_confirmed")
    
    confirmed_total_quantity_returned =           self.delivery_entries.where(
                        :item_condition => DELIVERY_ENTRY_ITEM_CONDITION[:production], 
                        :is_confirmed => true,
                        :is_finalized => true,
                        :is_deleted => false  ).sum("quantity_returned")
                        
    confirmed_total_quantity_lost =                     self.delivery_entries.where(
                                  :item_condition => DELIVERY_ENTRY_ITEM_CONDITION[:production], 
                                  :is_confirmed => true,
                                  :is_finalized => true,
                                  :is_deleted => false  ).sum("quantity_lost")
                                  
    # deduct with the quantity being post produced: success or fail
    
    confirmed_total_quantity_used_for_post_production = self.post_production_results.where(
      :is_confirmed => true
    ).sum("processed_quantity")
              
    total_quantity_finished - total_quantity_going_out - confirmed_total_quantity_going_out - 
                confirmed_total_quantity_returned - confirmed_total_quantity_lost - confirmed_total_quantity_used_for_post_production
  end
  
  def ready_post_production
    return ready_post_production_only_post_production if not self.is_internal_production
    total_quantity_finished = self.post_production_results.where(:is_confirmed => true ) .sum("ok_quantity") 
     
    total_quantity_going_out = self.delivery_entries.where(
              :item_condition => DELIVERY_ENTRY_ITEM_CONDITION[:post_production], 
              :is_confirmed => true,
              :is_finalized => false,
              :is_deleted => false  ).sum("quantity_sent")     
              
    confirmed_total_quantity_going_out = self.delivery_entries.where(
              :item_condition => DELIVERY_ENTRY_ITEM_CONDITION[:post_production], 
              :is_confirmed => true,
              :is_finalized => true,
              :is_deleted => false  ).sum("quantity_confirmed")       
              
     confirmed_total_quantity_returned =           self.delivery_entries.where(
                        :item_condition => DELIVERY_ENTRY_ITEM_CONDITION[:post_production], 
                        :is_confirmed => true,
                        :is_finalized => true,
                        :is_deleted => false ).sum("quantity_returned")

    confirmed_total_quantity_lost =                     self.delivery_entries.where(
                                  :item_condition => DELIVERY_ENTRY_ITEM_CONDITION[:post_production], 
                                  :is_confirmed => true,
                                  :is_finalized => true,
                                  :is_deleted => false ).sum("quantity_lost")     
    
    total_quantity_finished - total_quantity_going_out - confirmed_total_quantity_going_out                               - 
                      confirmed_total_quantity_returned - confirmed_total_quantity_lost
  end
  
  
  def pending_production
    return 0 if not self.is_internal_production
    total_quantity_ordered = self.production_orders.sum("quantity") 
    total_quantity_finished = self.production_results.where(:is_confirmed => true ) .sum("processed_quantity")  
                                
    
    total_quantity_ordered - total_quantity_finished
  end
  
  def pending_production_repair
    return 0 if not self.is_internal_production
    total_quantity_ordered = self.production_repair_orders.sum("quantity") 
    total_quantity_finished = self.production_repair_results.where(:is_confirmed => true ) .sum("processed_quantity")
    
    total_quantity_ordered - total_quantity_finished 
  end
  
  def pending_post_production
    return pending_post_production_only_post_production if not self.is_internal_production
    
    total_quantity_ordered = self.post_production_orders.sum("quantity") 
    total_quantity_finished = self.post_production_results.where(:is_confirmed => true ) .sum("ok_quantity")
    
    
    
    total_quantity_ordered - total_quantity_finished
  end
  
###################################################
###################################################
################# =>    Only Post Production 
###################################################
###################################################
  def pending_delivery_bad_source
    return 0 if  self.is_internal_production
    template_sales_item_id = self.id 
    total_bad_source = self.post_production_results.where(:is_confirmed => true ) .sum('bad_source_quantity')
 
    
    delivery =   DeliveryEntry.joins(:sales_item).where(
          :sales_item => {
            :template_sales_item_id => template_sales_item_id
          },
          :is_confirmed => true,
          :is_finalized => false ,
          :entry_case => DELIVERY_ENTRY_CASE[:bad_source_fail_post_production],
          :item_condition =>  DELIVERY_ENTRY_ITEM_CONDITION[:post_production],
          :is_deleted => false
        ).sum('quantity_sent')
    
    confirmed_delivery = DeliveryEntry.joins(:sales_item).where(
        :sales_item => {
          :template_sales_item_id => template_sales_item_id
        },
        :is_confirmed => true,
        :is_finalized => true ,
        :entry_case => DELIVERY_ENTRY_CASE[:bad_source_fail_post_production],
        :item_condition =>  DELIVERY_ENTRY_ITEM_CONDITION[:post_production],
        :is_deleted => false
      ).sum('quantity_confirmed')
      
    
    
    quantity_lost = DeliveryEntry.joins(:sales_item).where(
        :sales_item => {
          :template_sales_item_id => template_sales_item_id
        },
        :is_confirmed => true,
        :is_finalized => false ,
        :entry_case => DELIVERY_ENTRY_CASE[:bad_source_fail_post_production],
        :item_condition =>  DELIVERY_ENTRY_ITEM_CONDITION[:post_production],
        :is_deleted => false
      ).sum('quantity_lost')
      
    confirmed_quantity_lost = DeliveryEntry.joins(:sales_item).where(
        :sales_item => {
          :template_sales_item_id => template_sales_item_id
        },
        :is_confirmed => true,
        :is_finalized => true ,
        :entry_case => DELIVERY_ENTRY_CASE[:bad_source_fail_post_production],
        :item_condition =>  DELIVERY_ENTRY_ITEM_CONDITION[:post_production],
        :is_deleted => false
      ).sum('quantity_lost')
      
    total_bad_source_delivered =  delivery +   confirmed_delivery + quantity_lost + confirmed_quantity_lost
    
    
    
    total_bad_source - total_bad_source_delivered
  end
  
  def pending_delivery_broken_quantity # pending delivery 
    return 0 if  self.is_internal_production
    template_sales_item_id = self.id 
    total_broken_quantity = self.post_production_results.where(:is_confirmed => true ) .sum('broken_quantity')
    quantity_sent =  DeliveryEntry.joins(:sales_item).where(
      :sales_item => {
        :template_sales_item_id => template_sales_item_id
      },
      :is_confirmed => true,
      :is_finalized => false ,
      :entry_case => DELIVERY_ENTRY_CASE[:technical_failure_post_production],
      :item_condition =>  DELIVERY_ENTRY_ITEM_CONDITION[:post_production],
      :is_deleted => false
    ).sum('quantity_sent')
    
    quantity_confirmed = DeliveryEntry.joins(:sales_item).where(
        :sales_item => {
          :template_sales_item_id => template_sales_item_id
        },
        :is_confirmed => true,
        :is_finalized => true  ,
        :entry_case => DELIVERY_ENTRY_CASE[:technical_failure_post_production],
        :item_condition =>  DELIVERY_ENTRY_ITEM_CONDITION[:post_production],
        :is_deleted => false
      ).sum('quantity_confirmed')
    
    quantity_lost = DeliveryEntry.joins(:sales_item).where(
        :sales_item => {
          :template_sales_item_id => template_sales_item_id
        },
        :is_confirmed => true,
        :is_finalized => true  ,
        :entry_case => DELIVERY_ENTRY_CASE[:technical_failure_post_production],
        :item_condition =>  DELIVERY_ENTRY_ITEM_CONDITION[:post_production],
        :is_deleted => false
      ).sum('quantity_lost')
          
    total_broken_quantity_delivered =  quantity_sent + quantity_confirmed + quantity_lost 
    
    return total_broken_quantity - total_broken_quantity_delivered
  end
  
  def pending_post_production_only_post_production
    return 0 if  self.is_internal_production
    
    # even if it fails, consider it as worked 
    
    total_quantity_ordered = self.post_production_orders.sum("quantity") 
    total_quantity_finished = self.post_production_results.
                                  where(:is_confirmed => true ).
                                  sum("processed_quantity")
    
    total_quantity_ordered - total_quantity_finished
  end
  
  
  def ready_post_production_only_post_production
    return 0 if  self.is_internal_production
    total_quantity_finished = self.post_production_results.
                                  where(:is_confirmed => true ).
                                  sum("ok_quantity")
    
    template_sales_item_id = self.id 
    delivery = DeliveryEntry.joins(:sales_item).where(
        :sales_item => {
          :template_sales_item_id => template_sales_item_id
        },
        :is_confirmed => true,
        :is_finalized => true  ,
        :entry_case => DELIVERY_ENTRY_CASE[:normal],
        :item_condition =>  DELIVERY_ENTRY_ITEM_CONDITION[:post_production],
        :is_deleted => false
      ).sum('quantity_sent')
      
    
    confirmed_delivery = DeliveryEntry.joins(:sales_item).where(
        :sales_item => {
          :template_sales_item_id => template_sales_item_id
        },
        :is_confirmed => true,
        :is_finalized => true  ,
        :entry_case => DELIVERY_ENTRY_CASE[:normal],
        :item_condition =>  DELIVERY_ENTRY_ITEM_CONDITION[:post_production],
        :is_deleted => false
      ).sum('quantity_confirmed')
    
    total_quantity_finished - confirmed_delivery - confirmed_delivery
  end
   
  
  def item_receival_ready_for_post_production
    puts "gonna return shite as 0"
    return 0 if   self.is_internal_production
    puts "not returning the shite as 0"
    
    sales_item_id_list = self.sales_items.map{|x| x.id }
    template_sales_item_id = self.id 
    total_quantity_received = ItemReceivalEntry.joins(:sales_item).where(
              :sales_item => {
                :template_sales_item_id => template_sales_item_id
              },
              :is_confirmed => true 
              ).sum('quantity')
              
    puts "Totalquantity received: #{total_quantity_received}"
    total_quantity_worked = self.post_production_results.where(:is_confirmed => true).sum('processed_quantity')
    puts "number of confirmed post production result: #{self.post_production_results.where(:is_confirmed => true).count}"
    puts "Total quantity worked: #{total_quantity_worked}"
    total_quantity_received - total_quantity_worked
  end
  
  
  def total_guarantee_return
    template_sales_item_id = self.id 
    production = GuaranteeReturnEntry.joins(:sales_item).where(
      :sales_item => {
        :template_sales_item_id => template_sales_item_id
      },
      :is_confirmed => true 
    ).sum("quantity_for_production")
    
    post_production = GuaranteeReturnEntry.joins(:sales_item).where(
      :sales_item => {
        :template_sales_item_id => template_sales_item_id
      },
      :is_confirmed => true 
    ).sum("quantity_for_post_production")
    
    production_repair = GuaranteeReturnEntry.joins(:sales_item).where(
      :sales_item => {
        :template_sales_item_id => template_sales_item_id
      },
      :is_confirmed => true 
    ).sum("quantity_for_production_repair")
    
    return production + post_production + production_repair
  end
  
  def delivered_guarantee_return
    
    template_sales_item_id = self.id 
    unfinalized = DeliveryEntry.joins(:sales_item).where(
      :sales_item => {
        :template_sales_item_id => template_sales_item_id
      },
      :is_confirmed => true ,
      :is_finalized => false , 
      :entry_case => DELIVERY_ENTRY_CASE[:guarantee_return],
      :is_deleted => false
    ).sum("quantity_sent")
    
    finalized = DeliveryEntry.joins(:sales_item).where(
      :sales_item => {
        :template_sales_item_id => template_sales_item_id
      },
      :is_confirmed => true ,
      :is_finalized => true , 
      :entry_case => DELIVERY_ENTRY_CASE[:guarantee_return],
      :is_deleted => false
    ).sum("quantity_confirmed")
    
    return unfinalized + finalized 
  end
  
  # the guarantee return that is not returned yet 
  def pending_guarantee_return
    total_guarantee_return - delivered_guarantee_return 
  end
  

###################################################
###################################################
################# =>    Only Post Production 
###################################################
###################################################
  def on_delivery
    template_sales_item_id=  self.id 
    items_on_delivery = DeliveryEntry.joins(:sales_item).where(
        :sales_item => {
          :template_sales_item_id => template_sales_item_id
        },
        :is_confirmed => true,
        :is_finalized => false ,
        :is_deleted => false
      ).sum('quantity_sent')
      
    return items_on_delivery
  end
  
  def customers_name
    self.customers.map{|x| x.name}.join(", ")
  end
end
