class ProductionOrder < ActiveRecord::Base
  attr_accessible    :sales_item_subcription_id, :template_sales_item_id, 
                  :case, :quantity,
                  :source_document_entry, :source_document_entry_id,
                  :source_document, :source_document_id
                  
 
  belongs_to :template_sales_item
  
  def ProductionOrder.create_sales_production_order( sales_item  )
    
    # deduce the sales item from document entry 
      ProductionOrder.create(
        :sales_item_subcription_id => sales_item.sales_item_subcription_id , 
        :template_sales_item_id    => sales_item.template_sales_item_id  , 

        :case                     => PRODUCTION_ORDER[:sales_order] ,
        :quantity                 => sales_item.quantity            ,
        :source_document_entry    => sales_item.class.to_s          ,
        :source_document_entry_id => sales_item.id                  ,
        :source_document          => sales_item.sales_order.to_s    ,
        :source_document_id       => sales_item.sales_order_id  
      )
  end
  
  def ProductionOrder.generate_production_failure_production_order( production_result )
    return nil if production_result.broken_quantity == 0  
    ProductionOrder.create(       
      :sales_item_subcription_id =>  nil , 
      :template_sales_item_id    => production_result.template_sales_item_id  ,
      
      :case                     => PRODUCTION_ORDER[:production_failure]     ,
      :quantity                 => production_result.broken_quantity     ,
      :source_document_entry    => production_result.class.to_s          ,
      :source_document_entry_id => production_result.id                  ,
      :source_document          => production_result.class.to_s          ,
      :source_document_id       => production_result.id  
    ) 
  end
  
  
  def ProductionOrder.generate_post_production_bad_source_failure_production_order( post_production_result )
    return nil if post_production_result.bad_source_quantity  == 0 
    ProductionOrder.create( 
      :sales_item_subcription_id => nil, 
      :template_sales_item_id    => post_production_result.template_sales_item_id  ,
      
      :case                     => PRODUCTION_ORDER[:post_production_failure_bad_source]     ,
      :quantity                 => post_production_result.bad_source_quantity     ,
      :source_document_entry    => post_production_result.class.to_s          ,
      :source_document_entry_id => post_production_result.id                  ,
      :source_document          => post_production_result.class.to_s          ,
      :source_document_id       => post_production_result.id  
    ) 
  end
  
  def ProductionOrder.generate_post_production_technical_failure_production_order( post_production_result )
    return nil if post_production_result.broken_quantity  == 0 
    ProductionOrder.create( 
      :sales_item_subcription_id => nil, 
      :template_sales_item_id    => post_production_result.template_sales_item_id  ,
      
      :case                     => PRODUCTION_ORDER[:post_production_failure_technical_failure]     ,
      :quantity                 => post_production_result.broken_quantity     ,
      :source_document_entry    => post_production_result.class.to_s          ,
      :source_document_entry_id => post_production_result.id                  ,
      :source_document          => post_production_result.class.to_s          ,
      :source_document_id       => post_production_result.id  
    ) 
  end
  
  def ProductionOrder.generate_production_repair_failure_production_order( production_repair_result  )
    return nil if production_repair_result.broken_quantity  == 0 
    ProductionOrder.create( 
      :sales_item_subcription_id => nil, 
      :template_sales_item_id    => production_repair_result.template_sales_item_id  ,
      
      :case                     => PRODUCTION_ORDER[:post_production_failure_technical_failure]     ,
      :quantity                 => production_repair_result.broken_quantity     ,
      :source_document_entry    => production_repair_result.class.to_s          ,
      :source_document_entry_id => production_repair_result.id                  ,
      :source_document          => production_repair_result.class.to_s          ,
      :source_document_id       => production_repair_result.id  
    ) 
  end
  
  def ProductionOrder.generate_sales_return_post_production_failure_production_order( post_production_history , quantity)
    # puts "We are inside the production order\n"*10
    # return nil if post_production_history.broken_quantity == 0 
    return nil if quantity == 0 
    sales_item = post_production_history.sales_item 
    ProductionOrder.create(
      :sales_item_id            => sales_item.id       ,
      :sales_item_subcription_id => sales_item.sales_item_subcription_id , 
      :template_sales_item_id    => sales_item.template_sales_item_id  ,
      
      :case                     => PRODUCTION_ORDER[:sales_return_post_production_failure]     ,
      :quantity                 => quantity     ,
      :source_document_entry    => post_production_history.class.to_s          ,
      :source_document_entry_id => post_production_history.id                  ,
      :source_document          => post_production_history.class.to_s          ,
      :source_document_id       => post_production_history.id  
    ) 
  end
  
  
  def ProductionOrder.generate_sales_return_production_order( sales_return_entry )
    return nil if sales_return_entry.quantity_for_production ==0 
    template_sales_item = sales_return_entry.delivery_entry.sales_item.template_sales_item 
    ProductionOrder.create(
      :sales_item_subcription_id =>  nil , 
      :template_sales_item_id    => template_sales_item.id  ,
      
      :case                     => PRODUCTION_ORDER[:sales_return]     ,
      :quantity                 => sales_return_entry.quantity_for_production     ,
      :source_document_entry    => sales_return_entry.class.to_s          ,
      :source_document_entry_id => sales_return_entry.id                  ,
      :source_document          => sales_return_entry.sales_return.class.to_s          ,
      :source_document_id       => sales_return_entry.sales_return_id
    ) 
     
  end
  
  def ProductionOrder.generate_delivery_lost_production_order( delivery_lost_entry  )
    return nil if delivery_lost_entry.quantity_lost == 0 
    # sales_item = delivery_lost_entry.delivery_entry.sales_item
    template_sales_item = delivery_lost_entry.delivery_entry.sales_item.template_sales_item
    ProductionOrder.create(
      # :sales_item_id            =>  sales_item.id       ,
      # :sales_item_subcription_id => sales_item.sales_item_subcription_id , 
      :template_sales_item_id    => template_sales_item.id  ,
      
      :case                     => PRODUCTION_ORDER[:delivery_lost]     ,
      :quantity                 => delivery_lost_entry.quantity_lost     ,
      :source_document_entry    => delivery_lost_entry.class.to_s          ,
      :source_document_entry_id => delivery_lost_entry.id                  ,
      :source_document          => delivery_lost_entry.delivery_lost.class.to_s          ,
      :source_document_id       => delivery_lost_entry.delivery_lost_id
    )
  end
  
  
  def ProductionOrder.generate_guarantee_return_production_order( guarantee_return_entry )
    return nil if guarantee_return_entry.quantity_for_production == 0 
    sales_item = guarantee_return_entry.sales_item
    template_sales_item = sales_item.template_sales_item 
    ProductionOrder.create(
      :sales_item_subcription_id => sales_item.sales_item_subcription_id , 
      :template_sales_item_id    => template_sales_item.id  ,
      
      :case                     => PRODUCTION_ORDER[:guarantee_return]     ,
      :quantity                 => guarantee_return_entry.quantity_for_production     ,
      :source_document_entry    => guarantee_return_entry.class.to_s          ,
      :source_document_entry_id => guarantee_return_entry.id                  ,
      :source_document          => guarantee_return_entry.guarantee_return.class.to_s          ,
      :source_document_id       => guarantee_return_entry.guarantee_return_id
    ) 
     
  end
end
