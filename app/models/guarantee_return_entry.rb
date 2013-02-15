class GuaranteeReturnEntry < ActiveRecord::Base
  belongs_to :guarantee_return 
  belongs_to :sales_item 
  
  validates_presence_of :sales_item_id,   :guarantee_return_id, :item_condition, 
                        :quantity_for_production_repair , :quantity_for_post_production, :quantity_for_production,
                        :weight_for_production_repair , :weight_for_post_production, :weight_for_production
  
  
  validate :not_all_quantity_zero
  validate :prevent_negative_quantity 
  validate :prevent_non_synced_quantity_weight
  validate :prevent_excess_guarantee_return
  validate :prevent_production_treatment_for_non_internal_item
  # validate :prevent_extra_service
  
  # validate :returned_quantity_not_exceeding_delivered
  # validate :matching_treatment_for_the_given_item_condition
  
  
  
  def not_all_quantity_zero
    if quantity_for_production_repair.present? and quantity_for_production_repair ==  0  and 
      quantity_for_post_production.present? and quantity_for_post_production == 0 and 
      quantity_for_production.present? and quantity_for_production ==  0
      msg = "Total quantity tidak boleh 0"
      errors.add(:quantity_for_production , msg)
      errors.add(:quantity_for_production_repair , msg)
      errors.add(:quantity_for_post_production , msg) 
    end
  end
  
  def prevent_negative_quantity
    msg = "Tidak boleh lebih kecil dari 0. Setidaknya 0"
    if quantity_for_production_repair.present? and quantity_for_production_repair  < 0
      errors.add(:quantity_for_production_repair , msg)
    end
    
    if quantity_for_production.present? and quantity_for_production < 0 
      errors.add(:quantity_for_production , msg)
    end
    
    if quantity_for_post_production.present? and quantity_for_post_production < 0 
      errors.add(:quantity_for_post_production , msg)
    end
    
    if weight_for_production_repair.present? and weight_for_production_repair < BigDecimal('0')
      errors.add(:weight_for_production_repair , msg)
    end
    
    if weight_for_post_production.present? and weight_for_post_production < BigDecimal('0')
      errors.add(:weight_for_post_production , msg)
    end
    
    if weight_for_production.present? and weight_for_production < BigDecimal('0')
      errors.add(:weight_for_production , msg)
    end
    
  end
  
  def prevent_non_synced_quantity_weight
    if quantity_for_production.present? 
      if quantity_for_production != 0 and weight_for_production == BigDecimal('0')
        errors.add(:weight_for_production , "Tidak boleh 0")
      end
      
      if quantity_for_production == 0 and weight_for_production != BigDecimal('0')
        errors.add(:weight_for_production , "Harus 0, karena kuantitas untuk lebur ulang == 0 ")
      end
    end
    
    if quantity_for_production_repair.present? 
      if quantity_for_production_repair != 0 and weight_for_production_repair == BigDecimal('0')
        errors.add(:weight_for_production_repair , "Tidak boleh 0")
      end
      
      if quantity_for_production_repair == 0 and weight_for_production_repair != BigDecimal('0')
        errors.add(:weight_for_production_repair , "Harus 0, karena kuantitas untuk perbaiki produksi == 0 ")
      end
    end
    
    if quantity_for_post_production.present? 
      if quantity_for_post_production != 0 and weight_for_post_production == BigDecimal('0')
        errors.add(:weight_for_post_production , "Tidak boleh 0")
      end
      
      if quantity_for_post_production == 0 and weight_for_post_production != BigDecimal('0')
        errors.add(:weight_for_post_production , "Harus 0, karena kuantitas untuk lebur ulang == 0 ")
      end
    end
  end
  
  def prevent_excess_guarantee_return 
    return nil if self.sales_item.nil? 
    # don't check this out if it is confirmed 
    return nil if self.is_confirmed ==  true 
    
    # if item coming in is in the form of production 
    if item_condition == GUARANTEE_RETURN_ENTRY_ITEM_CONDITION[:production]
      if  quantity_for_production.present? and quantity_for_production_repair.present? and 
        ( quantity_for_production + quantity_for_production_repair > sales_item.receivable_guarantee_return_normal_production )
      # sales_item.delivered_normal_production
        errors.add(:item_condition , "Maks jumlah lebur ulang dan perbaiki cor tidak boleh lebih dari: #{sales_item.receivable_guarantee_return_normal_production}")
      end
      
      if quantity_for_post_production.present? and quantity_for_post_production !=  0 
        errors.add(:quantity_for_post_production , "Untuk garansi retur hasil cor, tidak bisa perbaiki bubut")
      end
      
      
    elsif item_condition == GUARANTEE_RETURN_ENTRY_ITEM_CONDITION[:post_production]
      # sales_item.delivered_normal_post_production
      if quantity_for_production.present? and quantity_for_post_production.present? and 
           ( quantity_for_production + quantity_for_post_production > sales_item.receivable_guarantee_return_normal_post_production )
      # sales_item.delivered_normal_production
        errors.add(:item_condition , "Maks jumlah lebur ulang dan perbaiki bubut tidak boleh lebih dari: #{sales_item.receivable_guarantee_return_normal_post_production}")
      end
      
      if quantity_for_production_repair.present? and quantity_for_production_repair !=  0 
        errors.add(:quantity_for_production_repair , "Untuk garansi retur hasil bubut, tidak bisa perbaiki cor")
      end
    end
  end
  
  def prevent_production_treatment_for_non_internal_item
    sales_item = self.sales_item
    template_sales_item = sales_item.template_sales_item 
    
    if not template_sales_item.is_internal_production
      msg = "Untuk item hanya bubut, tidak boleh ada peleburan ulang atau perbaikan cor"
      if quantity_for_production.present? and quantity_for_production > 0 
        errors.add(:quantity_for_production , msg)
      end
      
      if quantity_for_production_repair.present? and quantity_for_production_repair > 0 
        errors.add(:quantity_for_production_repair , msg)
      end
    end
  end
  
  # def prevent_extra_service
  #   return nil if self.sales_item.nil? 
  #   
  #   
  #   if sales_item.is_production? and sales_item.is_post_production?
  #     # no production repair 
  #     if ( quantity_for_production_repair.present?  and quantity_for_production_repair > 0 )  
  #       msg = "Tidak menerima perbaiki hasil cor"
  #       errors.add(:quantity_for_production_repair , msg)  
  #       errors.add(:weight_for_production_repair , msg)  
  #     end
  #   end
  #   
  #   if sales_item.is_production? and not sales_item.is_post_production?
  #     # no post production 
  #     if ( quantity_for_post_production.present?  and quantity_for_post_production > 0 )  
  #       msg = "Tidak menerima perbaiki hasil bubut"
  #       errors.add(:quantity_for_post_production , msg)  
  #       errors.add(:weight_for_post_production , msg)  
  #     end
  #   end
  #   
  #   if not sales_item.is_production? and sales_item.is_post_production?
  #     # no production repair  + no production 
  #     
  #     if (quantity_for_production.present? and quantity_for_production > 0 )  
  #       msg = "Tidak menerima lebur ulang"
  #       errors.add(:quantity_for_production , msg)  
  #       errors.add(:weight_for_production , msg)  
  #     end
  #     
  #     if ( quantity_for_production_repair.present? and quantity_for_production_repair > 0 ) or 
  #         ( weight_for_production_repair.present?  and  weight_for_production_repair > BigDecimal('0') ) 
  #       msg = "Tidak menerima  perbaiki cor"
  #       errors.add(:quantity_for_production_repair , msg)  
  #       errors.add(:weight_for_production_repair , msg)  
  #     end
  #   end
  # end

  def self.create_guarantee_return_entry( employee, guarantee_return,  params ) 
    return nil if employee.nil?
    
    new_object                                = self.new
    new_object.creator_id                     = employee.id 
    new_object.guarantee_return_id            = guarantee_return.id 
    new_object.sales_item_id                  = params[:sales_item_id] 
    new_object.quantity_for_post_production   = params[:quantity_for_post_production]      
    new_object.quantity_for_production        = params[:quantity_for_production]
    new_object.quantity_for_production_repair = params[:quantity_for_production_repair]
    new_object.weight_for_post_production     = BigDecimal( params[:weight_for_post_production] )     
    new_object.weight_for_production          = BigDecimal( params[:weight_for_production] ) 
    new_object.weight_for_production_repair   = BigDecimal( params[:weight_for_production_repair] )
    new_object.item_condition                 = params[:item_condition]
    
    if new_object.save 
      new_object.generate_code 
    end
    
    return new_object 
  end
  
  def update_guarantee_return_entry( employee, guarantee_return,  params ) 
    return nil if employee.nil?
    if self.is_confirmed?
      self.post_confirm_update(employee, guarantee_return, params)
      return self 
    end
    
   
    self.creator_id                     = employee.id 
    self.guarantee_return_id            = guarantee_return.id 
    self.sales_item_id                  = params[:sales_item_id] 
    self.quantity_for_post_production   = params[:quantity_for_post_production]      
    self.quantity_for_production        = params[:quantity_for_production]
    self.quantity_for_production_repair = params[:quantity_for_production_repair]
    self.weight_for_post_production     = BigDecimal( params[:weight_for_post_production] )     
    self.weight_for_production          = BigDecimal( params[:weight_for_production] )
    self.weight_for_production_repair   = BigDecimal( params[:weight_for_production_repair] )
    self.item_condition                 = params[:item_condition]
    if self.save 
    end
    
    return self 
  end
  
  def post_confirm_update(employee, guarantee_return, params)
    self.quantity_for_post_production   = params[:quantity_for_post_production]      
    self.quantity_for_production        = params[:quantity_for_production]
    self.quantity_for_production_repair = params[:quantity_for_production_repair]
    self.weight_for_post_production     = BigDecimal( params[:weight_for_post_production] )     
    self.weight_for_production          = BigDecimal( params[:weight_for_production] )
    self.weight_for_production_repair   = BigDecimal( params[:weight_for_production_repair] )
    self.item_condition                 = params[:item_condition]
    self.save 
    
    if self.errors.size == 0 
      return self 
    end
    
    self.destroy_work_order
    self.generate_work_order
  end
  
  def delete( employee )
    return nil if employee.nil?
    if self.is_confirmed? 
      self.post_confirm_delete(employee)
      return self
    end
    
    self.destroy 
  end
  
  def post_confirm_delete(employee)
    self.destroy_work_order
    self.destroy 
  end
  
  def confirm 
    return nil if self.is_confirmed == true  
    self.is_confirmed = true 
    
    self.save 
    
    self.generate_code
    
     
    if  self.errors.size != 0  
      raise ActiveRecord::Rollback, "Call tech support!" 
    end
    
    self.generate_work_order
   
  end
  
  def generate_work_order
    ProductionOrder.generate_guarantee_return_production_order( self  )
    ProductionRepairOrder.generate_guarantee_return_production_repair_order( self  )
    PostProductionOrder.generate_guarantee_return_post_production_order( self )
  end
  
  def destroy_work_order
    ProductionOrder.where(
      :case                     => PRODUCTION_ORDER[:guarantee_return]     ,
      :source_document_entry    => self.class.to_s          ,
      :source_document_entry_id => self.id                 
    ).each {|x| x.destroy }
    
    ProductionRepairOrder.where(
      :case                     => PRODUCTION_REPAIR_ORDER[:guarantee_return]     ,
      :source_document_entry    => self.class.to_s          ,
      :source_document_entry_id => self.id         
    ).each {|x| x.destroy }
    
    PostProductionOrder.where(
      :case                     =>  POST_PRODUCTION_ORDER[:guarantee_return]  ,
    
      :source_document_entry    => self.class.to_s          ,
      :source_document_entry_id => self.id            
    ).each {|x| x.destroy }
  end
  
  def generate_code
    
    start_datetime = Date.today.at_beginning_of_month.to_datetime
    end_datetime = Date.today.next_month.at_beginning_of_month.to_datetime
    
    counter = self.class.where{
      (self.created_at >= start_datetime)  & 
      (self.created_at < end_datetime )
    }.count
    
    if self.is_confirmed?
      counter = self.class.where{
        (self.created_at >= start_datetime)  & 
        (self.created_at < end_datetime ) & 
        (self.is_confirmed.eq true )
      }.count
    end
    
    header = ""
    if not self.is_confirmed?  
      header = "[pending]"
    end
    
    string = "#{header}GRE" + "/" + 
              self.created_at.year.to_s + '/' + 
              self.created_at.month.to_s+ '/' + 
              counter.to_s
              
    self.code =  string 
    self.save 
  end
  
  
  def self.all_selectable_item_conditions
    result = []
    
    
    
    result << [ "Hasil Cor" , 
                    GUARANTEE_RETURN_ENTRY_ITEM_CONDITION[:production] ] 
                    
    result << [ "Hasil Bubut" , 
                    GUARANTEE_RETURN_ENTRY_ITEM_CONDITION[:post_production] ] 
     
    return result
  end
end
