class ItemReceivalsController < ApplicationController
  before_filter :role_required
  def new
    @objects = ItemReceival.order("created_at DESC")
    @new_object = ItemReceival.new 
    add_breadcrumb "Surat Jalan", 'new_item_receival_url'
  end
  
  def create
    # HARD CODE.. just for testing purposes 
    # params[:customer][:town_id] = Town.first.id 
    
    params[:item_receival][:receival_date] = parse_date( params[:item_receival][:receival_date] )
    @object = ItemReceival.create_by_employee( current_user, params[:item_receival] ) 
    if @object.errors.size == 0 
      @new_object=  ItemReceival.new
    else
      @new_object= @object
    end
  end
  
  
  
  def edit
    # @customer = Customer.find_by_id params[:id] 
    @object = ItemReceival.find_by_id params[:id]
  end
  
  def update_item_receival
    params[:item_receival][:receival_date] = parse_date( params[:item_receival][:receival_date] )
    @object = ItemReceival.find_by_id params[:item_receival_id] 
    @object.update_by_employee( current_user, params[:item_receival])
    @has_no_errors  = @object.errors.size  == 0
  end
  
  def delete_item_receival
    @object = ItemReceival.find_by_id params[:object_to_destroy_id]
    @object_identifier = @object.code 
    @object.delete(current_user) 
  end
  
=begin
  CONFIRM SALES RELATED
=end
  def confirm_item_receival
    @item_receival = ItemReceival.find_by_id params[:item_receival_id]
    # add some defensive programming.. current user has role admin, and current_user is indeed belongs to the company 
    @item_receival.confirm( current_user  )  
    @item_receival.reload
  end
 
=begin
  DETAILS
=end
   
  def details
    puts "We are in the details of sales order\n"*50
    @object = ItemReceival.find_by_id params[:id]
  end
  
  def search_item_receival
    search_params = params[:q]

    @objects = [] 
    query = '%' + search_params + '%'
    # on PostGre SQL, it is ignoring lower case or upper case 
    @objects = ItemReceival.where{ (code =~ query)  &
                      (is_deleted.eq false) & 
                      (is_confirmed.eq true) }.map do |x| 
                        {
                          :code => x.code, 
                          :id => x.id 
                        }
                      end

    respond_to do |format|
      format.html # show.html.erb 
      format.json { render :json => @objects }
    end
  end

  def generate_details 
    @parent = ItemReceival.find_by_id params[:item_receival][:search_record_id]
    @children = @parent.item_receival_entries.order("created_at DESC") 
  end
  
 
end 
