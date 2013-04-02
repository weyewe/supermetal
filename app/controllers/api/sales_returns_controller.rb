class Api::SalesReturnsController < Api::BaseApiController
  
  def index
    if params[:livesearch].present? 
      livesearch = "%#{params[:livesearch]}%"
      @objects = SalesReturn.joins(:delivery => [:customer]).where{
        (
          (code =~  livesearch ) | 
          (delivery.code =~  livesearch ) | 
          (delivery.customer.name =~ livesearch)
        )
        
      }.page(params[:page]).per(params[:limit]).order("id DESC")
      
      @total = Delivery.joins(:customer).where{
        (
          (code =~  livesearch ) | 
          (delivery.code =~  livesearch ) | 
          (delivery.customer.name =~ livesearch)
        )
      }.count
    else
      @objects = SalesReturn.joins(  :delivery => [:customer]).active_objects.page(params[:page]).per(params[:limit]).order("id DESC")
      @total = SalesReturn.active_objects.count
    end
    
    
    # render :json => { :sales_returns => @objects , :total => SalesReturn.active_objects.count, :success => true }
  end

  # def create
  #   @object = SalesReturn.create_by_employee(current_user,  params[:sales_return] )  
  #   
  #   
  #  
  #   if @object.errors.size == 0 
  #     render :json => { :success => true, 
  #                       :sales_returns => [@object] , 
  #                       :total => SalesReturn.active_objects.count }  
  #   else
  #     msg = {
  #       :success => false, 
  #       :message => {
  #         :errors => extjs_error_format( @object.errors )  
  #       }
  #     }
  #     
  #     render :json => msg                         
  #   end
  # end
  # 
  # def update
  #   
  #   @object = SalesReturn.find_by_id params[:id] 
  #   @object.update_by_employee(current_user,  params[:sales_return])
  #    
  #   if @object.errors.size == 0 
  #     render :json => { :success => true,   
  #                       :sales_returns => [@object],
  #                       :total => SalesReturn.active_objects.count  } 
  #   else
  #     msg = {
  #       :success => false, 
  #       :message => {
  #         :errors => extjs_error_format( @object.errors )  
  #       }
  #     }
  #     
  #     render :json => msg 
  #   end
  # end
  # 
  # def destroy
  #   @object = SalesReturn.find(params[:id])
  #   @object.delete(current_user)
  # 
  #   if ( @object.is_confirmed? and @object.is_deleted) or (  not @object.is_confirmed? and not @object.persisted?)  
  #     render :json => { :success => true, :total => SalesReturn.active_objects.count }  
  #   else
  #     render :json => { 
  #                 :success => false, 
  #                 :total => SalesReturn.active_objects.count,
  #                 :message => {
  #                   :errors => extjs_error_format( @object.errors )  
  #                 }
  #              }  
  #   end
  # end
  
  def confirm
    @object = SalesReturn.find_by_id params[:id]
    # add some defensive programming.. current user has role admin, and current_user is indeed belongs to the company 
    @object.confirm( current_user  )  
    
    if @object.is_confirmed? 
      render :json => { :success => true, :total => SalesReturn.active_objects.count }  
    else
      render :json => { :success => false, :total => SalesReturn.active_objects.count }  
    end
  end
end
