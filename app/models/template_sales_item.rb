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
  
  validates_presence_of :code 
  
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
  
    if not sales_item.is_production?
      new_object.is_internal_production  = false 
    end
    
    new_object.save 
    
    return new_object 
  end
  
  def confirmed_sales_items
    self.sales_items.where(:is_confirmed => true ).order("created_at ASC")
  end
  
  
  
  def ready_production
    total_quantity_finished = self.production_results.where(:is_confirmed => true ) .sum("ok_quantity") +
                              self.production_repair_results.where(:is_confirmed => true ) .sum("ok_quantity")
     
    total_quantity_going_out = DeliveryEntry.where(:template_sales_item_id => self.id, 
              :entry_case => DELIVERY_ENTRY_ITEM_CONDITION[:production], :is_confirmed => true ).sum("quantity_confirmed")                 
    
    total_quantity_finished - total_quantity_going_out
  end
  
  def ready_post_production
    total_quantity_finished = self.post_production_results.where(:is_confirmed => true ) .sum("ok_quantity") 
     
    total_quantity_going_out = DeliveryEntry.where(:template_sales_item_id => self.id, 
              :item_condition => DELIVERY_ENTRY_ITEM_CONDITION[:post_production], :is_confirmed => true ).sum("quantity_confirmed")                 
    
    total_quantity_finished - total_quantity_going_out
  end
  
  
  def pending_production
    total_quantity_ordered = self.production_orders.sum("quantity") 
    total_quantity_finished = self.production_results.where(:is_confirmed => true ) .sum("processed_quantity")  
                                
    
    total_quantity_ordered - total_quantity_finished
  end
  
  def pending_production_repair
    total_quantity_ordered = self.production_repair_orders.sum("quantity") 
    total_quantity_finished = self.production_repair_results.where(:is_confirmed => true ) .sum("processed_quantity")
    
    total_quantity_ordered - total_quantity_finished 
  end
  
  def pending_post_production
    total_quantity_ordered = self.post_production_orders.sum("quantity") 
    total_quantity_finished = self.post_production_results.where(:is_confirmed => true ) .sum("ok_quantity")
    
    total_quantity_ordered - total_quantity_finished
  end
  
###################################################
###################################################
################# =>    Only Post Production 
###################################################
###################################################
  def pending_bad_source
    return 0 if not self.is_internal_production
    template_sales_item_id = self.id 
    total_bad_source = self.post_production_results.where(:is_confirmed => true ) .sum('bad_source_quantity')
    quantity_sent =  DeliveryEntry.joins(:sales_item).where(
      :sales_item => {
        :template_sales_item_id => template_sales_item_id
      },
      :is_confirmed => true,
      :is_finalized => false 
    ).sum('quantity_sent')
    
    quantity_confirmed = DeliveryEntry.joins(:sales_item).where(
        :sales_item => {
          :template_sales_item_id => template_sales_item_id
        },
        :is_confirmed => true,
        :is_finalized => true 
      ).sum('quantity_confirmed')
    
    quantity_lost = DeliveryEntry.joins(:sales_item).where(
        :sales_item => {
          :template_sales_item_id => template_sales_item_id
        },
        :is_confirmed => true,
        :is_finalized => true 
      ).sum('quantity_lost')
      
    total_bad_source_delivered =  quantity_sent +   quantity_confirmed + quantity_lost 
    
    
    
    total_bad_source - total_bad_source_delivered
  end
  
  def pending_broken_quantity
    return 0 if not self.is_internal_production
    
    total_broken_quantity = self.post_production_results.where(:is_confirmed => true ) .sum('broken_quantity')
    quantity_sent =  DeliveryEntry.joins(:sales_item).where(
      :sales_item => {
        :template_sales_item_id => template_sales_item_id
      },
      :is_confirmed => true,
      :is_finalized => false 
    ).sum('quantity_sent')
    
    quantity_confirmed = DeliveryEntry.joins(:sales_item).where(
        :sales_item => {
          :template_sales_item_id => template_sales_item_id
        },
        :is_confirmed => true,
        :is_finalized => true 
      ).sum('quantity_confirmed')
    
    quantity_lost = DeliveryEntry.joins(:sales_item).where(
        :sales_item => {
          :template_sales_item_id => template_sales_item_id
        },
        :is_confirmed => true,
        :is_finalized => true 
      ).sum('quantity_lost')
      
      
    
    total_broken_quantity_delivered =  quantity_sent + quantity_confirmed + quantity_lost 
    
    total_broken_quantity - total_broken_quantity_delivered
  end
  
  def pending_post_production_only_post_production
    return 0 if not self.is_internal_production
    sales_item_id_list = self.sales_items.map{|x| x.id }
    template_sales_item_id = self.id 
    total_quantity_received = ItemReceivalEntry.joins(:sales_item).where(
              :sales_item => {
                :template_sales_item_id => template_sales_item_id
              },
              :is_confirmed => true 
              ).sum('quantity')
              
    total_quantity_worked = self.post_production_results.where(:is_confirmed => true).sum('processed_quantity')
    
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
      :entry_case => DELIVERY_ENTRY_CASE[:guarantee_return]
    ).sum("quantity_sent")
    
    finalized = DeliveryEntry.joins(:sales_item).where(
      :sales_item => {
        :template_sales_item_id => template_sales_item_id
      },
      :is_confirmed => true ,
      :is_finalized => true , 
      :entry_case => DELIVERY_ENTRY_CASE[:guarantee_return]
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
        :is_finalized => false 
      ).sum('quantity_sent')
  end
  
   

end
