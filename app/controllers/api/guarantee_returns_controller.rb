class Api::GuaranteeReturnsController < Api::BaseApiController
  
  def index
    @objects = GuaranteeReturn.joins(:customer).active_objects.page(params[:page]).per(params[:limit]).order("id DESC")
    @total = GuaranteeReturn.active_objects.count
    # render :json => { :guarantee_returns => @objects , :total => GuaranteeReturn.active_objects.count, :success => true }
  end

  def create
    params[:guarantee_return][:receival_date] = extract_date( params[:guarantee_return][:receival_date] )
    @object = GuaranteeReturn.create_by_employee(current_user,  params[:guarantee_return] )  
    
    
 
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :guarantee_returns => [@object] , 
                        :total => GuaranteeReturn.active_objects.count }  
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
    
    @object = GuaranteeReturn.find_by_id params[:id] 
    params[:guarantee_return][:receival_date] = extract_date( params[:guarantee_return][:receival_date] )
    @object.update_by_employee(current_user,  params[:guarantee_return])
     
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :guarantee_returns => [@object],
                        :total => GuaranteeReturn.active_objects.count  } 
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
    @object = GuaranteeReturn.find(params[:id])
    @object.delete(current_user)

    if ( @object.is_confirmed? and @object.is_deleted) or (  not @object.is_confirmed? and not @object.persisted?)  
      render :json => { :success => true, :total => GuaranteeReturn.active_objects.count }  
    else
      render :json => { 
                  :success => false, 
                  :total => GuaranteeReturn.active_objects.count,
                  :message => {
                    :errors => extjs_error_format( @object.errors )  
                  }
               }  
    end
  end
  
  def confirm
    @object = GuaranteeReturn.find_by_id params[:id]
    # add some defensive programming.. current user has role admin, and current_user is indeed belongs to the company 
    @object.confirm( current_user  )  
    
    if @object.is_confirmed? 
      render :json => { :success => true, :total => GuaranteeReturn.active_objects.count }  
    else
      render :json => { :success => false, :total => GuaranteeReturn.active_objects.count }  
    end
  end
end
