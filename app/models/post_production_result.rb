class PostProductionResult < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :template_sales_item
   
  validates_presence_of   :ok_quantity,  :broken_quantity, :bad_source_quantity, 
                          :ok_weight,   :broken_weight,   :bad_source_weight ,  
                          :started_at, :finished_at, :template_sales_item_id 
                          
  validates_numericality_of :ok_quantity, :broken_quantity  ,  :bad_source_quantity, 
                          :ok_weight, :broken_weight    , :bad_source_weight         
                  
   
  validate :no_all_zero_quantity
  validate :no_negative_quantity
  validate :no_negative_weight
  validate :prevent_zero_weight_for_non_zero_quantity
  validate  :prevent_excess_post_production

   

  def no_all_zero_quantity
    if  ok_quantity.present? and broken_quantity.present? and bad_source_quantity.present? and 
        ok_quantity == 0  and  broken_quantity == 0   and bad_source_quantity == 0 
      errors.add(:ok_quantity , "OK, gagal, dan perbaiki tidak boleh bernilai 0 bersamaan" ) 
      errors.add(:broken_quantity , "OK, gagal, dan perbaiki tidak boleh bernilai 0 bersamaan" )   
      errors.add(:bad_source_quantity , "OK, gagal, dan perbaiki tidak boleh bernilai 0 bersamaan" )   
    end
  end
  
  def no_negative_quantity
    if ok_quantity.present? and ok_quantity < 0 
      errors.add(:ok_quantity , "Kuantitas tidak boleh lebih kecil dari 0" ) 
    end
    
    if broken_quantity.present? and  broken_quantity <0 
      errors.add(:broken_quantity , "Kuantitas tidak boleh lebih kecil dari 0" )   
    end 
    
    if bad_source_quantity.present? and  bad_source_quantity <0 
      errors.add(:bad_source_quantity , "Kuantitas tidak boleh lebih kecil dari 0" )   
    end
    
  
  end
  
  def no_negative_weight
    if ok_weight.present? and ok_weight < BigDecimal('0')
      errors.add(:ok_weight , "Berat tidak boleh negative" ) 
    end
    
    if broken_weight.present? and  broken_weight < BigDecimal('0')
      errors.add(:broken_weight , "Berat tidak boleh negative" )   
    end
    
    if bad_source_weight.present? and  bad_source_weight < BigDecimal('0')
      errors.add(:bad_source_weight , "Berat tidak boleh negative" )   
    end
  
  end
  
  def prevent_zero_weight_for_non_zero_quantity
    if ok_quantity.present? and ok_weight.present? and ok_quantity > 0 and ok_weight <= BigDecimal('0')
      errors.add(:ok_weight , "Berat tidak boleh 0 jika kuantity > 0 " ) 
    end
    
    if broken_quantity.present? and broken_weight.present? and broken_quantity >  0  and broken_weight <=  BigDecimal('0')
      errors.add(:broken_weight , "Berat tidak boleh 0 jika kuantity > 0 " )   
    end
    
    if bad_source_quantity.present? and bad_source_weight.present? and bad_source_quantity >  0  and bad_source_weight <=  BigDecimal('0')
      errors.add(:bad_source_weight , "Berat tidak boleh 0 jika kuantity > 0 " )   
    end
  end
  
  def prevent_excess_post_production
    template_sales_item = self.template_sales_item 
    pending_post_production = 0 
    if template_sales_item.is_internal_production
      pending_post_production = template_sales_item.pending_post_production 
    else
      pending_post_production = template_sales_item.pending_post_production_only_post_production 
    end
    
    # puts "pending post production from validation: #{pending_post_production}"
    
    if ok_quantity.present? and broken_quantity.present? and bad_source_quantity.present?  and 
          ( ok_quantity + broken_quantity + bad_source_quantity > pending_post_production  ) 
      err_msg = "Jumlah kuantitas oK, gagal, dan kuantitas rusak tidak boleh lebih dari #{pending_post_production}"
      errors.add(:ok_quantity         , err_msg)   
      errors.add(:broken_quantity     , err_msg)
      errors.add(:bad_source_quantity , err_msg)
    end
  end
  
 
  
  
  
  def self.create_result( employee,  params) 
    return nil if employee.nil?   
    return nil if params[:template_sales_item_id].nil?
    template_sales_item = TemplateSalesItem.find_by_id params[:template_sales_item_id]
    return nil if template_sales_item.has_unconfirmed_post_production_result? 
    
    new_object  = self.new
    new_object.template_sales_item_id = template_sales_item.id 
     
  
    
    new_object.ok_quantity         = params[:ok_quantity]
    new_object.broken_quantity     = params[:broken_quantity] 
    new_object.bad_source_quantity = params[:bad_source_quantity] 
    
     
    
    new_object.ok_weight           = BigDecimal( params[:ok_weight]           )
    new_object.broken_weight       = BigDecimal( params[:broken_weight]       )
    new_object.bad_source_weight   = BigDecimal( params[:bad_source_weight]   )


    new_object.started_at          = params[:started_at] 
    new_object.finished_at         = params[:finished_at] 

    
    if new_object.save   
    end
    
   
    
    return new_object 
  end
  
  def update_result( employee, params ) 
    return nil if employee.nil?   
    if self.is_confirmed? 
      self.post_confirm_update(employee,  params ) 
      return self
    end
    
    
    
    self.creator_id          = employee.id
    self.ok_quantity         = params[:ok_quantity]
    self.broken_quantity     = params[:broken_quantity]  
    self.bad_source_quantity = params[:bad_source_quantity] 
    
    self.ok_weight           = BigDecimal( params[:ok_weight]         )
    self.broken_weight       = BigDecimal( params[:broken_weight]     )
    self.bad_source_weight   = BigDecimal( params[:bad_source_weight] )


    
    self.started_at         =  params[:started_at]
    self.finished_at        =  params[:finished_at]

    if self.save  
      # new_object.update_processed_quantity 
      # sales_item.update_pre_production_statistics 
    end
    
    return self 
  end
  
  
  def post_confirm_update(employee,  params ) 
    self.creator_id = employee.id 
    self.ok_quantity         = params[:ok_quantity]
    self.bad_source_quantity = params[:bad_source_quantity]
    self.broken_quantity     = params[:broken_quantity] 
    self.ok_weight           = BigDecimal( params[:ok_weight]         )
    self.bad_source_weight   = BigDecimal( params[:bad_source_weight] )
    self.broken_weight       = BigDecimal( params[:broken_weight]     )
    self.started_at          = params[:started_at] 
    self.finished_at         = params[:finished_at]
    
    if self.save 
      ActiveRecord::Base.transaction do
        update_processed_quantity
        if self.template_sales_item.is_internal_production? 
          update_bad_source_production_order
          update_technical_failure_production_order
        end
        
      end
    end
    
    return self 
  end
  
  def update_bad_source_production_order
    bad_source_production_order = ProductionOrder.where(
      :template_sales_item_id => self.template_sales_item_id, 
      :source_document_entry =>  self.class.to_s,
      :source_document_entry_id => self.id ,
      :case                     => PRODUCTION_ORDER[:post_production_failure_bad_source]    
    ).first
    
    if self.bad_source_quantity == 0 and  not bad_source_production_order.nil? 
      bad_source_production_order.destroy 
    elsif self.bad_source_quantity != 0 and  not bad_source_production_order.nil? 
      bad_source_production_order.quantity = self.bad_source_quantity
      bad_source_production_order.save 
    elsif self.bad_source_quantity != 0 and bad_source_production_order.nil? 
      ProductionOrder.generate_post_production_bad_source_failure_production_order( self )
    end
  end
  
  def update_technical_failure_production_order
    technical_failure_production_order = ProductionOrder.where(
      :template_sales_item_id => self.template_sales_item_id, 
      :source_document_entry =>  self.class.to_s,
      :source_document_entry_id => self.id ,
      :case                     => PRODUCTION_ORDER[:post_production_failure_technical_failure]   
    ).first
    
    if self.broken_quantity == 0 and  not technical_failure_production_order.nil? 
      technical_failure_production_order.destroy 
    elsif self.broken_quantity != 0 and  not technical_failure_production_order.nil? 
      technical_failure_production_order.quantity = self.broken_quantity
      technical_failure_production_order.save 
    elsif self.broken_quantity != 0 and technical_failure_production_order.nil? 
      ProductionOrder.generate_post_production_technical_failure_production_order( self )
    end
  end
  
  
  
  def delete(employee)
    return nil if employee.nil?
    return nil if self.is_confirmed == true 
    
    self.destroy if self.is_confirmed == false 
  end
  
  
  def update_processed_quantity 
    # puts "3321 we are in update processed quantity\n"*10
    self.processed_quantity = self.ok_quantity  + 
                                  self.broken_quantity + self.bad_source_quantity 
    self.save
  end
  
  def quantity_to_be_reproduced
    if self.is_internal_production?
      self.broken_quantity + self.bad_source_quantity 
    else
      0  # hey, it is external goods. we don't know how to cast it. 
    end
  end
  
   
  
  
  def confirm( employee )
    return nil if employee.nil? 
    return nil if self.is_confirmed == true 
    
    ActiveRecord::Base.transaction do
      
      
      self.is_confirmed = true 
      self.confirmer_id = employee.id
      self.confirmed_at = DateTime.now 
      self.save
      self.update_processed_quantity
      if  self.errors.size != 0  
        raise ActiveRecord::Rollback, "Call tech support!" 
      end
       
       
      if self.template_sales_item.is_internal_production? 
        
      
        if self.bad_source_quantity != 0 
          # create production order 
          ProductionOrder.generate_post_production_bad_source_failure_production_order( self )
        end
        
        if self.broken_quantity != 0 
          # create production order 
          ProductionOrder.generate_post_production_technical_failure_production_order( self )
        end
      else
        # don't create anything. we cant create it inhouse anyway 
      end 
    end
    
  end 
  
  
  def is_a_number?(s)
    s.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true 
  end
  
end
