class Api::InvoicePaymentsController < Api::BaseApiController
  
  def index
    @parent = Payment.find_by_id params[:payment_id]
    @objects = @parent.invoice_payments.joins(:payment, :invoice).page(params[:page]).per(params[:limit]).order("id DESC")
    @total = @parent.invoice_payments.count
  end

  def create
   
    @parent = Payment.find_by_id params[:payment_id]
    @object = InvoicePayment.create_invoice_payment(current_user, @parent,  params[:invoice_payment] )  
    
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :invoice_payments => [@object] , 
                        :total => @parent.invoice_payments.count }  
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
    @object = InvoicePayment.find_by_id params[:id] 
    @parent = @object.payment 
    @object.update_invoice_payment(current_user,  @parent, params[:invoice_payment])
     
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :invoice_payments => [@object],
                        :total => @parent.invoice_payments.count  } 
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
    @object = InvoicePayment.find(params[:id])
    @parent = @object.payment 
    @object.delete(current_user)

    if ( @object.persisted? and @object.is_deleted ) or ( not @object.persisted? )
      render :json => { :success => true, :total => @parent.invoice_payments.count }  
    else
      render :json => { :success => false, :total =>@parent.invoice_payments.count }  
    end
  end
  
  def search
    search_params = params[:query]
    selected_id = params[:selected_id]
    if params[:selected_id].nil?  or params[:selected_id].length == 0 
      selected_id = nil
    end
    
    customer_id = params[:customer_id]
    
    query = "%#{search_params}%"
    # on PostGre SQL, it is ignoring lower case or upper case 
    
    if  selected_id.nil?
      @objects = InvoicePayment.joins(:template_invoice_payment, :payment ).where{ (template_invoice_payment.name =~ query )   & 
                                (is_deleted.eq false )  & 
                                (payment.customer_id.eq customer_id)
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
    else
      @objects = InvoicePayment.joins(:template_invoice_payment, :payment).where{ (id.eq selected_id)  & 
                                (is_deleted.eq false ) & 
                                (payment.customer_id.eq customer_id)
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
    end
    
    @total = @objects.count
    @success = true 
    # render :json => { :records => @objects , :total => @objects.count, :success => true }
  end
end
