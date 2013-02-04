class SalesItem < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :sales_order
  belongs_to :customer 
  belongs_to :template_sales_item 
  belongs_to :sales_item_subcription
  
  
  has_many :pre_production_orders
  has_many :production_orders
  has_many :post_production_orders
  
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
  validates_presence_of :weight_per_piece
  validates_presence_of :quantity 
  validates_presence_of :case 
  
  validate :material_must_present_if_production_is_true 
  validate :delivery_address_must_present_if_delivered_is_true 
  validate :quantity_must_be_at_least_one
  validate  :weight_per_piece_must_not_be_less_than_zero
  
   
  
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
  
  def quantity_must_be_at_least_one
    if not quantity.present? or quantity <= 0 
      errors.add(:quantity , "Quantity harus setidaknya 1" )  
    end
  end
  
  
  def weight_per_piece_must_not_be_less_than_zero
    if  weight_per_piece <= BigDecimal('0')
      errors.add(:weight_per_piece , "Berat satuan tidak boleh kurang dari 0 kg" )  
    end
  end
  
  
  
  def delete(employee)
    return nil if employee.nil?
    return nil if self.is_confirmed? 
    
    self.destroy 
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
    new_object.quantity              = params[:quantity]          
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
  
  def update_sales_item( params ) 
    return nil if self.is_confirmed? 
    
    self.material_id           = params[:material_id]       
    self.is_pre_production     = params[:is_pre_production] 
    self.is_production       = params[:is_production]     
    # self.is_production         = true # by default 
    self.is_post_production    = params[:is_post_production]
    self.is_delivered          = params[:is_delivered]      
    self.delivery_address      = params[:delivery_address]  
    self.weight_per_piece      = BigDecimal( params[:weight_per_piece ])
    self.quantity              = params[:quantity]          
    self.description           = params[:description]   
    self.name                  = params[:name]
    
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
    new_object.quantity               = params[:quantity]  
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
    
    self.quantity              = params[:quantity]
    
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
    
    if self.only_machining?
       
    elsif self.casting_included?
      
      # self.update_on_confirm 
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
  
  
  
  
end
