class Api::ItemReceivalsController < Api::BaseApiController
  
  def index
    @objects = ItemReceival.joins(:customer).active_objects.page(params[:page]).per(params[:limit]).order("id DESC")
    @total = ItemReceival.active_objects.count
    # render :json => { :item_receivals => @objects , :total => ItemReceival.active_objects.count, :success => true }
  end

  def create
    params[:item_receival][:receival_date] = extract_date( params[:item_receival][:receival_date] )
    @object = ItemReceival.create_by_employee(current_user,  params[:item_receival] )  
    
    
 
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :item_receivals => [@object] , 
                        :total => ItemReceival.active_objects.count }  
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
    
    @object = ItemReceival.find_by_id params[:id] 
    params[:item_receival][:receival_date] = extract_date( params[:item_receival][:receival_date] )
    @object.update_by_employee(current_user,  params[:item_receival])
     
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :item_receivals => [@object],
                        :total => ItemReceival.active_objects.count  } 
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
    @object = ItemReceival.find(params[:id])
    @object.delete(current_user)

    if ( @object.is_confirmed? and @object.is_deleted) or (  not @object.is_confirmed? and not @object.persisted?)  
      render :json => { :success => true, :total => ItemReceival.active_objects.count }  
    else
      render :json => { 
                  :success => false, 
                  :total => ItemReceival.active_objects.count,
                  :message => {
                    :errors => extjs_error_format( @object.errors )  
                  }
               }  
    end
  end
  
  def confirm
    @object = ItemReceival.find_by_id params[:id]
    # add some defensive programming.. current user has role admin, and current_user is indeed belongs to the company 
    @object.confirm( current_user  )  
    
    if @object.is_confirmed? 
      render :json => { :success => true, :total => ItemReceival.active_objects.count }  
    else
      render :json => { :success => false, :total => ItemReceival.active_objects.count }  
    end
  end
end
