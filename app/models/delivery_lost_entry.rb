class DeliveryLostEntry < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :sales_item 
  belongs_to :delivery_entry 
  belongs_to :delivery_lost
  
  def DeliveryLostEntry.create_by_employee( employee, delivery_lost, delivery_entry)
    
    new_object = DeliveryLostEntry.new 
    new_object.creator_id = employee.id 
    new_object.delivery_entry_id = delivery_entry.id 
    new_object.delivery_lost_id  = delivery_lost.id  
    
    if new_object.save 
    end
    
    return new_object
  end
  
  def quantity_lost
    self.delivery_entry.quantity_lost
  end
  
  def confirm
    
    sales_item = self.delivery_entry.sales_item 
    
    self.is_confirmed = true 
    self.save 
    
    self.generate_work_order
    
  end
  
  def delete(employee)
    self.delete_related_work_order
    self.destroy 
  end
  
  def generate_work_order
    delivery_entry = self.delivery_entry 
    if delivery_entry.entry_case == DELIVERY_ENTRY_CASE[:normal]
      if delivery_entry.item_condition == DELIVERY_ENTRY_ITEM_CONDITION[:production]
        ProductionOrder.generate_delivery_lost_production_order( self  )
      elsif delivery_entry.item_condition == DELIVERY_ENTRY_ITEM_CONDITION[:post_production]
        ProductionOrder.generate_delivery_lost_production_order( self  )
        PostProductionOrder.generate_delivery_lost_production_order( self  )
      end
    elsif delivery_entry.entry_case == DELIVERY_ENTRY_CASE[:premature]
      if delivery_entry.item_condition == DELIVERY_ENTRY_ITEM_CONDITION[:production]
        ProductionOrder.generate_delivery_lost_production_order( self  )
      end
    elsif delivery_entry.entry_case == DELIVERY_ENTRY_CASE[:guarantee_return]
      if delivery_entry.item_condition == DELIVERY_ENTRY_ITEM_CONDITION[:production]
        ProductionOrder.generate_delivery_lost_production_order( self  )
      elsif delivery_entry.item_condition == DELIVERY_ENTRY_ITEM_CONDITION[:post_production]
        ProductionOrder.generate_delivery_lost_production_order( self  )
        PostProductionOrder.generate_delivery_lost_production_order( self  )
      end
    else
      # it must be only post production:
      # 1. bad source, 2. technical failure, 3. cancel post production only 
      # in either case, we don't need to create production order 
    end
  end
  
  def post_confirm_update 
    delivery_entry = self.delivery_entry 
    delivery_lost_entry = self 
    
    
    self.delete_related_work_order
    
    self.generate_work_order
  end
  
  def delete_related_work_order
    ProductionOrder.where( 
      :case                     => PRODUCTION_ORDER[:delivery_lost]     ,
      :source_document_entry    => delivery_lost_entry.class.to_s          ,
      :source_document_entry_id => delivery_lost_entry.id   
    ).each do |x|
      x.destroy 
    end 
    
    PostProductionOrder.create(
      :case                     =>  POST_PRODUCTION_ORDER[:delivery_lost]  ,
      :source_document_entry    => delivery_lost_entry.class.to_s          ,
      :source_document_entry_id => delivery_lost_entry.id       
    ).each do |x|
      x.destroy 
    end
  end
end
