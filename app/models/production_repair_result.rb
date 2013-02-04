class ProductionRepairResult < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :template_sales_item
   
   
  validates_presence_of   :ok_quantity,  :broken_quantity,   
                          :ok_weight,   :broken_weight,   
                          :started_at, :finished_at, :template_sales_item_id 
                          
  validates_numericality_of :ok_quantity, :broken_quantity  ,  
                          :ok_weight, :broken_weight  
                  
   
  validate :no_all_zero_quantity
  validate :no_negative_quantity
  validate :no_negative_weight
  validate :prevent_zero_weight_for_non_zero_quantity
  validate :start_date_must_not_be_later_than_finish_date
  validate :no_excess_repair
 

   

  def no_all_zero_quantity
    if  ok_quantity.present? and broken_quantity.present? and
      ok_quantity == 0  and  broken_quantity == 0  
      errors.add(:ok_quantity , "OK, gagal, dan perbaiki tidak boleh bernilai 0 bersamaan" ) 
      errors.add(:broken_quantity , "OK, gagal, dan perbaiki tidak boleh bernilai 0 bersamaan" )   
    end
  end
  
  def no_negative_quantity
    if ok_quantity.present? and ok_quantity < 0 
      errors.add(:ok_quantity , "Kuantitas tidak boleh lebih kecil dari 0" ) 
    end
    
    if broken_quantity.present? and  broken_quantity <0 
      errors.add(:broken_quantity , "Kuantitas tidak boleh lebih kecil dari 0" )   
    end 
  end
  
  def no_negative_weight
    if ok_weight.present? and ok_weight < BigDecimal('0')
      errors.add(:ok_weight , "Berat tidak boleh negative" ) 
    end
    
    if broken_weight.present? and broken_weight < BigDecimal('0')
      errors.add(:broken_weight , "Berat tidak boleh negative" )   
    end
    
   
  end
  
  def prevent_zero_weight_for_non_zero_quantity
    if ok_quantity.present? and ok_weight.present? and 
        ok_quantity > 0 and ok_weight <= BigDecimal('0')
      errors.add(:ok_weight , "Berat tidak boleh 0 jika kuantity > 0 " ) 
    end
    
    if broken_quantity.present? and broken_weight.present? and 
       broken_quantity >  0  and broken_weight <=  BigDecimal('0')
      errors.add(:broken_weight , "Berat tidak boleh 0 jika kuantity > 0 " )   
    end
     
  end
  
  def start_date_must_not_be_later_than_finish_date
    if (not started_at.nil?) and (not finished_at.nil? )  and  (started_at > finished_at)
      errors.add(:started_at , "Tanggal mulai tidak boleh sesudah tanggal selesai" ) 
    end 
  end 
  
  def no_excess_repair
    total_repair_result = ok_quantity + broken_quantity 
    total_pending_production_repair = template_sales_item.pending_production_repair 
    if ok_quantity.present? and broken_quantity.present? and total_repair_result > total_pending_production_repair
      err_msg = "Total ok dan rusak tidak boleh lebih dari pending perbaiki: #{total_pending_production_repair}"
      errors.add(:ok_quantity ,     err_msg ) 
      errors.add(:broken_quantity , err_msg ) 
    end
  end
  
  
  
  def self.create_result( employee,  params ) 
    return nil if employee.nil?  
    return nil if params[:template_sales_item_id].nil? 
    
    template_sales_item = TemplateSalesItem.find_by_id params[:template_sales_item_id]
    return nil if template_sales_item.has_unconfirmed_production_repair_result? 
    
    new_object  = self.new 
    new_object.template_sales_item_id = template_sales_item.id 
    new_object.creator_id = employee.id 
     
   
    
    new_object.ok_quantity         = params[:ok_quantity]
    new_object.broken_quantity     = params[:broken_quantity] 
    new_object.ok_weight           = BigDecimal( params[:ok_weight]           )
    new_object.broken_weight       = BigDecimal( params[:broken_weight]       )
    new_object.started_at          = params[:started_at] 
    new_object.finished_at         = params[:finished_at] 

    
    if new_object.save   
      new_object.update_processed_quantity
    end
    
   
    
    return new_object 
  end
  
  def update_result( employee, params ) 
    return nil if employee.nil?    
    return nil if self.is_confirmed == true  # and self is not admin 
    
    self.creator_id = employee.id 
    self.ok_quantity         = params[:ok_quantity]
    self.broken_quantity     = params[:broken_quantity] 
    self.ok_weight           = BiDecimal( params[:ok_weight]         )
    self.broken_weight       = BiDecimal( params[:broken_weight]     )
    self.started_at          = params[:started_at] 
    self.finished_at         = params[:finished_at]

    if self.save  
      self.update_processed_quantity
      # new_object.update_processed_quantity 
      # sales_item.update_pre_production_statistics 
    end
    
    return self 
  end
  
  def delete(employee)
    return nil if employee.nil?
    return nil if self.is_confirmed == true 
    self.destroy if self.is_confirmed == false 
  end
  
  
  
  
  def update_processed_quantity 
    self.processed_quantity = self.ok_quantity  + 
                                    self.broken_quantity
    self.save
  end
  
  
  
  def confirm( employee )
    return nil if employee.nil? 
    puts "pass the employee check"
    return nil if self.is_confirmed == true 
    puts "pass the is_confirmed check"
    
    ActiveRecord::Base.transaction do
      
      
      
      self.is_confirmed = true 
      self.confirmer_id = employee.id
      self.confirmed_at = DateTime.now 
      self.save
      
      puts "Total error in confirm: #{self.errors.size}"
      if  self.errors.size != 0  
        puts "There is rollback!! on confirm"
        self.errors.messages.each do |msg|
          puts "#{msg}"
        end
        raise ActiveRecord::Rollback, "Call tech support!" 
      end
      
      ProductionOrder.generate_production_repair_failure_production_order( self  )
    end
  end
  
  
   
  def is_a_number?(s)
    s.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true 
  end
end
