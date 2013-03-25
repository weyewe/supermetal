class Api::PreProductionResultsController < Api::BaseApiController
  
  def index
    @objects = PreProductionResult.where(:template_sales_item_id => params[:template_sales_item_id]).page(params[:page]).per(params[:limit]).order("id DESC")
    render :json => { :pre_production_results => @objects , :total => PreProductionResult.count, :success => true }
  end

  def create
    params[:pre_production_result][:started_at] = extract_datetime( params[:pre_production_result][:started_at].getutc )
    params[:pre_production_result][:finished_at] = extract_datetime( params[:pre_production_result][:finished_at].getutc )
    @object = PreProductionResult.create_result(current_user,  params[:pre_production_result] )  
    
    # get the datetime => separated
    # it is GMT+7 time.. convert to GMT +0 
    
    return 
 
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :pre_production_results => [@object] , 
                        :total => PreProductionResult.count }  
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
    
    @object = PreProductionResult.find_by_id params[:id] 
    
    params[:pre_production_result][:started_at] = extract_datetime( params[:pre_production_result][:started_at].getutc )
    params[:pre_production_result][:finished_at] = extract_datetime( params[:pre_production_result][:finished_at].getutc )
    @object.update_result(current_user,  params[:pre_production_result])
     
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :pre_production_results => [@object],
                        :total => PreProductionResult.count  } 
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
    @object = PreProductionResult.find(params[:id])
    @object.delete(current_user)

    if @object.is_deleted
      render :json => { :success => true, :total => PreProductionResult.count }  
    else
      render :json => { :success => false, :total => PreProductionResult.count }  
    end
  end
end
