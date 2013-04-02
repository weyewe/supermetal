class Api::DeliveriesController < Api::BaseApiController
  
  def index
    
    if params[:livesearch].present? 
      livesearch = "%#{params[:livesearch]}%"
      @objects = Delivery.joins(:customer).where{
        (is_deleted.eq false) & 
        (
          (code =~  livesearch ) | 
          (customer.name =~ livesearch)
        )
        
      }.page(params[:page]).per(params[:limit]).order("id DESC")
      
      @total = Delivery.joins(:customer).where{
        (is_deleted.eq false) & 
        (
          (code =~  livesearch ) | 
          (customer.name =~ livesearch)
        )
      }.count
    else
      @objects = Delivery.joins(:customer).active_objects.page(params[:page]).per(params[:limit]).order("id DESC")
      @total = Delivery.active_objects.count
    end
    
    
    
    # render :json => { :deliveries => @objects , :total => Delivery.active_objects.count, :success => true }
  end

  def create
    @object = Delivery.create_by_employee(current_user,  params[:delivery] )  
    
    
 
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :deliveries => [@object] , 
                        :total => Delivery.active_objects.count }  
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
    
    @object = Delivery.find_by_id params[:id] 
    @object.update_by_employee(current_user,  params[:delivery])
     
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :deliveries => [@object],
                        :total => Delivery.active_objects.count  } 
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
    @object = Delivery.find(params[:id])
    @object.delete(current_user)

    if ( @object.is_confirmed? and @object.is_deleted) or (  not @object.is_confirmed? and not @object.persisted?)  
      render :json => { :success => true, :total => Delivery.active_objects.count }  
    else
      render :json => { 
                  :success => false, 
                  :total => Delivery.active_objects.count,
                  :message => {
                    :errors => extjs_error_format( @object.errors )  
                  }
               }  
    end
  end
  
  def confirm
    @object = Delivery.find_by_id params[:id]
    # add some defensive programming.. current user has role admin, and current_user is indeed belongs to the company 
    @object.confirm( current_user  )  
    
    if @object.is_confirmed? 
      render :json => { :success => true, :total => Delivery.active_objects.count }  
    else
      render :json => { :success => false, :total => Delivery.active_objects.count }  
    end
  end
  
  def finalize
     @object = Delivery.find_by_id params[:id]
      # add some defensive programming.. current user has role admin, and current_user is indeed belongs to the company 
      @object.finalize( current_user  )  

      if @object.is_finalized? 
        render :json => { :success => true, :total => Delivery.active_objects.count }  
      else
        render :json => { :success => false, :total => Delivery.active_objects.count }  
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
      @objects = Delivery.joins( :customer ).where{ ( code =~ query )   & 
                                (is_deleted.eq false ) 
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
    else
      @objects = SalesItem.joins( :customer).where{ (id.eq selected_id)  & 
                                (is_deleted.eq false )  
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
