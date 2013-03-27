class DeliveryEntry < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :delivery
  belongs_to :sales_item 
  has_one :sales_return_entry
  has_one :delivery_lost_entry 
  
  validates_presence_of :item_condition, :entry_case, :sales_item_id, :template_sales_item_id 
  
  validate   :quantity_sent_is_not_zero_and_less_than_ready_quantity
  validate   :quantity_sent_weight_is_not_zero_and_less_than_ready_quantity 
  validate   :uniqueness_of_sales_item
  validate   :customer_ownership_to_sales_item
  validate :valid_delivery_entry_combination
  belongs_to :template_sales_item 
  
  def quantity_sent_is_not_zero_and_less_than_ready_quantity
    ready_production = self.sales_item.template_sales_item.ready_production
    ready_post_production = self.sales_item.template_sales_item.ready_post_production
    
    if self.item_condition == DELIVERY_ENTRY_ITEM_CONDITION[:production]
      if quantity_sent.present? and (self.is_confirmed == false ) and ( quantity_sent > ready_production  or quantity_sent <= 0 ) 
        errors.add(:quantity_sent , "Kuantitas harus lebih dari 0 dan kurang atau sama dengan #{ready_production}" )  
      end
      
    elsif self.item_condition == DELIVERY_ENTRY_ITEM_CONDITION[:post_production]
      if quantity_sent.present? and (self.is_confirmed == false ) and ( quantity_sent > ready_post_production  or quantity_sent <= 0 ) 
        errors.add(:quantity_sent , "Kuantitas harus lebih dari 0 dan kurang atau sama dengan #{ready_post_production}" )  
      end
    end
  end
  
  def quantity_sent_weight_is_not_zero_and_less_than_ready_quantity
    if  quantity_sent_weight <= BigDecimal('0') 
      errors.add(:quantity_sent_weight , "Berat tidak boleh kurang dari 0kg" )  
    end
  end
  
  def uniqueness_of_sales_item
    # but allow it, if it is from different CASE 
    parent  = self.delivery
    sales_item_id_list = parent.delivery_entries.map{|x| x.sales_item_id }
    post_uniq_sales_item_id_list = sales_item_id_list.uniq 
   
   
    delivery_entry_count = DeliveryEntry.where(
      :sales_item_id => self.sales_item_id,
      :delivery_id => parent.id ,
      :entry_case => self.entry_case,
      :item_condition => self.item_condition 
    ).count 
    
   
    if not self.persisted? and delivery_entry_count != 0
      errors.add(:sales_item_id , "Sales item #{self.sales_item.code} sudah terdaftar di surat jalan" ) 
    elsif self.persisted? and delivery_entry_count != 1 
      errors.add(:sales_item_id , "Sales item #{self.sales_item.code} sudah terdaftar di surat jalan" ) 
    end
  end
  
  def customer_ownership_to_sales_item
    parent = self.delivery
    if delivery.customer_id != self.sales_item.sales_order.customer_id 
      errors.add(:sales_item_id , "Sales item #{self.sales_item.code} tidak terdaftar di daftar penjualan." ) 
    end
  end
  
  
  def valid_delivery_entry_combination
    return nil if self.is_confirmed? 
    
    template_sales_item = sales_item.template_sales_item
    # CASE: only production 
    if sales_item.is_production and not sales_item.is_post_production
      if item_condition == DELIVERY_ENTRY_ITEM_CONDITION[:production] 
        
        # if quantity_sent <= sales_item.pending_fulfilment  # don't block.. keep charging.. doesn't matter
        
        if entry_case == DELIVERY_ENTRY_CASE[:normal] and sales_item.pending_fulfillment_production < quantity_sent  
          errors.add(:entry_case , "Max yang dapat dikirim: #{sales_item.pending_fulfillment_production}" ) 
        elsif entry_case == DELIVERY_ENTRY_CASE[:premature]
          # can't happen
          errors.add(:entry_case , "Hanya ada permintaan untuk casting. Pilihan prematur tidak valid" ) 
        elsif entry_case == DELIVERY_ENTRY_CASE[:guarantee_return] and sales_item.pending_guarantee_return < quantity_sent
          errors.add(:entry_case , "Tidak bisa pengiriman untuk retur garansi. Max: #{sales_item.pending_guarantee_return}" ) 
        elsif entry_case == DELIVERY_ENTRY_CASE[:bad_source_fail_post_production]
          # can't happen
          errors.add(:entry_case , "Hanya ada permintaan untuk casting. pengembalian barang keropos tidak valid" ) 
        elsif entry_case == DELIVERY_ENTRY_CASE[:technical_failure_post_production]
          errors.add(:entry_case , "Hanya ada permintaan untuk casting. Gagal bubut tidak valid" ) 
        elsif entry_case == DELIVERY_ENTRY_CASE[:cancel_post_production_only]
          errors.add(:entry_case , "Hanya ada permintaan untuk casting. Pengembalian batal bubut tidak valid" ) 
        end
          
      end
      
      if item_condition == DELIVERY_ENTRY_ITEM_CONDITION[:post_production] 
        errors.add(:item_condition , "Tidak bisa pengiriman hasil bubut untuk pesanan ini. hanya boleh mengirim hasil cor" ) 
      end
    end
    
    # Case: production + post production 
    if sales_item.is_production and  sales_item.is_post_production
      # if sending out the production ready item 
      if item_condition == DELIVERY_ENTRY_ITEM_CONDITION[:production] 
        
        # if quantity_sent <= sales_item.pending_fulfilment  # don't block.. keep charging.. doesn't matter
        
        if entry_case == DELIVERY_ENTRY_CASE[:normal] and 
            sales_item.pending_fulfillment_production < quantity_sent  
          errors.add(:entry_case , "Tidak bisa pengiriman normal untuk sales item ini. Max: #{sales_item.pending_fulfillment_production}" ) 
        elsif entry_case == DELIVERY_ENTRY_CASE[:premature] and 
              sales_item.pending_fulfillment_post_production > quantity_sent  and
              template_sales_item.ready_production < quantity_sent 
              # case 1. : no post production to be sent, customer needs it urgently 
              # so, sending the production. but, the quantity sent is more than ready production stock
          msg = "Tidak cukup hasil cor untuk pengiriman premature. Max: #{template_sales_item.ready_production}"
          errors.add(:entry_case , msg ) 
        elsif entry_case == DELIVERY_ENTRY_CASE[:premature] and 
              sales_item.pending_fulfillment_post_production < quantity_sent  and
              template_sales_item.ready_production >= quantity_sent 
              # case 1. : no post production to be sent, customer needs it urgently 
              # so, sending the production. but, the quantity sent is more than ready production stock
          msg = "Kelebihan kuantitas pengiriman. Hasil bubut yang belum terkirim: #{sales_item.pending_fulfillment_post_production}"
          errors.add(:entry_case , msg )
        elsif entry_case == DELIVERY_ENTRY_CASE[:guarantee_return]  and sales_item.receivable_guarantee_return_normal_production < quantity_sent
          errors.add(:entry_case , "Tidak bisa pengiriman untuk retur garansi karena item yang dipilih belum dibubut" ) 
        elsif entry_case == DELIVERY_ENTRY_CASE[:bad_source_fail_post_production]
          # can't happen
          errors.add(:entry_case , "Hanya ada permintaan untuk casting. pengembalian barang keropos tidak valid" ) 
        elsif entry_case == DELIVERY_ENTRY_CASE[:technical_failure_post_production]
          errors.add(:entry_case , "Hanya ada permintaan untuk casting. Gagal bubut tidak valid" ) 
        elsif entry_case == DELIVERY_ENTRY_CASE[:cancel_post_production_only]
          errors.add(:entry_case , "Hanya ada permintaan untuk casting. Pengembalian batal bubut tidak valid" ) 
        end
          
      end
   
      # if sendind out the post production ready item 
      if item_condition == DELIVERY_ENTRY_ITEM_CONDITION[:post_production] 

        # if quantity_sent <= sales_item.pending_fulfilment  # don't block.. keep charging.. doesn't matter
        # pending_fulfillment doesn't need to be confirmed 
        if entry_case == DELIVERY_ENTRY_CASE[:normal] and sales_item.pending_fulfillment_post_production < quantity_sent  
          errors.add(:entry_case , "Kelebihan jumlah pengiriman . Max: #{sales_item.pending_fulfillment}" ) 
        elsif entry_case == DELIVERY_ENTRY_CASE[:premature]  
          # can't happen
          errors.add(:item_condition , "Untuk pengiriman premature, pilih jenis barang sebagai hasil bubut" ) 
        elsif entry_case == DELIVERY_ENTRY_CASE[:guarantee_return] and sales_item.receivable_guarantee_return_normal_post_production < quantity_sent
          errors.add(:entry_case , "Kelebihan jumlah untuk pengiriman retur garansi. Max: #{sales_item.pending_guarantee_return}" ) 
        elsif entry_case == DELIVERY_ENTRY_CASE[:bad_source_fail_post_production]
          # can't happen
          errors.add(:entry_case , "Hanya ada permintaan untuk casting. pengembalian barang keropos tidak valid" ) 
        elsif entry_case == DELIVERY_ENTRY_CASE[:technical_failure_post_production]
          errors.add(:entry_case , "Hanya ada permintaan untuk casting. Gagal bubut tidak valid" ) 
        elsif entry_case == DELIVERY_ENTRY_CASE[:cancel_post_production_only] 
          errors.add(:entry_case ,  "Hanya ada permintaan untuk casting. Pengembalian batal bubut tidak valid") 
        end
      end
    end
    
    
    # only post production (pure service)
    if not sales_item.is_production and sales_item.is_post_production
      if item_condition == DELIVERY_ENTRY_ITEM_CONDITION[:production]
        if entry_case == DELIVERY_ENTRY_CASE[:cancel_post_production_only]  and sales_item.template_sales_item.pending_post_production_only_post_production < quantity_sent 
          errors.add(:entry_case , "Tidak bisa pengembalian batal bubut. Max: #{sales_item.template_sales_item.pending_post_production_only_post_production}"  ) 
        else
          # no errors 
        end
        
        if entry_case != DELIVERY_ENTRY_CASE[:cancel_post_production_only]
          errors.add(:item_condition , "Tidak bisa mengeluarkan barang  yang belum di proses, kecuali pengembalian batal bubut" ) 
        end
      end 

      if item_condition == DELIVERY_ENTRY_ITEM_CONDITION[:post_production]
        # if quantity_sent <= sales_item.pending_fulfilment  # don't block.. keep charging.. doesn't matter
        # pending_fulfillment doesn't need to be confirmed 
        if entry_case == DELIVERY_ENTRY_CASE[:normal] and 
            self.is_confirmed == false and sales_item.pending_fulfillment_post_production < quantity_sent  
          errors.add(:entry_case , "Tidak bisa pengiriman normal untuk sales item ini. Max: #{sales_item.pending_fulfillment}" ) 
        elsif entry_case == DELIVERY_ENTRY_CASE[:premature]  
          # can't happen
          errors.add(:entry_case , "Tidak bisa pengiriman prematur untuk sales item ini karena casting tidak dilakukan di sini" ) 
        elsif entry_case == DELIVERY_ENTRY_CASE[:guarantee_return] and
            self.is_confirmed == false and sales_item.pending_guarantee_return < quantity_sent
          errors.add(:entry_case , "Kelebihan jumlah  pengiriman garansi retur. Max: #{sales_item.pending_guarantee_return}" ) 
        elsif entry_case == DELIVERY_ENTRY_CASE[:bad_source_fail_post_production] and
            self.is_confirmed == false and sales_item.template_sales_item.pending_delivery_bad_source < quantity_sent
          errors.add(:entry_case , "Kelebihan jumlah  pengembalian barang keropos. Max: #{sales_item.template_sales_item.pending_delivery_bad_source}" )
        elsif entry_case == DELIVERY_ENTRY_CASE[:technical_failure_post_production] and 
            self.is_confirmed == false and sales_item.template_sales_item.pending_delivery_broken_quantity < quantity_sent
          errors.add(:entry_case , "Kelebihan jumlah  pengembalian pengembalian gagal bubut. Max: #{sales_item.template_sales_item.pending_delivery_broken_quantity}" ) 
        elsif entry_case == DELIVERY_ENTRY_CASE[:cancel_post_production_only] 
          errors.add(:entry_case , "Hanya bisa cancel untuk barang yang belum dibubut"  ) 
        end
      end
    end
    
  end
  
  
  
  def DeliveryEntry.create_delivery_entry( employee, delivery,  params ) 
    return nil if employee.nil?
    sales_item = SalesItem.find_by_id params[:sales_item_id]
    new_object = DeliveryEntry.new
    new_object.creator_id = employee.id 
    new_object.delivery_id = delivery.id 
    new_object.sales_item_id = params[:sales_item_id] 
    new_object.template_sales_item_id = sales_item.template_sales_item_id 
    
    new_object.quantity_sent        = params[:quantity_sent]       
    new_object.quantity_sent_weight = BigDecimal( params[:quantity_sent_weight ])
    new_object.entry_case           = params[:entry_case] 
    new_object.item_condition           = params[:item_condition] 

    
    # new_object.generate_delivery_entry_case
    if new_object.save 
      new_object.generate_code 
      
    end
    
    return new_object 
  end
  
  def update_delivery_entry( employee, delivery,  params ) 
    return nil if employee.nil?
    if self.is_confirmed?
      self.post_confirm_update(employee,  params ) 
      return self 
    end
    
    sales_item = SalesItem.find_by_id params[:sales_item_id]
    self.creator_id           = employee.id 
    self.delivery_id          = delivery.id 
    self.sales_item_id        = params[:sales_item_id] 
    self.template_sales_item_id = sales_item.template_sales_item_id 
    self.quantity_sent        = params[:quantity_sent]       
    self.quantity_sent_weight = BigDecimal( params[:quantity_sent_weight ])
    self.entry_case           = params[:entry_case] 
    self.item_condition           = params[:item_condition]

    # new_object.generate_delivery_entry_case
    if self.save 
    end
    
    return self 
  end
  
  def post_confirm_update(employee,  params ) 
    
    sales_item = SalesItem.find_by_id params[:sales_item_id]
    self.creator_id           = employee.id  
    self.sales_item_id        = params[:sales_item_id] 
    self.template_sales_item_id = sales_item.template_sales_item_id 
    self.quantity_sent        = params[:quantity_sent]       
    self.quantity_sent_weight = BigDecimal( params[:quantity_sent_weight ])
    self.entry_case           = params[:entry_case] 
    self.item_condition           = params[:item_condition]
    
    update_invoice = true 
    if sales_item_id_changed? or quantity_changed? or quantity_sent_weight_changed? or 
      entry_case_changed? or item_condition_changed? 
      update_invoice = true
    else
      update_invoice = false 
    end
    
    self.save 
    
    if update_invoice
      # if there is no invoice, we need to create one 
      # if there is invoice. But, going to be no invoice. Don't delete the pre-existing invoice
      # just mark it as paid, with amount = 0 
      delivery = self.delivery
      # if it is transition from no invoice => with invoice 
      delivery.create_or_update_invoice(employee)
      
      # if payment has been made, we need to rebalance the payment 
      sales_item.update_invoice  
    end
  end
  
  def delete( employee )
    return nil if employee.nil? 
    if self.is_confirmed? or self.is_finalized? 
      ActiveRecord::Base.transaction do
        self.post_confirm_delete( employee) 
      end
      return self
    end
    
    self.destroy 
  end
  
  def post_confirm_delete( employee) 
    invoice = self.delivery.invoice  
    
    delivery = self.delivery 
    sales_return = delivery.sales_return 
    delivery_lost = delivery.delivery_lost 
    
    if not sales_return.nil?
      # delete the sales return entry related with the delivery entry 
      related_sales_return_entry = sales_return.sales_return_entries.where(:delivery_entry_id => self.id ).first 
      
      if not related_sales_return_entry.nil?
        related_sales_return_entry.delete( employee ) 
      end
      
      sales_return.reload 
      if sales_return.sales_return_entries.count == 0 
        sales_return.delete( employee ) 
      end 
    end
    
    if not delivery_lost.nil?
      
      # delete the delivery_lost_entry related with the delivery_entry
      related_delivery_lost_entry = delivery_lost.delivery_lost_entries.where(:delivery_entry_id => self.id ).first 
      
      if not related_delivery_lost_entry.nil?
        related_delivery_lost_entry.delete( employee ) 
      end
      
      
      # if the total delivery_lost_entries == 0 
      # delete the delivery_lost as well
      delivery_lost.reload 
      if delivery_lost.delivery_lost_entries.count == 0 
        delivery_lost.delete( employee ) 
      end
      
    end
    
    self.destroy 
    if not invoice.nil?  
      invoice.propagate_price_change
    end 
  end
  
  def validate_post_production_quantity 
    if quantity_confirmed.nil? or quantity_confirmed < 0 
      self.errors.add(:quantity_confirmed , "Tidak boleh kurang dari 0" ) 
    end
    
    if quantity_returned.nil? or quantity_returned < 0 
      self.errors.add(:quantity_returned , "Tidak boleh kurang dari 0" ) 
    end
    
    if quantity_lost.nil? or quantity_lost < 0 
      self.errors.add(:quantity_lost , "Tidak boleh kurang dari 0" ) 
    end
  end
  
  def validate_post_production_total_sum
    if self.quantity_confirmed + self.quantity_returned + self.quantity_lost != self.quantity_sent 
      msg = "Jumlah yang terkirim: #{self.quantity_sent}. " +
              "Konfirmasi #{self.quantity_confirmed} + " + 
              " Retur #{self.quantity_returned }+ " + 
              " Hilang #{self.quantity_lost} tidak sesuai."
      self.errors.add(:quantity_confirmed , msg ) 
      self.errors.add(:quantity_returned ,  msg ) 
      self.errors.add(:quantity_lost ,      msg ) 
    end
  end
  
  def validate_returned_item_quantity_weight  
    if self.quantity_returned == 0 and self.quantity_returned_weight.to_i !=  0 
      self.errors.add(:quantity_returned_weight , "Tidak ada yang di retur. Harus 0" )  
    end
  end
  
  
  def validate_post_production_update 
    self.validate_post_production_quantity 
    # puts "after validate_post_production_quantity, errors: #{self.errors.size.to_s}"
    
    self.validate_post_production_total_sum   
    # puts "after validate_post_production_total_sum, errors: #{self.errors.size.to_s}"
    
    self.validate_returned_item_quantity_weight 
    # puts "after validate_returned_item_quantity_weight, errors: #{self.errors.size.to_s}"
    
  end
    
  def update_post_delivery( employee, params ) 
    return nil if employee.nil? 
    if self.is_finalized?
      self.post_finalize_update( employee, params)
      return self 
    end 
    
    self.quantity_confirmed        = params[:quantity_confirmed]
    self.quantity_confirmed_weight = BigDecimal( params[:quantity_confirmed_weight] ) 
    


    self.quantity_returned         = params[:quantity_returned]
    self.quantity_returned_weight  = BigDecimal( params[:quantity_returned_weight] )


    self.quantity_lost             = params[:quantity_lost]

    self.validate_post_production_update
    # puts "after validate_post_production_update, errors: #{self.errors.size.to_s}"
    self.errors.messages.each do |message|
      puts "The message: #{message}"
    end
    
    return self if  self.errors.size != 0 
    # puts "Not supposed to be printed out if there is error"
    self.save  
    return self  
  end
  
  def post_finalize_update( employee, params)
    self.quantity_confirmed        = params[:quantity_confirmed]
    self.quantity_confirmed_weight = BigDecimal( params[:quantity_confirmed_weight] ) 

    is_delivery_return_changed = false
    is_delivery_lost_changed = false
    
    if quantity_returned != params[:quantity_returned].to_i
      is_delivery_return_changed = true 
    end
    
    self.quantity_returned         = params[:quantity_returned]
    self.quantity_returned_weight  = BigDecimal( params[:quantity_returned_weight] )

    if quantity_lost != params[:quantity_lost].to_i
      is_delivery_lost_changed = true 
    end
    
    
    self.quantity_lost             = params[:quantity_lost]
    validate_post_production_total_sum
    return self if self.errors.size != 0 
    
    
    
    if self.save   
      delivery = self.delivery 
       
      if is_delivery_return_changed
        sales_return = delivery.sales_return 
        if sales_return.nil?
          SalesReturn.create_by_employee( employee  , delivery  ) 
          # needs to be confirmed 
        else
          sales_return.unconfirm  ## => delete work order 
          
          sales_return_entry = SalesReturnEntry.where(
            :delivery_entry_id  => self.id  ,
            :sales_item_id      => self.sales_item_id ,
            :sales_return_id    => sales_return.id
          ).first 
          
          # unconfirm the sales return  
          # 
          
          
          if sales_return_entry.nil?
            SalesReturnEntry.create_by_employee( employee ,sales_return ,  self )
          else
            # the quantity is computed from delivery entry 
          end
        end
      end
      
      if is_delivery_lost_changed
        delivery_lost = delivery.delivery_lost 
        if delivery_lost.nil?  and self.quantity_lost != 0 
          # from no delivery_lost to something
          DeliveryLost.create_by_employee( employee, delivery )
        else
          delivery_lost_entry = DeliveryLostEntry.where(
            :delivery_entry_id => self.id , 
            :delivery_lost_id  => delivery_lost.id
          )
          
          if  delivery_lost_entry.nil?
            # from no delivery_lost_entry => something 
            delivery_lost_entry = DeliveryLostEntry.create_by_employee( employee , delivery_lost,  self )
            delivery_lost_entry.confirm 
          else
            
            delivery_lost_entry.post_confirm_update 
          end
          
        end
        # from something => something 
        # from something => 0 
        # delete quantity lost, delete the associated production or post production order 
      end
    end 
    sales_item = self.sales_item 
    sales_item.update_invoice  
 
    return self 
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
    
    string = "#{header}DE" + "/" + 
              self.created_at.year.to_s + '/' + 
              self.created_at.month.to_s+ '/' + 
              counter.to_s
              
    self.code =  string 
    self.save 
  end
  
  def validate_pricing_availability
    sales_item = self.sales_item
    
    if sales_item.is_pending_pricing == true  
      errors.add(:pricing , "Harga untuk sales item ini belum tersedia" )  
    end
  end
   
  
  def confirm 
    return nil if self.is_confirmed == true  
    self.is_confirmed = true 
    
    self.save 
    
    self.generate_code
    
    # self.generate_delivery_entry_case 
    
    # validate_pricing_availability
    
    # puts "\n\n"
    # puts "inside the delivery_entry confirm\n"*15
    # puts "Total errors: #{self.errors.size}" 
    # self.errors.messages.each do |msg|
    #   puts "MSG: #{msg}"
    # end
    if  self.errors.size != 0  
      raise ActiveRecord::Rollback, "Call tech support!" 
    end
    
    # sales_item = self.sales_item 
    
    # sales_item.update_on_delivery_confirm
    # sales_item.update_on_delivery_statistics
    # sales_item.update_ready_statistics
  end
  
  def finalize
    return nil if self.is_confirmed == false 
    return nil if self.is_finalized == true 
    
    # puts "finalizing shite\n"*10
    
    # puts "before finalize delivery_entry"
    # puts "confirmed: #{self.quantity_confirmed}"
    # puts "quantity_returned: #{self.quantity_returned}"
    # puts "quantity_lost: #{self.quantity_lost}"
     
    self.validate_post_production_update
    
    if  self.errors.size != 0 
      puts("AAAAAAAAAAAAAAAA THe sibe kia is NOT  valid")
      
      self.errors.messages.each do |key, values| 
        puts "The key is #{key.to_s}"
        values.each do |value|
          puts "\tthe value is #{value}"
        end
      end
      
      raise ActiveRecord::Rollback, "Call tech support!" 
    end
    
    
    
    self.is_finalized = true 
    self.save
    
    
    # puts "&&&&&&&&&&&&&&&&&&BEFORE UPDATING ON FINALIZE\n"*10
    # sales_item = self.sales_item 
    
    # depend on the delivery case 
    # if it is the normal  ( entry_case is according to what it is ordered)
    # if self.normal_delivery_entry? 
    #   sales_item.update_on_delivery_item_finalize 
    # elsif self.entry_case == DELIVERY_ENTRY_CASE[:guarantee_return] 
    #   puts "This is the DELIVERY_ENTRY_CASE[:guarantee_return]\n"*10
    #   sales_item.update_on_guarantee_return_delivery_item_finalize
    # end
    
    
    # if it is the case of guarantee_sales_return 
    # => update pending delivery 
    
    # if it is the case of failure / bad source 
    # => update pending failure / bad source delivery 
    
    # if it is emergency return.. WTF.. ordered post production as well. 
  end
  
  def self.all_selectable_delivery_entry_cases
    result = []
    
    result << [ "#{DELIVERY_ENTRY_CASE_VALUE[:normal]}" , 
                    DELIVERY_ENTRY_CASE[:normal] ] 
                    
    result << [ "#{DELIVERY_ENTRY_CASE_VALUE[:premature]}" , 
                    DELIVERY_ENTRY_CASE[:premature] ] 
    
    result << [ "#{DELIVERY_ENTRY_CASE_VALUE[:guarantee_return]}" , 
                    DELIVERY_ENTRY_CASE[:guarantee_return] ] 
                    
    result << [ "#{DELIVERY_ENTRY_CASE_VALUE[:bad_source_fail_post_production]}" , 
                    DELIVERY_ENTRY_CASE[:bad_source_fail_post_production] ]
                    
    result << [ "#{DELIVERY_ENTRY_CASE_VALUE[:technical_failure_post_production]}" , 
                    DELIVERY_ENTRY_CASE[:technical_failure_post_production] ]
    return result
  end
  
  def self.all_selectable_delivery_entry_item_conditions
    result = []
    
    result << [ "Hasil Cor" , 
                    DELIVERY_ENTRY_ITEM_CONDITION[:production] ] 
                    
    result << [ "Hasil Bubut" , 
                    DELIVERY_ENTRY_ITEM_CONDITION[:post_production] ] 
     
    return result
  end
  
  # def normal_delivery_entry?
  #   sales_item = self.sales_item
  #   if sales_item.only_production?
  #     return self.entry_case == DELIVERY_ENTRY_CASE[:ready_production]
  #   elsif sales_item.is_post_production? 
  #     return self.entry_case == DELIVERY_ENTRY_CASE[:ready_post_production]
  #   end
  # end
  
  def billed_quantity
    quantity = 0 
    if delivery.is_confirmed? and  not delivery.is_finalized? 
      quantity = self.quantity_sent  
    elsif delivery.is_confirmed? and  delivery.is_finalized? 
      quantity = self.quantity_confirmed 
    end
    
    return quantity 
  end
  
  def billed_weight
    weight = 0 
    if delivery.is_confirmed? and  not delivery.is_finalized? 
      weight = self.quantity_sent_weight
    elsif delivery.is_confirmed? and  delivery.is_finalized? 
      weight = self.quantity_confirmed_weight
    end
    
    return weight
  end
  
  def payable_delivery_entry?
    not ( self.entry_case == DELIVERY_ENTRY_CASE[:guarantee_return]  ||
         self.entry_case == DELIVERY_ENTRY_CASE[:technical_failure_post_production]  
      )
  end
  
  def total_delivery_entry_price
    if self.sales_item.is_pending_pricing?
      return BigDecimal("0")
    end
    
    sales_item = self.sales_item 
    quantity = 0 
    weight = BigDecimal('0')
    if delivery.is_confirmed?  and not delivery.is_finalized?
      quantity = self.quantity_sent
      weight = self.quantity_sent_weight 
    elsif  delivery.is_confirmed?  and  delivery.is_finalized?
      quantity = self.quantity_confirmed
      weight = self.quantity_confirmed_weight 
    end 
    
    
    puts "quantity in delivery_entry: #{quantity}"
    total_amount = BigDecimal("0")
    
    if self.item_condition == DELIVERY_ENTRY_ITEM_CONDITION[:production]
      if self.entry_case == DELIVERY_ENTRY_CASE[:normal] or 
          self.entry_case == DELIVERY_ENTRY_CASE[:premature]
        if sales_item.is_pre_production?
          total_amount += sales_item.pre_production_price * quantity
        end

        if sales_item.is_production? 
          if sales_item.is_pricing_by_weight? 
            total_amount += sales_item.production_price * weight
          else
            total_amount += sales_item.production_price * quantity
          end
        end
      elsif self.entry_case == DELIVERY_ENTRY_CASE[:guarantee_return]
        # total amount is 0, by default 
      elsif self.entry_case == DELIVERY_ENTRY_CASE[:bad_source_fail_post_production]  
        #impossible case 
      elsif self.entry_case == DELIVERY_ENTRY_CASE[:technical_failure_post_production]
        #impossible case 
      elsif self.entry_case == DELIVERY_ENTRY_CASE[:cancel_post_production_only]
        #impossible case 
      end
    elsif self.item_condition == DELIVERY_ENTRY_ITEM_CONDITION[:post_production]
      
      puts "item_condition == post production"
      if self.entry_case == DELIVERY_ENTRY_CASE[:normal] 
        # puts "case : normal "
        # puts "quantity: #{quantity}"
        if sales_item.is_pre_production?
          # puts "pre_production_price: #{sales_item.pre_production_price.to_s} "
          total_amount += sales_item.pre_production_price * quantity
        end

        if sales_item.is_production? 
          # puts "production_price: #{sales_item.production_price.to_s} "
          if sales_item.is_pricing_by_weight? 
            total_amount += sales_item.production_price * weight
          else
            total_amount += sales_item.production_price * quantity
          end
        end
        
        if sales_item.is_post_production? 
          # puts "post_production_price: #{sales_item.post_production_price.to_s} "
          total_amount += sales_item.post_production_price * quantity
        end
        
      elsif self.entry_case == DELIVERY_ENTRY_CASE[:premature]
        if sales_item.is_pre_production?
          total_amount += sales_item.pre_production_price * quantity
        end

        if sales_item.is_production? 
          if sales_item.is_pricing_by_weight? 
            total_amount += sales_item.production_price * weight
          else
            total_amount += sales_item.production_price * quantity
          end
        end
      elsif self.entry_case == DELIVERY_ENTRY_CASE[:guarantee_return]
        #free
      elsif self.entry_case == DELIVERY_ENTRY_CASE[:bad_source_fail_post_production] 
        # can only send this out for only_post_production
         if sales_item.is_pre_production?
           total_amount += sales_item.pre_production_price * quantity
         end

         if sales_item.is_production? 
           if sales_item.is_pricing_by_weight? 
             total_amount += sales_item.production_price * weight
           else
             total_amount += sales_item.production_price * quantity
           end
         end

         if sales_item.is_post_production? 
           total_amount += sales_item.post_production_price * quantity
         end
      elsif self.entry_case == DELIVERY_ENTRY_CASE[:technical_failure_post_production]
        #free , only available for post production 
      elsif self.entry_case == DELIVERY_ENTRY_CASE[:cancel_post_production_only]
        # return total_amount 
      end
    end
    
   
    
    return total_amount
  end
  
  def item_condition_name
    if self.item_condition == DELIVERY_ENTRY_ITEM_CONDITION[:production]
      return "Cor"
    elsif self.item_condition == DELIVERY_ENTRY_ITEM_CONDITION[:post_production]
      return "Bubut"
    end
  end
  
  def entry_case_name
    if self.entry_case == DELIVERY_ENTRY_CASE[:normal]
      return "Normal"
    elsif self.entry_case == DELIVERY_ENTRY_CASE[:premature]
      return "Prematur"
    elsif self.entry_case == DELIVERY_ENTRY_CASE[:guarantee_return]
      return "Garansi"
    elsif self.entry_case == DELIVERY_ENTRY_CASE[:bad_source_fail_post_production]
      return "Keropos"
    elsif self.entry_case == DELIVERY_ENTRY_CASE[:technical_failure_post_production]
      return "Gagal bubut"
    end
  end
  
end
