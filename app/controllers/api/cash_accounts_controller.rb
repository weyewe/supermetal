class Api::CashAccountsController < Api::BaseApiController
  
  def index
    if params[:livesearch].present? 
      livesearch = "%#{params[:livesearch]}%"
      @objects = CashAccount.where{
        (is_deleted.eq false) & 
        (
          (name =~  livesearch )
        )
        
      }.page(params[:page]).per(params[:limit]).order("id DESC")
      
      @total = CashAccount.where{
        (is_deleted.eq false) & 
        (
          (name =~  livesearch )
        )
      }.count
    else
      @objects = CashAccount.page(params[:page]).per(params[:limit]).order("id DESC")
      @total = CashAccount.count
    end
    
    render :json => { :cash_accounts => @objects , :total => @total , :success => true }
  end

  def create
    @object = CashAccount.create_by_employee(current_user, params[:cash_account])
 
    if @object.valid?
      render :json => { :success => true, 
                        :cash_accounts => [@object] , 
                        :total => CashAccount.count }  
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
    @object = CashAccount.find(params[:id])
    @object.update_by_employee(params[:cash_account])
    
    if @object.valid?
      render :json => { :success => true,   
                        :cash_accounts => [@object],
                        :total => CashAccount.count  } 
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
    @object = CashAccount.find(params[:id])
    @object.delete(current_user)

    if @object.is_deleted
      render :json => { :success => true, :total => CashAccount.count }  
    else
      render :json => { :success => false, :total => CashAccount.count }  
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
      @objects = CashAccount.where{  (name =~ query)   
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
    else
      @objects = CashAccount.where{ (id.eq selected_id)  
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
    end
    
    
    render :json => { :records => @objects , :total => @objects.count, :success => true }
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
      @objects = CashAccount.where{     
                                        (name =~ query)   | 
                                        (description =~ query )
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
    else
      @objects = CashAccount.where{ 
                                (id.eq selected_id) 
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
    end
    
    
    render :json => { :records => @objects , :total => @objects.count, :success => true }
  end
  
  def search_case
    selected_id = params[:selected_id]
    
    if not selected_id.present?
      @objects = [
          {
            :value => CASH_ACCOUNT_CASE[:bank][:value], 
            :text =>  CASH_ACCOUNT_CASE[:bank][:name]
          },
          {
            :value => CASH_ACCOUNT_CASE[:cash][:value], 
            :text =>  CASH_ACCOUNT_CASE[:cash][:name]
          }
        ]
    else

      if selected_id.to_i == CASH_ACCOUNT_CASE[:bank][:value]
        @objects = [
            {
              :value => CASH_ACCOUNT_CASE[:bank][:value], 
              :text =>  CASH_ACCOUNT_CASE[:bank][:name]
            }
          ]
      elsif selected_id.to_i == CASH_ACCOUNT_CASE[:cash][:value]
        @objects = [
            {
              :value =>   CASH_ACCOUNT_CASE[:cash][:value],
              :text =>    CASH_ACCOUNT_CASE[:cash][:name]
            }
          ]
      end
        
    end
    
    @total = @objects.count
    @success = true
  end
end
