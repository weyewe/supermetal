class PostProductionOrder < ActiveRecord::Base
  attr_accessible :case, :quantity, 
                  :source_document_entry, :source_document_entry_id,
                  :source_document, :source_document_id,
                  :template_sales_item_id
                  
  belongs_to :sales_item 
  
  # def PostProductionOrder.create_machining_only_sales_production_order( sales_item )
  #   PostProductionOrder.create(
  #     :sales_item_id            => sales_item.id                                               , 
  #     :case                     =>  POST_PRODUCTION_ORDER[:sales_order_only_post_production]   ,
  #     :quantity                 => sales_item.quantity                                         ,
  #     :source_document_entry    => sales_item.class.to_s                                       ,
  #     :source_document_entry_id => sales_item.id                                               ,
  #     :source_document          => sales_item.sales_order.class.to_s                           ,
  #     :source_document_id       => sales_item.sales_order_id 
  #   ) 
  # end
  
  
  def PostProductionOrder.generate_sales_post_production_order( sales_item ) 
    return nil if sales_item.quantity_for_post_production == 0 
    template_sales_item = sales_item.template_sales_item
    PostProductionOrder.create(
      :template_sales_item_id            => template_sales_item.id       ,
      :case                     =>  POST_PRODUCTION_ORDER[:sales_order]  ,
      :quantity                 => sales_item.quantity_for_post_production  ,
      :source_document_entry    => sales_item.class.to_s         ,
      :source_document_entry_id => sales_item.id                 ,
      :source_document          => sales_item.sales_order.class.to_s         ,
      :source_document_id       => sales_item.sales_order.id                 
    )                                                                    
  end
  
  def PostProductionOrder.generate_production_repair_post_production_order( production_history )
    PostProductionOrder.create(
      :sales_item_id            => production_history.sales_item_id      ,
      :case                     =>  POST_PRODUCTION_ORDER[:production_repair]  ,
      :quantity                 => production_history.repairable_quantity, 
      :source_document_entry    => production_history.class.to_s         ,
      :source_document_entry_id => production_history.id                 ,
      :source_document          => production_history.class.to_s         ,
      :source_document_id       => production_history.id                 
    )
  end
  
  def PostProductionOrder.generate_sales_return_repair_post_production_order( sales_return_entry )    
    return nil if sales_return_entry.nil? 
    quantity = sales_return_entry.quantity_for_post_production
    return nil if quantity == 0  
    template_sales_item = sales_return_entry.sales_item.template_sales_item
    
    PostProductionOrder.create(
      :template_sales_item_id => template_sales_item.id , 
      :case                     =>  POST_PRODUCTION_ORDER[:sales_return_repair]  ,
      :quantity                 => sales_return_entry.quantity_for_post_production, 
      :source_document_entry    => sales_return_entry.class.to_s          ,
      :source_document_entry_id => sales_return_entry.id                  ,
      :source_document          => sales_return_entry.sales_return.class.to_s          ,
      :source_document_id       => sales_return_entry.sales_return_id
    )
  end
  
  def PostProductionOrder.generate_delivery_lost_production_order( delivery_lost_entry  )
    return nil if delivery_lost_entry.nil? 
    quantity = delivery_lost_entry.quantity_lost
    return nil if quantity == 0  
    template_sales_item = delivery_lost_entry.delivery_entry.sales_item.template_sales_item 
    PostProductionOrder.create(
      :template_sales_item_id => template_sales_item.id , 
      :case                     =>  POST_PRODUCTION_ORDER[:delivery_lost]  ,
      :quantity                 => delivery_lost_entry.quantity_lost, 
      :source_document_entry    => delivery_lost_entry.class.to_s          ,
      :source_document_entry_id => delivery_lost_entry.id                  ,
      :source_document          => delivery_lost_entry.delivery_lost.class.to_s          ,
      :source_document_id       => delivery_lost_entry.delivery_lost_id 
    )
  end
  
  # item receival : for post production order 
  def PostProductionOrder.generate_item_receival_post_production_order( item_receival_entry )
    PostProductionOrder.create(
      :sales_item_id            => item_receival_entry.sales_item_id      ,
      :case                     =>  POST_PRODUCTION_ORDER[:sales_order_only_post_production]  ,
      :quantity                 => item_receival_entry.quantity, 
      
      :source_document_entry    => item_receival_entry.class.to_s          ,
      :source_document_entry_id => item_receival_entry.id                  ,
      :source_document          => item_receival_entry.item_receival.class.to_s          ,
      :source_document_id       => item_receival_entry.item_receival_id
    )
  end
  
  def PostProductionOrder.generate_guarantee_return_post_production_order( guarantee_return_entry ) 
    return nil if guarantee_return_entry.quantity_for_post_production == 0  
    template_sales_item = guarantee_return_entry.sales_item.template_sales_item 
    PostProductionOrder.create(
      :template_sales_item_id => template_sales_item.id , 
      :case                     =>  POST_PRODUCTION_ORDER[:guarantee_return]  ,
      :quantity                 => guarantee_return_entry.quantity_for_post_production, 
      
      :source_document_entry    => guarantee_return_entry.class.to_s          ,
      :source_document_entry_id => guarantee_return_entry.id                  ,
      :source_document          => guarantee_return_entry.guarantee_return.class.to_s          ,
      :source_document_id       => guarantee_return_entry.guarantee_return_id
    )
  end
  
  
  
  
end
