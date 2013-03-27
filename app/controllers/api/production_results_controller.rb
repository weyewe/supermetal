class Api::ProductionResultsController < Api::BaseApiController
  
  def index
    @objects = ProductionResult.joins(:template_sales_item).where(:template_sales_item_id => params[:template_sales_item_id]).page(params[:page]).per(params[:limit]).order("id DESC")
    @total = ProductionResult.count 
  end

  def create
    params[:production_result][:started_at] = extract_datetime( params[:production_result][:started_at] )
    params[:production_result][:finished_at] = extract_datetime( params[:production_result][:finished_at] )
    @object = ProductionResult.create_result(current_user,  params[:production_result] )  
    @total =  ProductionResult.count 
  
  end

  def update
    
    @object = ProductionResult.find_by_id params[:id] 
    
    params[:production_result][:started_at] = extract_datetime( params[:production_result][:started_at] )
    params[:production_result][:finished_at] = extract_datetime( params[:production_result][:finished_at] )
    @object.update_result(current_user,  params[:production_result])
     
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :production_results => [@object],
                        :total => ProductionResult.count  } 
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
    @object = ProductionResult.find(params[:id])
    @object.delete(current_user)

    if not @object.persisted? 
      render :json => { :success => true, :total => ProductionResult.count }  
    else
      render :json => { :success => false, :total => ProductionResult.count }  
    end
  end
  
  def confirm
    @object = ProductionResult.find_by_id params[:id]
    # add some defensive programming.. current user has role admin, and current_user is indeed belongs to the company 
    @object.confirm( current_user  )  
    
    if @object.is_confirmed? 
      render :json => { :success => true, :total => ProductionResult.count }  
    else
      render :json => { :success => false, :total => ProductionResult.count }  
    end
  end
end
