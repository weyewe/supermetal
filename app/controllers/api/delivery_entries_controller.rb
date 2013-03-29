class Api::DeliveryEntriesController < Api::BaseApiController
  
  def index
    @parent = Delivery.find_by_id params[:delivery_id]
    @objects = @parent.active_delivery_entries.joins(:delivery, :sales_item).page(params[:page]).per(params[:limit]).order("id DESC")
    @total = @parent.active_delivery_entries.count
  end

  def create
   
    @parent = Delivery.find_by_id params[:delivery_id]
    @object = DeliveryEntry.create_delivery_entry(current_user, @parent,  params[:delivery_entry] )  
    
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :delivery_entries => [@object] , 
                        :total => @parent.active_delivery_entries.count }  
    else
      msg = {
        :success => false, 
        :message => {
          :errors => extjs_error_format( @object.errors )  
        }
      }
      
      render :json => msg                         
    end
  end

  def update
    @object = DeliveryEntry.find_by_id params[:id] 
    @parent = @object.delivery 
    
    if params[:update_post_delivery].present?  
      @object.update_post_delivery( current_user, params[:delivery_entry] )
    else
      @object.update_delivery_entry(current_user, @parent,  params[:delivery_entry])
    end
    
     
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :delivery_entries => [@object],
                        :total => @parent.active_delivery_entries.count  } 
    else
      msg = {
        :success => false, 
        :message => {
          :errors => extjs_error_format( @object.errors )  
        }
      }
      
      render :json => msg 
    end
  end

  def destroy
    @object = DeliveryEntry.find(params[:id])
    @parent = @object.delivery 
    @object.delete(current_user)

    if ( @object.persisted? and @object.is_deleted ) or ( not @object.persisted? )
      render :json => { :success => true, :total => @parent.active_delivery_entries.count }  
    else
      render :json => { :success => false, :total =>@parent.active_delivery_entries.count }  
    end
  end
  
  def search
    search_params = params[:query]
    selected_id = params[:selected_id]
    if params[:selected_id].nil?  or params[:selected_id].length == 0 
      selected_id = nil
    end
    
    customer_id = params[:customer_id]
    
    query = "%#{search_params}%"
    # on PostGre SQL, it is ignoring lower case or upper case 
    
    if  selected_id.nil?
      @objects = DeliveryEntry.joins(:template_delivery_entry, :delivery ).where{ (template_delivery_entry.name =~ query )   & 
                                (is_deleted.eq false )  & 
                                (delivery.customer_id.eq customer_id)
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
    else
      @objects = DeliveryEntry.joins(:template_delivery_entry, :delivery).where{ (id.eq selected_id)  & 
                                (is_deleted.eq false ) & 
                                (delivery.customer_id.eq customer_id)
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
    end
    
    @total = @objects.count
    @success = true 
    # render :json => { :records => @objects , :total => @objects.count, :success => true }
  end
  
  def search_entry_case
    selected_id = params[:selected_id]
    if not selected_id.present?
      @objects = [
          {
            :value => DELIVERY_ENTRY_CASE[:normal],
            :text => "Normal"
          },
          {
            :value =>  DELIVERY_ENTRY_CASE[:premature],
            :text => "Prematur"
          },
          {
            :value =>  DELIVERY_ENTRY_CASE[:guarantee_return],
            :text => "Garansi"
          },
          {
            :value =>  DELIVERY_ENTRY_CASE[:bad_source_fail_post_production],
            :text => "Keropos"
          },
          {
            :value =>  DELIVERY_ENTRY_CASE[:technical_failure_post_production],
            :text => "Gagal Bubut"
          }
        ]
    else
      puts "In the search entry_case\n"*10
      puts "The selected_id:#{ selected_id.to_i} "
      if selected_id.to_i == DELIVERY_ENTRY_CASE[:normal]
        @objects = [
            {
              :value => DELIVERY_ENTRY_CASE[:normal],
              :text => "Normal"
            }
          ]
      elsif selected_id.to_i == DELIVERY_ENTRY_CASE[:premature]
        @objects = [
            {
              :value => DELIVERY_ENTRY_CASE[:premature],
              :text => "Prematur"
            }
          ]
      elsif selected_id.to_i == DELIVERY_ENTRY_CASE[:guarantee_return]
        @objects = [
            {
              :value => DELIVERY_ENTRY_CASE[:guarantee_return],
              :text => "Garansi"
            }
          ]
      elsif selected_id.to_i == DELIVERY_ENTRY_CASE[:bad_source_fail_post_production]
        @objects = [
            {
              :value => DELIVERY_ENTRY_CASE[:bad_source_fail_post_production],
              :text => "Keropos"
            }
          ]
      elsif selected_id.to_i == DELIVERY_ENTRY_CASE[:technical_failure_post_production]
        @objects = [
            {
              :value => DELIVERY_ENTRY_CASE[:technical_failure_post_production],
              :text => "Gagal Bubut"
            }
          ]
      end
        
    end
    
    @total = @objects.count
    @success = true
  end
  
  def search_item_condition
    selected_id = params[:selected_id]
    
    if not selected_id.present?
      @objects = [
          {
            :value => DELIVERY_ENTRY_ITEM_CONDITION[:production],
            :text => "Hasil Cor"
          },
          {
            :value => DELIVERY_ENTRY_ITEM_CONDITION[:post_production],
            :text => "Hasil Bubut"
          }
        ]
    else
      if selected_id.to_i == DELIVERY_ENTRY_ITEM_CONDITION[:production]
        @objects = [
            {
              :value => DELIVERY_ENTRY_ITEM_CONDITION[:production],
              :text => "Hasil Cor"
            }
          ]
      elsif selected_id.to_i == DELIVERY_ENTRY_ITEM_CONDITION[:post_production]
        @objects = [
            {
              :value => DELIVERY_ENTRY_ITEM_CONDITION[:post_production],
              :text => "Hasil Bubut"
            }
          ]
      end
    end
    
    @total = @objects.count
    @success = true 
  end
end
