class Api::PostProductionResultsController < Api::BaseApiController
  
  def index
    @objects = PostProductionResult.joins(:template_sales_item).where(:template_sales_item_id => params[:template_sales_item_id]).page(params[:page]).per(params[:limit]).order("id DESC")
    @total = PostProductionResult.count 
  end

  def create
    params[:post_production_result][:started_at] = extract_datetime( params[:post_production_result][:started_at] )
    params[:post_production_result][:finished_at] = extract_datetime( params[:post_production_result][:finished_at] )
    @object = PostProductionResult.create_result(current_user,  params[:post_production_result] )  
    @total =  PostProductionResult.count 
  
  end

  def update
    
    @object = PostProductionResult.find_by_id params[:id] 
    
    params[:post_production_result][:started_at] = extract_datetime( params[:post_production_result][:started_at] )
    params[:post_production_result][:finished_at] = extract_datetime( params[:post_production_result][:finished_at] )
    @object.update_result(current_user,  params[:post_production_result])
     
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :post_production_results => [@object],
                        :total => PostProductionResult.count  } 
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
    @object = PostProductionResult.find(params[:id])
    @object.delete(current_user)

    if not @object.persisted? 
      render :json => { :success => true, :total => PostProductionResult.count }  
    else
      render :json => { :success => false, :total => PostProductionResult.count }  
    end
  end
  
  def confirm
    @object = PostProductionResult.find_by_id params[:id]
    # add some defensive programming.. current user has role admin, and current_user is indeed belongs to the company 
    @object.confirm( current_user  )  
    
    if @object.is_confirmed? 
      render :json => { :success => true, :total => PostProductionResult.count }  
    else
      render :json => { :success => false, :total => PostProductionResult.count }  
    end
  end
end
