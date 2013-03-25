class Api::TemplateSalesItemsController < Api::BaseApiController
  
  def index
    if params[:livesearch].present? 
      livesearch = "%#{params[:livesearch]}%"
      @objects = TemplateSalesItem.where{
        (is_deleted.eq false) & 
        (
          (name =~  livesearch )
        )
        
      }.page(params[:page]).per(params[:limit]).order("id DESC")
      
      @total = TemplateSalesItem.where{
        (is_deleted.eq false) & 
        (
          (name =~  livesearch )
        )
      }.count
    else
      @objects = TemplateSalesItem.page(params[:page]).per(params[:limit]).order("id DESC")
      @total = TemplateSalesItem.count
    end
    
    # render :json => { :template_sales_items => @objects , :total => @total , :success => true }
  end

  def create
    @object = TemplateSalesItem.new(params[:template_sales_item])
 
    if @object.save
      render :json => { :success => true, 
                        :template_sales_items => [@object] , 
                        :total => TemplateSalesItem.count }  
    else
      msg = {
        :success => false, 
        :message => {
          :errors => extjs_error_format( @object.errors ) 
          # :errors => {
          #   :name => "Nama tidak boleh bombastic"
          # }
        }
      }
      
      render :json => msg                         
    end
  end

  def update
    @object = TemplateSalesItem.find(params[:id])
    
    if @object.update_attributes(params[:template_sales_item])
      render :json => { :success => true,   
                        :template_sales_items => [@object],
                        :total => TemplateSalesItem.count  } 
    else
      msg = {
        :success => false, 
        :message => {
          :errors => {
            :name => "Nama tidak boleh kosong"
          }
        }
      }
      
      render :json => msg 
    end
  end

  def destroy
    @object = TemplateSalesItem.find(params[:id])
    @object.delete(current_user)

    if @object.is_deleted
      render :json => { :success => true, :total => TemplateSalesItem.count }  
    else
      render :json => { :success => false, :total => TemplateSalesItem.count }  
    end
  end
  
  def search
    search_params = params[:query]
    selected_id = params[:selected_id]
    if params[:selected_id].nil?  or params[:selected_id].length == 0 
      selected_id = nil
    end
    
    query = "%#{search_params}%"
    # on PostGre SQL, it is ignoring lower case or upper case 
    
    if  selected_id.nil?  
      @objects = TemplateSalesItem.where{  
                                (is_deleted.eq false )  & 
                                (
                                  ( name =~ query ) | 
                                  ( code =~ query ) 
                                )
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
    else
      @objects = TemplateSalesItem.where{ (id.eq selected_id)  & 
                                (is_deleted.eq false )
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
    end
    
    
    render :json => { :records => @objects , :total => @objects.count, :success => true }
  end
end
