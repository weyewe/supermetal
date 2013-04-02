class Api::SalesItemsController < Api::BaseApiController
  
  def index
    @parent = SalesOrder.find_by_id params[:sales_order_id]
    @objects = @parent.active_sales_items.joins(:sales_order).page(params[:page]).per(params[:limit]).order("id DESC")
    @total = @parent.active_sales_items.count
  end

  def create
   
    @parent = SalesOrder.find_by_id params[:sales_order_id]
    
    if params[:sales_item][:is_repeat_order].present? and params[:sales_item][:is_repeat_order] == true 
      puts 'In the repeat order block\n'*10
      @object = SalesItem.create_derivative_sales_item( current_user, @parent,  params[:sales_item] )
    else
      @object = SalesItem.create_sales_item(current_user, @parent,  params[:sales_item] )  
    end
    
    
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :sales_items => [@object] , 
                        :total => @parent.active_sales_items.count }  
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
    @object = SalesItem.find_by_id params[:id] 
    @parent = @object.sales_order 
    
    
    if params[:sales_item][:is_repeat_order].present? and params[:sales_item][:is_repeat_order] == true 
      @object.update_derivative_sales_item(current_user, params[:sales_item])
    else
      @object.update_sales_item(current_user,  params[:sales_item])
    end
    
    
    
     
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :sales_items => [@object],
                        :total => @parent.active_sales_items.count  } 
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
    @object = SalesItem.find(params[:id])
    @parent = @object.sales_order 
    @object.delete(current_user)

    if ( @object.persisted? and @object.is_deleted ) or ( not @object.persisted? )
      render :json => { :success => true, :total => @parent.active_sales_items.count }  
    else
      render :json => { :success => false, :total =>@parent.active_sales_items.count }  
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
      
      if params[:only_post_production].present?
        @objects = SalesItem.joins(:template_sales_item, :sales_order ).where{ (template_sales_item.name =~ query )   & 
                                  (is_deleted.eq false )  & 
                                  (sales_order.customer_id.eq customer_id) & 
                                  (is_pre_production.eq false) & 
                                  (is_production.eq false )  & 
                                  (is_post_production.eq true ) 
                                }.
                          page(params[:page]).
                          per(params[:limit]).
                          order("id DESC")
      else
        @objects = SalesItem.joins(:template_sales_item, :sales_order ).where{ (template_sales_item.name =~ query )   & 
                                  (is_deleted.eq false )  & 
                                  (sales_order.customer_id.eq customer_id)
                                }.
                          page(params[:page]).
                          per(params[:limit]).
                          order("id DESC")
      end
      
    else
      @objects = SalesItem.joins(:template_sales_item, :sales_order).where{ (id.eq selected_id)  & 
                                (is_deleted.eq false ) & 
                                (sales_order.customer_id.eq customer_id)
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
    end
    
    @total = @objects.count
    @success = true 
    # render :json => { :records => @objects , :total => @objects.count, :success => true }
  end
  
 
end
