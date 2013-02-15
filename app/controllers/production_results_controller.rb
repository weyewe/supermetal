class ProductionResultsController < ApplicationController
  before_filter :role_required, :except => [:generate_result]
  
  def generate_result
    # @sales_item   =  SalesItem.find_by_id params[:selected_sales_item_id]
    # @histories    = @sales_item.production_histories.order("created_at DESC")
    # @sales_order  = @sales_item.sales_order
    # 
    @template_sales_item = TemplateSalesItem.find_by_id params[:selected_id]
    @results = @template_sales_item.production_results.order("created_at DESC")
    @new_object   = ProductionResult.new
  end
  
  def new
    # no idea about shite.. looking forward to get a sales item ID from you
    respond_to do |format|
      format.html {}
      format.js do 
        @parent = TemplateSalesItem.find_by_id params[:template_sales_item_id] 
        @new_object = ProductionResult.new
      end
    end
  end
  
  def create
    # HARD CODE.. just for testing purposes 
    # params[:customer][:town_id] = Town.first.id 
    
    params[:production_result][:start_date] = parse_date( params[:production_result][:started_at] )
    params[:production_result][:finish_date] = parse_date( params[:production_result][:finished_at] )
    @parent = TemplateSalesItem.find_by_id params[:template_sales_item_id] 
    params[:production_result][:template_sales_item_id] = params[:template_sales_item_id]
    @object = ProductionResult.create_result( current_user,   params[:production_result] ) 
    if @object.errors.size == 0 
      @new_object=  ProductionResult.new
    else
      @new_object= @object
    end
    
  end
   
  
  def edit
    # @customer = Customer.find_by_id params[:id] 
    
    
    @parent = TemplateSalesItem.find_by_id params[:template_sales_item_id] 
    @object = ProductionResult.find_by_id params[:id]
  end
  
  def update_production_result
    params[:production_result][:start_date] = parse_date( params[:production_result][:start_date] )
    params[:production_result][:finish_date] = parse_date( params[:production_result][:finish_date] )
    
    
    @object = ProductionResult.find_by_id params[:production_result_id] 
    @parent = @object.template_sales_item 
    @object.update_result( current_user,  params[:production_result])
    @has_no_errors  = @object.errors.size  == 0
  end
  
  def delete_production_result 
    @object = ProductionResult.find_by_id params[:object_to_destroy_id]
    @object_identifier = @object.created_at 
    @parent= @object.template_sales_item
    @object_id = @object.id 
    @object.delete(current_user ) 
  end
  
=begin
  CONFIRM SALES RELATED
=end
  def confirm_production_result
    @production_result = ProductionResult.find_by_id params[:production_result_id]
    # add some defensive programming.. current user has role admin, and current_user is indeed belongs to the company 
    @production_result.confirm( current_user  ) 
    @object =  @production_result
    @parent = @object.template_sales_item  
  end
end
