class SalesItem < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :sales_order
  belongs_to :customer 
  belongs_to :template_sales_item 
  belongs_to :sales_item_subcription
  
   
  
  has_many :delivery_entries
  
  has_many :pre_production_histories # PreProductionHistory 
  has_many :production_histories # ProductionHistory
  has_many :post_production_histories#  PostProductionHistory
  has_many :delivery_entries #  DeliveryEntry 
  has_many :sales_return_entries #  SalesReturnEntry
  has_many :delivery_lost_entries #  DeliveryLostEntry
  
  has_many :guarantee_return_entries
  has_many :item_receival_entries
  
  validates_presence_of :description
  validates_presence_of :name 
  validates_presence_of :creator_id
  # validates_presence_of :price_per_piece
  # validates_presence_of :weight_per_piece
  # validates_presence_of :quantity 
  validates_presence_of :case 
  validates_presence_of :quantity_for_production, :quantity_for_post_production
  
  validate :material_must_present_if_production_is_true 
  validate :delivery_address_must_present_if_delivered_is_true 
  # validate :quantity_must_be_at_least_one
  validate  :weight_per_piece_must_not_be_less_than_zero
  validate :quantity_must_be_present_if_selected
  validate :quantity_for_production_and_post_production_non_zero
  
   
  
  def material_must_present_if_production_is_true
    if  is_production == true  and  material_id.nil?
      errors.add(:material_id , "Pilih Material karena ada produksi" )  
    end
  end
  
  def delivery_address_must_present_if_delivered_is_true
    if  is_delivered == true and  not delivery_address.present? 
      errors.add(:delivery_address , "Harus ada alamat pengiriman" )  
    end
  end
  
  # def quantity_must_be_at_least_one
  #   if not quantity.present? or quantity <= 0 
  #     errors.add(:quantity , "Quantity harus setidaknya 1" )  
  #   end
  # end
  
  
  def weight_per_piece_must_not_be_less_than_zero
    if  weight_per_piece.present? and weight_per_piece <= BigDecimal('0')
      errors.add(:weight_per_piece , "Berat satuan tidak boleh kurang dari 0 kg" )  
    end
  end
  
  def quantity_must_be_present_if_selected
    if is_production? and quantity_for_production.present? and quantity_for_production <=  0 
      msg = "Kuantitas  tidak boleh 0 "
      errors.add(:quantity_for_production , msg )
    end
    
    if is_post_production? and quantity_for_post_production.present? and quantity_for_post_production <=  0 
      msg = "Kuantitas  tidak boleh 0 "
      errors.add(:quantity_for_post_production , msg )
    end
  end
  
  def quantity_for_production_and_post_production_non_zero
    if is_production.present? and is_post_production.present?    and 
      quantity_for_production.present? and quantity_for_post_production.present?
      if quantity_for_production == 0 and quantity_for_post_production == 0 
        msg = "Kuantitas cor dan bubut tidak boleh 0"
        errors.add(:quantity_for_production , msg )    
        errors.add(:quantity_for_post_production ,  msg )    
      end
      
      if quantity_for_post_production > quantity_for_production 
        errors.add(:quantity_for_post_production ,  'Tidak boleh lebih besar daripada kuantitas cor' )   
      end
    end
    
    if is_production.present? and not is_post_production.present?    and 
      quantity_for_production.present? and quantity_for_post_production.present?
      
      if quantity_for_post_production != 0 
        errors.add(:quantity_for_post_production ,  'Harus 0' ) 
      end
    end
    
    
    if not is_production.present? and  is_post_production.present?    and 
      quantity_for_production.present? and quantity_for_post_production.present?
      
      if quantity_for_production != 0 
        errors.add(:quantity_for_production ,  'Harus 0' ) 
      end
    end
  end
  
  # def total_quantity_must_match_quantity
  #   if quantity_for_production +  quantity_for_post_production != quantity
  #     msg = "Jumlah kuantitas"
  #     errors.add(:quantity_for_production , "Berat satuan tidak boleh kurang dari 0 kg" ) 
  #     errors.add(:quantity_for_post_production , "Berat satuan tidak boleh kurang dari 0 kg" )
  #   end
  # end
  
  
  
  def delete(employee)
    return nil if employee.nil?
    return nil if self.is_confirmed? 
    
    self.destroy 
  end
  
  def cancel(employee)
    return nil if employee.nil?
    return nil if not sales.is_confirmed?
    
    self.is_deleted = true 
    self.save 
    
    ProductionOrder.where(:source_document_entry_id => self.id , 
    :source_document_entry => self.class.to_s, 
    :case =>  PRODUCTION_ORDER[:sales_order] ).each do |x| 
      x.quantity = 0 
      x.save 
    end
    
    PostProductionOrder.where(:source_document_entry_id => self.id , 
    :source_document_entry => self.class.to_s, 
    :case =>  PRODUCTION_ORDER[:sales_order] ).each do |x| 
      x.quantity = 0 
      x.save 
    end
    
    
  end
  
  def SalesItem.create_sales_item( employee, sales_order, params ) 
    return nil if employee.nil?
    return nil if sales_order.nil? 
    
    new_object = SalesItem.new
    new_object.creator_id = employee.id 
    new_object.sales_order_id = sales_order.id 
    
    new_object.material_id           = params[:material_id]       
    new_object.is_pre_production     = params[:is_pre_production] 
    new_object.is_production       = params[:is_production]    
    # new_object.is_production         = true # by default  
    new_object.is_post_production    = params[:is_post_production]
    new_object.is_delivered          = params[:is_delivered]      
    new_object.delivery_address      = params[:delivery_address]  

    new_object.weight_per_piece      = BigDecimal( params[:weight_per_piece ])
    # new_object.quantity              = params[:quantity]      
    new_object.quantity_for_production              = params[:quantity_for_production]     
    new_object.quantity_for_post_production              = params[:quantity_for_post_production]         
    new_object.description           = params[:description]   
    new_object.name                  = params[:name]
    
    new_object.customer_id = sales_order.customer_id 
    
    if params[:case].nil?
      new_object.case  = SALES_ITEM_CREATION_CASE[:new]
    end
    
    

    
    new_object.is_pending_pricing = params[:is_pending_pricing]
    if not new_object.is_pending_pricing
      new_object.pre_production_price  = BigDecimal( params[:pre_production_price]  )
      new_object.production_price      = BigDecimal( params[:production_price]      )
      new_object.post_production_price = BigDecimal( params[:post_production_price] )
      new_object.is_pricing_by_weight  =  params[:is_pricing_by_weight]  
    else 
      new_object.pre_production_price   = BigDecimal("0")
      new_object.production_price       = BigDecimal("0")
      new_object.post_production_price  = BigDecimal("0") 
    end                               
     

    new_object.requested_deadline    = params[:requested_deadline] # Date.new( 2013, 3,5 )

    
    
    if new_object.save 
      new_object.generate_code 
    end
    
    return new_object 
  end
  
  def update_sales_item( employee, params ) 
    if self.is_confirmed? 
      self.post_confirm_update(employee,  params ) 
      return self 
    end
       
    self.material_id           = params[:material_id]       
    self.is_pre_production     = params[:is_pre_production] 
    self.is_production       = params[:is_production]     
    # self.is_production         = true # by default 
    self.is_post_production    = params[:is_post_production]
    self.is_delivered          = params[:is_delivered]      
    self.delivery_address      = params[:delivery_address]  
    self.weight_per_piece      = BigDecimal( params[:weight_per_piece ])
    # self.quantity              = params[:quantity]         
    self.quantity_for_production              = params[:quantity_for_production]     
    self.quantity_for_post_production              = params[:quantity_for_post_production] 
    self.description           = params[:description]   
    self.name                  = params[:name]
    
    self.is_delivered          = params[:is_delivered]      
    self.delivery_address      = params[:delivery_address]
    
    self.is_pending_pricing = params[:is_pending_pricing]
    
    if not self.is_pending_pricing
      self.pre_production_price  = BigDecimal( params[:pre_production_price]  )
      self.production_price      = BigDecimal( params[:production_price]      )
      self.post_production_price = BigDecimal( params[:post_production_price] )
      self.is_pricing_by_weight  =  params[:is_pricing_by_weight]   
    else
      self.pre_production_price  = BigDecimal( '0' )
      self.production_price      = BigDecimal( '0' )
      self.post_production_price = BigDecimal( '0' )
    end
    
    
    if self.main_template_sales_item? and self.name_changed? or self.description_changed? 
      self.update_template_sales_item 
    end
    
    self.requested_deadline    = params[:requested_deadline] 
    self.save 
    
    return self 
  end
  
  
  
  
  
