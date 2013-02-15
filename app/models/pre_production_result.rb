class PreProductionResult < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :template_sales_item
   
  validates_presence_of   :ok_quantity,  :broken_quantity,
                          :started_at, :finished_at, :template_sales_item_id 
                          
  validates_numericality_of :ok_quantity, :broken_quantity  
                  
   
  validate :no_all_zero_quantity
  validate :no_negative_quantity
  validate :start_date_must_not_be_later_than_finish_date
  # validate :no_excess_production 
 

   

  def no_all_zero_quantity
    if  ok_quantity.present? and broken_quantity.present?   and
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
  
  
  def start_date_must_not_be_later_than_finish_date
    if (not started_at.nil?) and (not finished_at.nil? )  and  (started_at > finished_at)
      errors.add(:started_at , "Tanggal mulai tidak boleh sesudah tanggal selesai" ) 
    end 
  end
  
  # def no_excess_production
  #   sales_item_subcription = self.sales_item_subcription 
  #   if ok_quantity.present? and ok_quantity > sales_item_subcription.pending_production 
  #     errors.add(:ok_quantity , "Tidak boleh lebih besar dari #{sales_item_subcription.pending_production }" ) 
  #   end
  # end
  
  
  
  def self.create_result( employee,  params ) 
    return nil if employee.nil?  
    return nil if params[:template_sales_item_id].nil? 
    
    template_sales_item = TemplateSalesItem.find_by_id params[:template_sales_item_id]
    return nil if template_sales_item.has_unconfirmed_pre_production_result? 
    # puts "the template_sales_item: #{template_sales_item}"
    
    new_object  = self.new 
    new_object.template_sales_item_id = params[:template_sales_item_id]
    new_object.creator_id = employee.id 
    
    new_object.ok_quantity         = params[:ok_quantity]
    new_object.broken_quantity     = params[:broken_quantity] 
    new_object.started_at          = params[:started_at] 
    new_object.finished_at         = params[:finished_at] 

    
    if new_object.save   
      new_object.update_processed_quantity
    end
    
   
    
    return new_object 
  end
  
  def update_result( employee, params ) 
    return nil if employee.nil?    
     # and self is not admin 
    if self.is_confirmed?
      self.post_confirm_update(employee,  params ) 
      return self 
    end
    
    self.creator_id = employee.id 
    self.ok_quantity         = params[:ok_quantity]
    self.broken_quantity     = params[:broken_quantity] 
    self.started_at          = params[:started_at] 
    self.finished_at         = params[:finished_at]

    if self.save  
      # sales_item.update_pre_production_statistics 
    end
    
    return self 
  end
  
  def post_confirm_update(employee,  params ) 
    self.creator_id = employee.id 
    self.ok_quantity         = params[:ok_quantity]
    self.broken_quantity     = params[:broken_quantity] 
    self.started_at          = params[:started_at] 
    self.finished_at         = params[:finished_at]
    
    if self.save 
      ActiveRecord::Base.transaction do
        update_processed_quantity  
      end
    end
    
    return self 
  end
   
  def delete(employee)
    return nil if employee.nil?
     
    self.destroy 
  end
  
  
  
  
  
  def update_processed_quantity 
    self.processed_quantity = self.ok_quantity  + 
                                    self.broken_quantity
    self.save
  end
  
  
  
  def confirm( employee )
    return nil if employee.nil? 
    # puts "pass the employee check"
    return nil if self.is_confirmed == true 
    # puts "pass the is_confirmed check"
    
    ActiveRecord::Base.transaction do
      self.is_confirmed = true 
      self.confirmer_id = employee.id
      self.confirmed_at = DateTime.now 
      self.save
      
      self.update_processed_quantity
      
      # puts "Total error in confirm: #{self.errors.size}"
      if  self.errors.size != 0  
        puts "There is rollback!! on confirm"
        self.errors.messages.each do |msg|
          puts "#{msg}"
        end
        raise ActiveRecord::Rollback, "Call tech support!" 
      end
      
    end
  end
  
  
   
  def is_a_number?(s)
    s.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true 
  end
end
