class Api::GuaranteeReturnEntriesController < Api::BaseApiController
  
  def index
    @parent = GuaranteeReturn.find_by_id params[:guarantee_return_id]
    @objects = @parent.active_guarantee_return_entries.joins(:guarantee_return).page(params[:page]).per(params[:limit]).order("id DESC")
    @total = @parent.active_guarantee_return_entries.count
  end

  def create
   
    @parent = GuaranteeReturn.find_by_id params[:guarantee_return_id]
    @object = GuaranteeReturnEntry.create_guarantee_return_entry(current_user, @parent,  params[:guarantee_return_entry] )  
    
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :guarantee_return_entries => [@object] , 
                        :total => @parent.active_guarantee_return_entries.count }  
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
    @object = GuaranteeReturnEntry.find_by_id params[:id] 
    @parent = @object.guarantee_return 
    @object.update_guarantee_return_entry(current_user, @parent,  params[:guarantee_return_entry])
     
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :guarantee_return_entries => [@object],
                        :total => @parent.active_guarantee_return_entries.count  } 
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
    @object = GuaranteeReturnEntry.find(params[:id])
    @parent = @object.guarantee_return 
    @object.delete(current_user)

    if ( @object.persisted? and @object.is_deleted ) or ( not @object.persisted? )
      render :json => { :success => true, :total => @parent.active_guarantee_return_entries.count }  
    else
      render :json => { :success => false, :total =>@parent.active_guarantee_return_entries.count }  
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
      @objects = GuaranteeReturnEntry.joins(  :guarantee_return ).where{ (template_guarantee_return_entry.name =~ query )   & 
                                (is_deleted.eq false )  & 
                                (guarantee_return.customer_id.eq customer_id)
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
    else
      @objects = GuaranteeReturnEntry.joins( :guarantee_return).where{ (id.eq selected_id)  & 
                                (is_deleted.eq false ) & 
                                (guarantee_return.customer_id.eq customer_id)
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