=begin
  ADMIN UPDATE CONFIRMED SALES ITEM 
=end

  def validate_post_confirm_update
    if self.is_production == true and self.quantity_for_production <= 0
      errors.add(:quantity_for_production , "Kuantitas cor tidak boleh 0 jika cor dipilih" ) 
    end
  
    if self.is_post_production == true and self.quantity_for_post_production <= 0 
      errors.add(:quantity_for_post_production , "Kuantitas bubut tidak boleh 0 jika bubut dipilih" )  
    end
  end

  def main_template_sales_item?
    self.template_sales_item.main_sales_item_id == self.id 
  end
  
  def update_template_sales_item
    template_sales_item = self.template_sales_item
    template_sales_item.update_from_sales_item( self) 
  end
  
  def update_invoice
    # noprice -> price 
    
    puts "inside the update invoice"
    self.related_invoices.each do |invoice|
      puts "\n===== propagate price change"
      invoice.propagate_price_change 
    end
    
    # price -> price 
  end
  
  def update_work_order
    # if self.quantity_for_production_changed? 
      sales_production_order = ProductionOrder.where(
        :source_document_entry => self.class.to_s,
        :source_document_entry_id => self.id , 
        :case                     => PRODUCTION_ORDER[:sales_order]
      ).first 
      
      puts "in the update work order, production order. quantity_for_proudction: #{self.quantity_for_production}"
      sales_production_order.quantity = self.quantity_for_production 
      sales_production_order.save 
    # end
    
    # if self.quantity_for_post_production_changed? 
      sales_post_production_order = PostProductionOrder.where(
        :source_document_entry => self.class.to_s,
        :source_document_entry_id => self.id , 
        :case                     => POST_PRODUCTION_ORDER[:sales_order]
      ).first 
      
      puts "in the update work order, post production order. quantity_for_postproudction: #{self.quantity_for_post_production}"
      
      sales_post_production_order.quantity = self.quantity_for_post_production 
      sales_post_production_order.save 
    # end
  end
  
  
  def related_invoices 
    delivery_id_list = self.delivery_entries.map{|x|  x.delivery_id }
    Invoice.where(:delivery_id => delivery_id_list )
  end
  
  def has_any_payment?
    invoice_id_list = self.related_invoices.map{|x| x.id }
    
    total_payments_made = InvoicePayment.where(:invoice_id => invoice_id_list)
    
    total_payments_made != 0 
  end
  
  def post_confirm_update(employee,  params ) 
    # if initial value is only post production, can't add production
    if self.is_production == false and self.is_post_production == true
      if params[:is_production] == true 
        errors.add(:is_production , "Pesanan hanya bubut. Tidak boleh ditambah cor" ) 
      end
    end
    
    
    if self.is_production == true  
        # then, on update, change it to only_post_production 
      if ( params[:is_production] == false ) and 
          ( params[:is_post_production] == true  ) 
        errors.add(:is_production , "Pesanan termasuk cor. Tidak boleh diubah jadi hanya bubut" ) 
      end
    end
    
    if self.is_pending_pricing == false and 
        ( params[:is_pending_pricing] == true  ) and 
        self.has_any_payment? 
        # if there is shite paid 
        # => can't change 
        
      errors.add(:is_pending_pricing , "Tidak boleh menghilangkan harga karena sudah ada pembayaran" ) 
    end
    
    if self.errors.size != 0
      return self
    end
    
    
    
    self.quantity_for_production      = params[:quantity_for_production]
    self.quantity_for_post_production = params[:quantity_for_post_production]
    
    self.is_pending_pricing    = params[:is_pending_pricing]
    self.is_pricing_by_weight  = params[:is_pricing_by_weight]
    
    self.is_pre_production     = params[:is_pre_production]
    self.is_production         = params[:is_production]
    self.is_post_production    = params[:is_post_production]
    self.pre_production_price  = BigDecimal( params[:pre_production_price])
    self.production_price      = BigDecimal( params[:production_price])   
    self.post_production_price = BigDecimal( params[:post_production_price]) 
    
    self.requested_deadline    = params[:requested_deadline] 
    
    self.name                  = params[:name]
    self.description           = params[:description]
    self.delivery_address = params[:delivery_address]
    
    

    if self.main_template_sales_item? and self.name_changed? or self.description_changed? 
      self.update_template_sales_item 
    end
    
    self.valid? 
    self.validate_post_confirm_update
    
    is_pricing_changed = self.pre_production_price_changed?    || 
                            self.production_price              ||
                            self.post_production_price         ||
                            self.is_pricing_by_weight
            
    is_quantity_changed = self.quantity_for_production_changed? || self.quantity_for_post_production_changed?
                
    if self.quantity_for_post_production_changed?
      puts "5555 the quantity for post production is changed\n"*5
    end
    
    puts "quantity_for_production_changed value: #{self.quantity_for_production_changed?}"
    puts "quantity_for_post_production_changed value : #{self.quantity_for_post_production_changed?}"
    if is_quantity_changed
      puts "is_quantity_changed value : #{is_quantity_changed}"
    else
      puts "NOT CHANGED: is_quantity_changed value : #{is_quantity_changed}"
    end
    
    self.save 
    
    if self.errors.size  == 0 
      # update price in invoice 
      if  is_pricing_changed
        self.update_invoice 
      end
     
      
      # update work_order 
      if  is_quantity_changed
          puts "Gonna update work order\n"*10
        self.update_work_order 
      end
    else
      puts "There are some error"
      self.errors.messages.each do |x|
        puts "MSG: #{x}"
      end
      
    end
    
    
    
    return self 
  end
  
