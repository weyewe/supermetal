class Api::InvoicesController < Api::BaseApiController
  
  def index
    @objects = Invoice.joins(:customer, :delivery).page(params[:page]).per(params[:limit]).order("id DESC")
    @total = Invoice.count
    # render :json => { :invoices => @objects , :total => Invoice.count, :success => true }
  end

  # def create
  #   @object = Invoice.create_by_employee(current_user,  params[:invoice] )  
  #   
  #   
  #  
  #   if @object.errors.size == 0 
  #     render :json => { :success => true, 
  #                       :invoices => [@object] , 
  #                       :total => Invoice.count }  
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

  def update
    
    @object = Invoice.find_by_id params[:id] 
    
    due_date =  extract_date(params[:invoice][:due_date])
    @object.update_due_date( current_user, due_date )
     
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :invoices => [@object],
                        :total => Invoice.count  } 
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

  # def destroy
  #   @object = Invoice.find(params[:id])
  #   @object.delete(current_user)
  # 
  #   if ( @object.is_confirmed? and @object.is_deleted) or (  not @object.is_confirmed? and not @object.persisted?)  
  #     render :json => { :success => true, :total => Invoice.count }  
  #   else
  #     render :json => { 
  #                 :success => false, 
  #                 :total => Invoice.count,
  #                 :message => {
  #                   :errors => extjs_error_format( @object.errors )  
  #                 }
  #              }  
  #   end
  # end
  # 
  # def confirm
  #   @object = Invoice.find_by_id params[:id]
  #   # add some defensive programming.. current user has role admin, and current_user is indeed belongs to the company 
  #   @object.confirm( current_user  )  
  #   
  #   if @object.is_confirmed? 
  #     render :json => { :success => true, :total => Invoice.count }  
  #   else
  #     render :json => { :success => false, :total => Invoice.count }  
  #   end
  # end
  
  def search
    search_params = params[:query]
    selected_id = params[:selected_id]
    if params[:selected_id].nil?  or params[:selected_id].length == 0 
      selected_id = nil
    end
    
    selected_customer_id = params[:customer_id]
    
    query = "%#{search_params}%"
    # on PostGre SQL, it is ignoring lower case or upper case 
    
    if  selected_id.nil?
      @objects = Invoice.joins(:delivery, :customer ).where{ (code  =~ query )   & 
                                (customer_id.eq selected_customer_id)
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
    else
      @objects = Invoice.joins(:delivery, :customer).where{ (id.eq selected_id)  & 
                                (customer_id.eq customer_id)
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
