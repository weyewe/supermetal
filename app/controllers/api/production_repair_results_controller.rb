class Api::ProductionRepairResultsController < Api::BaseApiController
  
  def index
    @objects = ProductionRepairResult.joins(:template_sales_item).where(:template_sales_item_id => params[:template_sales_item_id]).page(params[:page]).per(params[:limit]).order("id DESC")
    @total = ProductionRepairResult.count 
  end

  def create
    params[:production_repair_result][:started_at] = extract_datetime( params[:production_repair_result][:started_at] )
    params[:production_repair_result][:finished_at] = extract_datetime( params[:production_repair_result][:finished_at] )
    @object = ProductionRepairResult.create_result(current_user,  params[:production_repair_result] )  
    @total =  ProductionRepairResult.count 
  
  end

  def update
    
    @object = ProductionRepairResult.find_by_id params[:id] 
    
    params[:production_repair_result][:started_at] = extract_datetime( params[:production_repair_result][:started_at] )
    params[:production_repair_result][:finished_at] = extract_datetime( params[:production_repair_result][:finished_at] )
    @object.update_result(current_user,  params[:production_repair_result])
     
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :production_repair_results => [@object],
                        :total => ProductionRepairResult.count  } 
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
    @object = ProductionRepairResult.find(params[:id])
    @object.delete(current_user)

    if not @object.persisted? 
      render :json => { :success => true, :total => ProductionRepairResult.count }  
    else
      render :json => { :success => false, :total => ProductionRepairResult.count }  
    end
  end
  
  def confirm
    @object = ProductionRepairResult.find_by_id params[:id]
    # add some defensive programming.. current user has role admin, and current_user is indeed belongs to the company 
    @object.confirm( current_user  )  
    
    if @object.is_confirmed? 
      render :json => { :success => true, :total => ProductionRepairResult.count }  
    else
      render :json => { :success => false, :total => ProductionRepairResult.count }  
    end
  end
end
