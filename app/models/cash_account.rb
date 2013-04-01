class CashAccount < ActiveRecord::Base
  attr_accessible :name, :case, :description 
  validates_presence_of :name, :case
  
  has_many :payments  
  
  def CashAccount.all_selectable_cases
    result = []
    CASH_ACCOUNT_CASE.each do |key, cac | 
      
      result << [ "#{cac[:name]}" , 
                      cac[:value] ]  
    end
    return result
  end
  
  def self.all_selectables
    selectables  =  CashAccount.order("created_at DESC") 
    result = []
    selectables.each do |selectable| 
      result << [ "#{selectable.name}" , 
                      selectable.id ]  
    end
    return result
  end
  
  def delete( employee )
    return nil if employee.nil?
    return nil if self.payments.count != 0
    self.destroy
  end
  
  def self.create_by_employee( employee, params) 
    new_object = self.new 
    new_object.name = params[:name]
    new_object.case = params[:case]
    new_object.description = params[:description]
    
    new_object.save
    return new_object 
  end
  
  def update_by_employee( employee, params)
    self.name = params[:name]
    self.case = params[:case]
    self.description = params[:description]

    self.save
    return self
  end
  
  def case_name
    if    self.case == CASH_ACCOUNT_CASE[:bank][:value]
      return CASH_ACCOUNT_CASE[:bank][:name]
    elsif self.case == CASH_ACCOUNT_CASE[:cash][:value]
      return CASH_ACCOUNT_CASE[:cash][:name]
    end
  end
end