=begin
##############################
##############################
##############################
  CREATING THE REPEAT_SALES_ITEM
##############################
##############################
##############################
=end
  def SalesItem.create_repeat_sales_item( employee, sales_order,  params )
    return nil if employee.nil?
    return nil if sales_order.nil? 
    return nil if params[:template_sales_item_id].nil? 
    
    new_object = SalesItem.new
    new_object.creator_id = employee.id 
    new_object.sales_order_id = sales_order.id 
    new_object.customer_id = sales_order.customer_id 
    
    template = TemplateSalesItem.find_by_id params[:template_sales_item_id]
    # related to the template sales item 
    sample_sales_item  = template.confirmed_sales_items.first 
    new_object.material_id           = sample_sales_item.material_id 
    new_object.weight_per_piece      = sample_sales_item.weight_per_piece 
    new_object.description           = sample_sales_item.description
    new_object.name                  = sample_sales_item.name
    
    
    # from params  
    # new_object.quantity               = params[:quantity]  
    new_object.quantity_for_production              = params[:quantity_for_production]     
    new_object.quantity_for_post_production              = params[:quantity_for_post_production]
    new_object.template_sales_item_id = params[:template_sales_item_id]
    new_object.is_pre_production      = params[:is_pre_production] 
    new_object.is_production          = params[:is_production]
    new_object.is_post_production     = params[:is_post_production]
    new_object.is_delivered           = params[:is_delivered]      
    new_object.delivery_address       = params[:delivery_address]  
    new_object.case                   = SALES_ITEM_CREATION_CASE[:repeat] 
    new_object.is_pending_pricing     = params[:is_pending_pricing]

    if not new_object.is_pending_pricing
      new_object.pre_production_price  = BigDecimal( params[:pre_production_price]  )
      new_object.production_price      = BigDecimal( params[:production_price]      )
      new_object.post_production_price = BigDecimal( params[:post_production_price] )
      new_object.is_pricing_by_weight  =  params[:is_pricing_by_weight]  
    else 
      new_object.pre_production_price   = BigDecimal("0")
      new_object.production_price       = BigDecimal("0")
      new_object.post_production_price  = BigDecimal("0") 
    end                               
     

    new_object.requested_deadline    = params[:requested_deadline] # Date.new( 2013, 3,5 )
    
    if sample_sales_item.is_production? and new_object.is_production == false 
      new_object.errors.add(:is_production , "Harus ada casting karena pesanan terdahulu memiliki casting" )  
      return new_object 
    end
 
    
    if new_object.save 
      new_object.code = template.code 
      new_object.save 
    end
    
    return new_object
  end
  
  
  def update_repeat_sales_item( params ) 
    return nil if self.is_confirmed? 
    template = TemplateSalesItem.find_by_id params[:template_sales_item_id]
    
    if self.template_sales_item_id != template.id
      # change the template and the data related to it 
      sample_sales_item  = template.confirmed_sales_items.first 
      self.material_id           = sample_sales_item.material_id 
      self.weight_per_piece      = sample_sales_item.weight_per_piece 
      self.description           = sample_sales_item.description
      self.name                  = sample_sales_item.name
      self.template_sales_item_id = template.id 
    end
    
    # self.quantity              = params[:quantity]
    self.quantity_for_production              = params[:quantity_for_production]     
    self.quantity_for_post_production              = params[:quantity_for_post_production]
    
    self.is_pre_production     = params[:is_pre_production] 
    self.is_production       = params[:is_production]     
    self.is_post_production    = params[:is_post_production]
    self.is_delivered          = params[:is_delivered]      
    self.delivery_address      = params[:delivery_address]   
    self.is_pending_pricing = params[:is_pending_pricing]
    
    if not self.is_pending_pricing
      self.pre_production_price  = BigDecimal( params[:pre_production_price]  )
      self.production_price      = BigDecimal( params[:production_price]      )
      self.post_production_price = BigDecimal( params[:post_production_price] )
      self.is_pricing_by_weight  =  params[:is_pricing_by_weight]   
    else
      self.pre_production_price  = BigDecimal( '0' )
      self.production_price      = BigDecimal( '0' )
      self.post_production_price = BigDecimal( '0' )
    end
    
    
    self.requested_deadline    = params[:requested_deadline] 
    self.save 
    
    return self
  end
  
