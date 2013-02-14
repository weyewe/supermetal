class DownpaymentHistory < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :payment 
  belongs_to :customer 
  
  def DownpaymentHistory.create_or_update_downpayment_addition_history( payment ) 
    downpayment = self.where(
      :payment_id  => payment.id, 
      :customer_id => payment.customer_id ,
      :creator_id  => payment.creator_id , 
      :case        => DOWNPAYMENT_CASE[:addition]
    ).first 
    
    if downpayment.nil?
      DownpaymentHistory.create_downpayment_addition_history( payment  ) 
    else
      downpayment.amount  = payment.downpayment_addition_amount
      downpayment.save 
    end
  end
  
  
  def DownpaymentHistory.create_downpayment_addition_history( payment  ) 
    # puts "in the downpaymenthistory.create_downpayment_addition_history"
    # puts "amount: #{payment.downpayment_addition_amount}"
    new_object             = self.new 
    new_object.payment_id  = payment.id 
    new_object.customer_id = payment.customer_id 
    new_object.creator_id  = payment.creator_id 
    new_object.amount      = payment.downpayment_addition_amount
    new_object.case        = DOWNPAYMENT_CASE[:addition]

    new_object.save  
  end
  
  def DownpaymentHistory.create_or_update_downpayment_deduction_history( payment ) 
    downpayment = self.where(
      :payment_id  => payment.id, 
      :customer_id => payment.customer_id ,
      :creator_id  => payment.creator_id , 
      :case        => DOWNPAYMENT_CASE[:deduction]
    ).first 
    
    if downpayment.nil?
      DownpaymentHistory.create_downpayment_deduction_history( payment  ) 
    else
      downpayment.amount  = payment.downpayment_usage_amount
      downpayment.save 
    end
  end
  
  def DownpaymentHistory.create_downpayment_deduction_history( payment  ) 
    new_object             = self.new 
    new_object.payment_id  = payment.id 
    new_object.customer_id = payment.customer_id 
    new_object.creator_id  = payment.creator_id 
    new_object.amount      = payment.downpayment_usage_amount
    new_object.case        = DOWNPAYMENT_CASE[:deduction]

    new_object.save  
  end
end
