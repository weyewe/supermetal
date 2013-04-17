class Api::InvoiceEntriesController < Api::BaseApiController
  
  def index
    @parent = Invoice.find_by_id params[:invoice_id]
    @objects = @parent.delivery.billable_delivery_entries.joins(:delivery, :sales_item).page(params[:page]).per(params[:limit]).order("id DESC")
    @total = @parent.delivery.billable_delivery_entries.count
  end

   
end
