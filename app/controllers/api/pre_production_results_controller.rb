class Api::PreProductionResultsController < Api::BaseApiController
  
  def index
    @objects = PreProductionResult.joins(:template_sales_item).where(:template_sales_item_id => params[:template_sales_item_id]).page(params[:page]).per(params[:limit]).order("id DESC")
    @total = PreProductionResult.count 
  end

  def create
    params[:pre_production_result][:started_at] = extract_datetime( params[:pre_production_result][:started_at] )
    params[:pre_production_result][:finished_at] = extract_datetime( params[:pre_production_result][:finished_at] )
    @object = PreProductionResult.create_result(current_user,  params[:pre_production_result] )  
    @total =  PreProductionResult.count 
  
  end

  def update
    
    @object = PreProductionResult.find_by_id params[:id] 
    
    params[:pre_production_result][:started_at] = extract_datetime( params[:pre_production_result][:started_at] )
    params[:pre_production_result][:finished_at] = extract_datetime( params[:pre_production_result][:finished_at] )
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

    if not @object.persisted? 
      render :json => { :success => true, :total => PreProductionResult.count }  
    else
      render :json => { :success => false, :total => PreProductionResult.count }  
    end
  end
  
  def confirm
    @object = PreProductionResult.find_by_id params[:id]
    # add some defensive programming.. current user has role admin, and current_user is indeed belongs to the company 
    @object.confirm( current_user  )  
    
    if @object.is_confirmed? 
      render :json => { :success => true, :total => PreProductionResult.count }  
    else
      render :json => { :success => false, :total => PreProductionResult.count }  
    end
  end
end
