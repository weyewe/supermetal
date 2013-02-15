class GuaranteeReturn < ActiveRecord::Base
  # attr_accessible :title, :body
  validates_presence_of :creator_id
  validates_presence_of :customer_id
  
  belongs_to :customer 
  has_many :guarantee_return_entries 
   

  def self.create_by_employee( employee, params ) 
    return nil if employee.nil? 
    
    new_object = self.new
    new_object.creator_id    = employee.id
    new_object.customer_id   = params[:customer_id] 
    new_object.receival_date = params[:receival_date]

    
    if new_object.save
      new_object.generate_code
    end
    
    return new_object 
  end
  
  def delete(employee)
    return nil if employee.nil?
    if self.is_confirmed?
      self.post_confirm_delete( employee ) 
      return self
    end
    
    self.guarantee_return_entries.each do |entry|
      entry.destroy 
    end
    self.destroy 
  end
  
  def update_by_employee( employee, params ) 
    return nil if employee.nil? 
    if self.is_confirmed?
      self.post_confirm_update(employee,params)
      return self
    end
    
    self.creator_id      = employee.id
    self.customer_id   = params[:customer_id] 
    self.receival_date = params[:receival_date]

    
    
    if self.save
    end
    
    return self 
  end
  
  def post_confirm_update(employee,params)
    self.creator_id = employee.id 
    self.receival_date =  params[:receival_date]
    self.save 
  end
  
  def post_confirm_delete(employee)
    self.guarantee_return_entries.each do |gre|
      gre.delete( employee ) 
    end 
    
    self.is_deleted = true 
    self.save
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
    
    
    string = "#{header}GR" + "/" + 
              self.created_at.year.to_s + '/' + 
              self.created_at.month.to_s + '/' + 
              counter.to_s 
              
    self.code =  string 
    self.save 
  end
  
  def confirm(employee) 
    return nil if employee.nil? 
    return nil if self.guarantee_return_entries.count == 0 
    return nil if self.is_confirmed == true  
    
    # transaction block to confirm all the sales item  + sales order confirmation 
    ActiveRecord::Base.transaction do
      self.confirmer_id = employee.id 
      self.confirmed_at = DateTime.now 
      self.is_confirmed = true 
      self.save 
      self.generate_code
      
      if  self.errors.size != 0  
        raise ActiveRecord::Rollback, "Call tech support!" 
      end
      
      self.guarantee_return_entries.each do |guarantee_return_entry|
        guarantee_return_entry.confirm 
      end
    end 
  end
end
