class TemplateSalesItemsController < ApplicationController
  def search_template_sales_item
    search_params = params[:q]
    
    @objects = [] 
    query = '%' + search_params + '%'
    # on PostGre SQL, it is ignoring lower case or upper case 
    @objects = TemplateSalesItem.where{ (code =~ query) }.map do |x| 
                        {
                          :code => x.code, 
                          :id => x.id, 
                          :customer_name => x.customers_name
                        }
                      end
    
    respond_to do |format|
      format.html # show.html.erb 
      format.json { render :json => @objects }
    end
  end
end
