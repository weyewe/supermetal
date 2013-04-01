class Api::PaymentsController < Api::BaseApiController
  
  def index
    @objects = Payment.joins(:customer, :cash_account).page(params[:page]).per(params[:limit]).order("id DESC")
    @total = Payment.count
    # render :json => { :payments => @objects , :total => Payment.count, :success => true }
  end

  def create
    @object = Payment.create_by_employee(current_user,  params[:payment] )  
    
    
 
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :payments => [@object] , 
                        :total => Payment.count }  
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
    
    @object = Payment.find_by_id params[:id] 
    @object.update_by_employee(current_user,  params[:payment])
     
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :payments => [@object],
                        :total => Payment.count  } 
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
    @object = Payment.find(params[:id])
    @object.delete(current_user)

    if ( @object.is_confirmed? and @object.is_deleted) or (  not @object.is_confirmed? and not @object.persisted?)  
      render :json => { :success => true, :total => Payment.count }  
    else
      render :json => { 
                  :success => false, 
                  :total => Payment.count,
                  :message => {
                    :errors => extjs_error_format( @object.errors )  
                  }
               }  
    end
  end
  
  def confirm
    @object = Payment.find_by_id params[:id]
    # add some defensive programming.. current user has role admin, and current_user is indeed belongs to the company 
    @object.confirm( current_user  )  
    
    if @object.is_confirmed? 
      render :json => { :success => true, :total => Payment.count }  
    else
      render :json => { :success => false, :total => Payment.count }  
    end
  end
  
  def search_payment_method
    selected_id = params[:selected_id]
    
  
    
    
    if not selected_id.present?
      @objects = [
          {
            :value => PAYMENT_METHOD_CASE[:bank_transfer][:value], 
            :text =>  PAYMENT_METHOD_CASE[:bank_transfer][:name]
          },
          {
            :value => PAYMENT_METHOD_CASE[:cash][:value], 
            :text =>  PAYMENT_METHOD_CASE[:cash][:name]
          },
          {
            :value => PAYMENT_METHOD_CASE[:giro][:value], 
            :text =>  PAYMENT_METHOD_CASE[:giro][:name]
          },
          {
            :value => PAYMENT_METHOD_CASE[:only_downpayment][:value], 
            :text =>  PAYMENT_METHOD_CASE[:only_downpayment][:name]
          }
        ]
    else
      puts "In the search entry_case\n"*10
      puts "The selected_id:#{ selected_id.to_i} "
      if selected_id.to_i == PAYMENT_METHOD_CASE[:bank_transfer][:value]
        @objects = [
            {
              :value => PAYMENT_METHOD_CASE[:bank_transfer][:value], 
              :text =>  PAYMENT_METHOD_CASE[:bank_transfer][:name]
            }
          ]
      elsif selected_id.to_i == PAYMENT_METHOD_CASE[:cash][:value]
        @objects = [
            {
              :value =>   PAYMENT_METHOD_CASE[:cash][:value],
              :text =>    PAYMENT_METHOD_CASE[:cash][:name]
            }
          ]
      elsif selected_id.to_i == PAYMENT_METHOD_CASE[:giro][:value]
        @objects = [
            {
              :value =>  PAYMENT_METHOD_CASE[:giro][:value], 
              :text =>   PAYMENT_METHOD_CASE[:giro][:name]
            }
          ]
      elsif selected_id.to_i ==  PAYMENT_METHOD_CASE[:only_downpayment][:value]
        @objects = [
            {
              :value =>   PAYMENT_METHOD_CASE[:only_downpayment][:value], 
              :text =>    PAYMENT_METHOD_CASE[:only_downpayment][:name]
            }
          ]
      end
        
    end
    
    @total = @objects.count
    @success = true
  end
end
