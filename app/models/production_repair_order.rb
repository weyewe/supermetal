class ProductionRepairOrder < ActiveRecord::Base
  attr_accessible :sales_item_subcription_id, :template_sales_item_id, 
                  :case, :quantity,
                  :source_document_entry, :source_document_entry_id,
                  :source_document, :source_document_id
                  
   
  belongs_to :template_sales_item
  
  def self.create_repairable_production_repair_order( production_result   )
    template_sales_item = production_result.template_sales_item 
      self.create(
        :template_sales_item_id    => production_result.template_sales_item_id  , 

        :case                     => PRODUCTION_REPAIR_ORDER[:production_repair] ,
        :quantity                 => production_result.repairable_quantity  ,
        # no document entry. it is just doing repair per normal 
        :source_document_entry    => production_result.class.to_s  , 
        :source_document_entry_id => production_result.id  , 
        :source_document          => production_result.class.to_s  , 
        :source_document_id       => production_result.id 
      )
  end
  
 
  
   
  
  def self.generate_sales_return_production_repair_order( sales_return_entry )
    # puts "We are inside the production order\n"*10
    # return nil if post_production_history.broken_quantity == 0 
    return nil if sales_return_entry.nil? 
    quantity = sales_return_entry.quantity_for_production_repair
    return nil if quantity == 0  
    template_sales_item = sales_return_entry.sales_item.template_sales_item 
    
    self.create(
      :template_sales_item_id    => template_sales_item.id   ,
      
      :case                     => PRODUCTION_REPAIR_ORDER[:sales_return]     ,
      :quantity                 =>  quantity    ,
      :source_document_entry    => sales_return_entry.class.to_s          ,
      :source_document_entry_id => sales_return_entry.id                  ,
      :source_document          => sales_return_entry.sales_return.class.to_s          ,
      :source_document_id       => sales_return_entry.sales_return.id  
    ) 
  end
  
  
   
  
  
  def self.generate_guarantee_return_production_repair_order( guarantee_return_entry )
    
    return nil if guarantee_return_entry.nil? 
    quantity = guarantee_return_entry.quantity_for_production_repair
    return nil if quantity == 0  
    template_sales_item = guarantee_return_entry.sales_item.template_sales_item
    
     
    
    self.create(
      :template_sales_item_id    => template_sales_item.id   ,
      
      :case                     => PRODUCTION_REPAIR_ORDER[:guarantee_return]     ,
      :quantity                 =>  quantity    ,
      :source_document_entry    => guarantee_return_entry.class.to_s          ,
      :source_document_entry_id => guarantee_return_entry.id                  ,
      :source_document          => guarantee_return_entry.guarantee_return.class.to_s          ,
      :source_document_id       => guarantee_return_entry.guarantee_return.id  
    )
     
  end
end
