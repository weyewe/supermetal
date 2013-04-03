class Api::ItemReceivalEntriesController < Api::BaseApiController
  
  def index
    @parent = ItemReceival.find_by_id params[:item_receival_id]
    @objects = @parent.active_item_receival_entries.joins(:item_receival).page(params[:page]).per(params[:limit]).order("id DESC")
    @total = @parent.active_item_receival_entries.count
  end

  def create
   
    @parent = ItemReceival.find_by_id params[:item_receival_id]
    
    params[:item_receival_entry][:receival_date] = extract_date( params[:item_receival_entry][:receival_date] )
    @object = ItemReceivalEntry.create_item_receival_entry(current_user, @parent,  params[:item_receival_entry] )  
    
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :item_receival_entries => [@object] , 
                        :total => @parent.active_item_receival_entries.count }  
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
    @object = ItemReceivalEntry.find_by_id params[:id] 
    @parent = @object.item_receival 
    
    params[:item_receival][:receival_date] = extract_date( params[:item_receival][:receival_date] )
    @object.update_item_receival_entry(current_user, @parent,  params[:item_receival_entry])
     
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :item_receival_entries => [@object],
                        :total => @parent.active_item_receival_entries.count  } 
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
    @object = ItemReceivalEntry.find(params[:id])
    @parent = @object.item_receival 
    @object.delete(current_user)

    if  ( not @object.persisted? )
      render :json => { :success => true, :total => @parent.active_item_receival_entries.count }  
    else
      render :json => { :success => false, :total =>@parent.active_item_receival_entries.count }  
    end
  end
  
  # def search
  #   search_params = params[:query]
  #   selected_id = params[:selected_id]
  #   if params[:selected_id].nil?  or params[:selected_id].length == 0 
  #     selected_id = nil
  #   end
  #   
  #   customer_id = params[:customer_id]
  #   
  #   query = "%#{search_params}%"
  #   # on PostGre SQL, it is ignoring lower case or upper case 
  #   
  #   if  selected_id.nil?
  #     @objects = ItemReceivalEntry.joins(  :item_receival ).where{ (template_item_receival_entry.name =~ query )   & 
  #                               (is_deleted.eq false )  & 
  #                               (item_receival.customer_id.eq customer_id)
  #                             }.
  #                       page(params[:page]).
  #                       per(params[:limit]).
  #                       order("id DESC")
  #   else
  #     @objects = ItemReceivalEntry.joins( :item_receival).where{ (id.eq selected_id)  & 
  #                               (is_deleted.eq false ) & 
  #                               (item_receival.customer_id.eq customer_id)
  #                             }.
  #                       page(params[:page]).
  #                       per(params[:limit]).
  #                       order("id DESC")
  #   end
  #   
  #   @total = @objects.count
  #   @success = true 
  #   # render :json => { :records => @objects , :total => @objects.count, :success => true }
  # end
end
