class Invoice < ActiveRecord::Base
  # can only be printed if the invoice has due date 
  
  # attr_accessible :title, :body
  belongs_to :delivery 
  belongs_to :customer 
  
  has_many :invoice_payments
  has_many :payments, :through => :invoice_payments 
  validates_presence_of :customer_id 
  
 
  def Invoice.create_by_employee( employee, delivery) 
    return nil if employee.nil?
    return nil if delivery.nil? 
    return nil if delivery.is_confirmed == false 
    
    # not creating invoice. Free Goods: guarantee return delivery 
    return nil if delivery.only_delivering_non_invoicable_goods? 

    new_object = Invoice.new 
    new_object.creator_id   = employee.id 
    new_object.delivery_id  = delivery.id 
    new_object.customer_id = delivery.customer_id 

    if new_object.save
      new_object.generate_code
      new_object.update_amount_payable
    end

    return new_object 
  end
  
  def update_due_date( employee, due_date)
    return nil if employee.nil?
    
    
    if due_date.nil? 
      errors.add(:due_date , "Tanggal Jatuh Tempo harus diisi" )  
      return self 
    end
    
    self.due_date = due_date 
    self.save 
    return self 
    
  end
  
  
  def generate_code
    
    start_datetime = Date.today.at_beginning_of_month.to_datetime
    end_datetime = Date.today.next_month.at_beginning_of_month.to_datetime
    
    counter = self.class.where{
      (self.created_at >= start_datetime)  & 
      (self.created_at < end_datetime )
    }.count
    
    header = ""
    if not self.is_confirmed?  
      header = "[pending]"
    end
    
    string = "INV" + "/" + 
              self.created_at.year.to_s + '/' + 
              self.created_at.month.to_s + '/' + 
              counter.to_s 
              
    self.code =  string 
    self.save 
  end
  
  def update_amount_payable
    total_amount = BigDecimal('0') 
    
    delivery.delivery_entries.each do |de|
      if de.sales_item.is_pending_pricing 
        self.amount_payable = BigDecimal('0')
        self.save 
        return 
      end
      total_amount +=  de.total_delivery_entry_price
    end
    
    self.amount_payable =  (1.0 + 0.1)*total_amount # with the tax 
    self.base_amount_payable = (1.0)*total_amount
    self.tax_amount_payable = 0.1*total_amount 
    self.save  
  end
  
  
  
  def update_paid_status(employee)
    self.reload
    if self.confirmed_pending_payment == BigDecimal("0")
      self.is_paid = true 
      self.paid_declarator_id = employee.id 
      self.paid_at = DateTime.now
      self.save 
    end
  end
  
  def pending_payment
    amount_payable - self.invoice_payments.sum("amount_paid") 
  end
  
  def confirmed_pending_payment
    amount_payable - confirmed_amount_paid 
  end
  
  def confirmed_amount_paid
     self.invoice_payments.where(:is_confirmed => true ).sum("amount_paid") 
  end
  
  def has_pending_payment_confirmation?
    self.invoice_payments.where(:is_confirmed => false ).count != 0
  end
 
=begin
  On Update price change
=end

  def propagate_price_change
    # puts "inside propagate_price_change"
    initial_amount_payable = self.amount_payable 
    new_amount_payable = BigDecimal("0")
    delivery.delivery_entries.each do |de|
      new_amount_payable +=  de.total_delivery_entry_price
    end
    
    amount_paid = self.confirmed_amount_paid
    # add the tax 
    new_amount_payable =  (1.0 + 0.1)*new_amount_payable
    
    self.amount_payable = new_amount_payable 
    
    # puts "initial_amount_payable: #{initial_amount_payable}"
    # puts "new_amount_payable: #{new_amount_payable}"
    # 
    if self.save 
     
    end
    
    if initial_amount_payable > new_amount_payable 
      # puts "initial amount > new amount"
      if amount_paid > new_amount_payable 
        #  we must distribute the excess to downpayment history
        # how can we distribute it? 
        # find the 
        diff = amount_paid -  new_amount_payable
        self.is_paid = true 
        
        self.distribute_excess_payment( diff )  
      elsif amount_paid < new_amount_payable
        self.is_paid = false 
      elsif amount_paid ==  new_amount_payable
        self.is_paid = true 
      end
      
    elsif initial_amount_payable < new_amount_payable
      # set is_paid status to be false 
      if amount_paid > new_amount_payable 
        #  we must distribute the excess to downpayment history
        # how can we distribute it? 
        # find the 
        diff = amount_paid -  new_amount_payable
        self.is_paid = true 
        
        self.distribute_excess_payment( diff )  
      elsif amount_paid < new_amount_payable
        self.is_paid = false 
      elsif amount_paid ==  new_amount_payable
        self.is_paid = true 
      end
      
    elsif initial_amount_payable  ==  new_amount_payable
      # do nothing. doesn't change anything
    end
    
    self.save 
    
    customer = self.customer 
    customer.update_outstanding_payment
  end
  
  def distribute_excess_payment(amount_to_be_distributed)
    
    # puts "gonna distribute excess payment: #{amount_to_be_distributed.to_s}"
    last_confirmed_invoice_payment = self.invoice_payments.joins(:payment).
          where( :payment => {:is_confirmed => true}).
          order("created_at DESC").last 
          
    last_payment = last_confirmed_invoice_payment.payment 
    
    if last_confirmed_invoice_payment.amount_paid > amount_to_be_distributed
      puts "case1"
      # deduct the invoice payment. add excess to downpayment asssociated with this payment 
      diff = last_confirmed_invoice_payment.amount_paid - amount_to_be_distributed
      last_confirmed_invoice_payment.amount_paid = diff
      last_confirmed_invoice_payment.save 
      last_payment.add_or_create_downpayment_from_price_adjustment( amount_to_be_distributed ) 
    elsif last_confirmed_invoice_payment.amount_paid < amount_to_be_distributed
      puts "case2"
      # delete this invoice_payment. add the whole amount to be distributed to downpayment
      last_confirmed_invoice_payment.destroy 
      last_payment.add_or_create_downpayment_from_price_adjustment( amount_to_be_distributed ) 
    elsif last_confirmed_invoice_payment.amount_paid ==  amount_to_be_distributed
      # delete this invoice payment.
      # add to downpayment s
      puts "case3"
      last_confirmed_invoice_payment.destroy 
      last_payment.add_or_create_downpayment_from_price_adjustment( amount_to_be_distributed )
    end
    
  
    
    
  end
 
=begin
  Delivery Printing
=end
  def printed_code
    self.code.gsub('/','-')
  end

  def calculated_vat
    BigDecimal("0")
  end

  def calculated_delivery_charges
    BigDecimal("0")
  end

  def calculated_sales_tax
    BigDecimal('0')
  end
end