=begin
##############################
##############################
##############################
  END OF REPEAT_SALES_ITEM
##############################
##############################
##############################
=end
  
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
    
    
    
    # Misalnya ada order FCD pada tanggal 21 januari 2013 dengan nomor urut 2 berarti nulisnya 
    # B13-0102 (Kode material Tahun order - Bulan order Nomor urut)
    # 
    material_code = "" 
    if not self.only_post_production? and not self.material_id.nil?
      material_code = Material.find_by_id( self.material_id ) .code 
    elsif self.only_post_production?
      material_code = "N"
    end
    
    string = "#{header}#{material_code}" + 
              ( self.created_at.year%1000).to_s + "-" + 
              ( self.created_at.month).to_s + '-' + 
              ( counter.to_s ) 
              
    
    self.code =  string 
    self.save 
  end
  
  def generate_template_sales_item
    if self.case == SALES_ITEM_CREATION_CASE[:new]
      template_si = TemplateSalesItem.create_based_on_sales_item( self )
      self.template_sales_item_id = template_si.id 
      self.save 
    end
  end
  
  def generate_customer_subcription
    return nil if not self.sales_item_subcription.nil? 
    
    si_subcription = nil 
    
      si_subcription = SalesItemSubcription.create_or_find_subcription(self)  
   
    
    self.sales_item_subcription_id = si_subcription.id 
    self.save
  end
  
  
  
  
  def confirm
    return nil if self.is_confirmed == true 
    
    self.is_confirmed = true 
    self.save
    
    if self.case == SALES_ITEM_CREATION_CASE[:new]
      self.generate_code
      self.generate_template_sales_item 
    end
    
    self.generate_customer_subcription
    self.reload 
    
    if self.is_production?
      production_order = ProductionOrder.create_sales_production_order( self )
    end
    
    if self.is_post_production?
      production_order = PostProductionOrder.generate_sales_post_production_order( self )
    end
  end
  
  
  
  def only_machining?
    self.is_production == false && self.is_post_production == true 
  end
  
  def only_post_production?
    only_machining? 
  end
  
  def casting_included? 
    self.is_production == true 
  end
  
  def has_post_production?
    self.is_post_production?
  end
  
  def only_production?
    stop_at_production?
  end
  
  def stop_at_production?
    self.is_post_production == false and self.is_production == true 
  end
  
  def stop_at_post_production?
    self.is_post_production == true 
  end
  
  
  
  def production_orders 
    ProductionOrder.where(
      :source_document_entry => self.class.to_s,
      :source_document_entry_id => self.id ,
      :case => PRODUCTION_ORDER[:sales_order] 
    )
  end
  
   
  
  
  def normal_post_production_delivery
    delivery = self.delivery_entries.where(
      :is_confirmed => true, 
      :is_finalized => false,
      :item_condition => DELIVERY_ENTRY_ITEM_CONDITION[:post_production],
      :entry_case =>  DELIVERY_ENTRY_CASE[:normal]
    ).sum("quantity_sent")
  
    confirmed_delivery = self.delivery_entries.where(
      :is_confirmed => true, 
      :is_finalized => true,
      :item_condition => DELIVERY_ENTRY_ITEM_CONDITION[:post_production],
      :entry_case =>  DELIVERY_ENTRY_CASE[:normal]
    ).sum("quantity_confirmed")
    
    return delivery + confirmed_delivery
  end
  
  def normal_production_delivery
    delivery = self.delivery_entries.where(
      :is_confirmed => true, 
      :is_finalized => false,
      :item_condition => DELIVERY_ENTRY_ITEM_CONDITION[:production],
      :entry_case =>  DELIVERY_ENTRY_CASE[:normal]
    ).sum("quantity_sent")
  
    confirmed_delivery = self.delivery_entries.where(
      :is_confirmed => true, 
      :is_finalized => true,
      :item_condition => DELIVERY_ENTRY_ITEM_CONDITION[:production],
      :entry_case =>  DELIVERY_ENTRY_CASE[:normal]
    ).sum("quantity_confirmed")
    
    return delivery + confirmed_delivery
  end
  
  def premature_delivery
    delivery = self.delivery_entries.where(
      :is_confirmed => true, 
      :is_finalized => false,
      :item_condition => DELIVERY_ENTRY_ITEM_CONDITION[:production],
      :entry_case =>  DELIVERY_ENTRY_CASE[:premature]
    ).sum("quantity_sent")
    
    confirmed_delivery = self.delivery_entries.where(
      :is_confirmed => true, 
      :is_finalized => true,
      :item_condition => DELIVERY_ENTRY_ITEM_CONDITION[:production],
      :entry_case =>  DELIVERY_ENTRY_CASE[:premature]
    ).sum("quantity_confirmed")
    
    
    return delivery + confirmed_delivery
  end
  
  def cancel_order_delivery
    delivery = self.delivery_entries.where(
      :is_confirmed => true, 
      :is_finalized => false,
      :item_condition => DELIVERY_ENTRY_ITEM_CONDITION[:production],
      :entry_case =>  DELIVERY_ENTRY_CASE[:cancel_post_production_only]
    ).sum("quantity_sent")

    confirmed_delivery =  self.delivery_entries.where(
      :is_confirmed => true, 
      :is_finalized => true,
      :item_condition => DELIVERY_ENTRY_ITEM_CONDITION[:production],
      :entry_case =>  DELIVERY_ENTRY_CASE[:cancel_post_production_only]
    ).sum("quantity_confirmed")
    return delivery + confirmed_delivery
  end
  
  def bad_source_delivery
    
    delivery = self.delivery_entries.where(
      :is_confirmed => true, 
      :is_finalized => false,
      :item_condition => DELIVERY_ENTRY_ITEM_CONDITION[:post_production],
      :entry_case =>  DELIVERY_ENTRY_CASE[:bad_source_fail_post_production]
    ).sum("quantity_sent")

    confirmed_delivery  =  self.delivery_entries.where(
      :is_confirmed => true, 
      :is_finalized => true,
      :item_condition => DELIVERY_ENTRY_ITEM_CONDITION[:post_production],
      :entry_case =>  DELIVERY_ENTRY_CASE[:bad_source_fail_post_production]
    ).sum("quantity_confirmed")
    
    return delivery + confirmed_delivery
  end
  
  def technical_failure_delivery
    delivery = self.delivery_entries.where(
      :is_confirmed => true, 
      :is_finalized => false,
      :item_condition => DELIVERY_ENTRY_ITEM_CONDITION[:post_production],
      :entry_case =>  DELIVERY_ENTRY_CASE[:technical_failure_post_production]
    ).sum("quantity_sent")
    
    confirmed_delivery  = self.delivery_entries.where(
      :is_confirmed => true, 
      :is_finalized => true,
      :item_condition => DELIVERY_ENTRY_ITEM_CONDITION[:post_production],
      :entry_case =>  DELIVERY_ENTRY_CASE[:technical_failure_post_production]
    ).sum("quantity_confirmed")
    
    return delivery + confirmed_delivery
  end
  
  def production_guarantee_return_delivery
    delivery = self.delivery_entries.where(
      :is_confirmed => true, 
      :is_finalized => false,
      :item_condition => DELIVERY_ENTRY_ITEM_CONDITION[:production],
      :entry_case =>  DELIVERY_ENTRY_CASE[:guarantee_return]
    ).sum("quantity_sent")
    
    confirmed_delivery  = self.delivery_entries.where(
      :is_confirmed => true, 
      :is_finalized => true,
      :item_condition => DELIVERY_ENTRY_ITEM_CONDITION[:production],
      :entry_case =>  DELIVERY_ENTRY_CASE[:guarantee_return]
    ).sum("quantity_confirmed")
    
    return delivery + confirmed_delivery
  end
  
  def post_production_guarantee_return_delivery
    delivery = self.delivery_entries.where(
      :is_confirmed => true, 
      :is_finalized => false,
      :item_condition => DELIVERY_ENTRY_ITEM_CONDITION[:post_production],
      :entry_case =>  DELIVERY_ENTRY_CASE[:guarantee_return]
    ).sum("quantity_sent")
    
    confirmed_delivery  = self.delivery_entries.where(
      :is_confirmed => true, 
      :is_finalized => true,
      :item_condition => DELIVERY_ENTRY_ITEM_CONDITION[:post_production],
      :entry_case =>  DELIVERY_ENTRY_CASE[:guarantee_return]
    ).sum("quantity_confirmed")
    
    return delivery + confirmed_delivery
  end
  
  def production_guarantee_return_receival
    all_production_guarantee_return_entries = self.guarantee_return_entries.where(:is_confirmed => true,
      :item_condition => GUARANTEE_RETURN_ENTRY_ITEM_CONDITION[:production] )
      
    quantity_for_production = all_production_guarantee_return_entries.sum('quantity_for_production')
      
    quantity_for_production_repair = all_production_guarantee_return_entries.sum('quantity_for_production_repair')
    
    return  quantity_for_production + quantity_for_production_repair
  end
  
  def post_production_guarantee_return_receival
    all_post_production_guarantee_return_entries = self.guarantee_return_entries.where(:is_confirmed => true,
      :item_condition => GUARANTEE_RETURN_ENTRY_ITEM_CONDITION[:post_production] )
      
    quantity_for_production = all_post_production_guarantee_return_entries.sum('quantity_for_production')
      
    quantity_for_post_production = all_post_production_guarantee_return_entries.sum('quantity_for_post_production')
    
    return  quantity_for_production + quantity_for_post_production
  end
  
  
  
  def pending_fulfillment_post_production
    total = self.quantity_for_post_production
    return total - fulfilled_post_production
  end
  
  def fulfilled_post_production
    delivered = 0 
    if self.is_production and not self.is_post_production
      return 0 
    end
    
    if self.is_production and self.is_post_production
      delivered = normal_post_production_delivery + premature_delivery  
    end
    
    if not self.is_production and self.is_post_production
      delivered = normal_post_production_delivery + cancel_order_delivery + 
            bad_source_delivery + technical_failure_delivery
    end
    
    return delivered 
  end
  
  def pending_fulfillment_production
    total = self.quantity_for_production - self.quantity_for_post_production 
    return total - fulfilled_production
  end
  
  def fulfilled_production
    delivered = 0 
    if self.is_production and not self.is_post_production
      delivered = normal_production_delivery 
    end
    
    if self.is_production and self.is_post_production
      delivered = normal_production_delivery + premature_delivery  
    end
    
    if not self.is_production and self.is_post_production
      return 0 
    end
    
    return delivered
  end
  
  def pending_guarantee_return
     
  end
  
  
  
  def on_delivery
    self.delivery_entries.where(
      :is_confirmed => true, 
      :is_finalized => false 
    ).sum("quantity_sent")
  end
  
=begin
  Guarantee return
=end
  # equal to the number of items @customer 
  def receivable_guarantee_return_normal_production
    # for production type of items 
    return normal_production_delivery + premature_delivery + production_guarantee_return_delivery - 
      production_guarantee_return_receival
  end
  
  def receivable_guarantee_return_normal_post_production
    return normal_post_production_delivery + post_production_guarantee_return_delivery - 
      post_production_guarantee_return_receival
  end
   
  
end