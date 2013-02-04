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
  
  def self.create_based_on_sales_item( sales_item )
    new_object = self.new
    new_object.code = sales_item.code 
  
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
    total_quantity_finished = self.production_repair_results.where(:is_confirmed => true ) .sum("ok_quantity")
    
    total_quantity_ordered - total_quantity_finished 
  end
  
  def pending_post_production
    total_quantity_ordered = self.post_production_orders.sum("quantity") 
    total_quantity_finished = self.post_production_results.where(:is_confirmed => true ) .sum("ok_quantity")
    
    total_quantity_ordered - total_quantity_finished
  end
  
  
end
