class SalesOrdersAndSalesItems < Netzke::Base
  # Remember regions collapse state and size
  include Netzke::Basepack::ItemPersistence

  def configure(c)
    super
    c.items = [
      { netzke_component: :sales_orders, region: :center },
      { netzke_component: :sales_items, region: :south, height: 250 }
    ]
  end

  js_configure do |c|
    c.layout = :border
    c.border = false

    # Overriding initComponent
    c.init_component = <<-JS
      function(){
        // calling superclass's initComponent
        this.callParent();

        // setting the 'rowclick' event
        var view = this.getComponent('sales_orders').getView();
        view.on('itemclick', function(view, record){
          // The beauty of using Ext.Direct: calling 3 endpoints in a row, which results in a single call to the server!
          this.selectParent({parent_id: record.get('id')});
          this.getComponent('sales_items').getStore().load();
        }, this);
      }
    JS
  end

  endpoint :select_parent do |params, this|
    # store selected boss id in the session for this component's instance
    component_session[:selected_parent_id] = params[:parent_id]
  end
  
  component :sales_orders do |c|
    c.klass = SalesOrders
  end
 

  component :sales_items do |c|
    c.klass = SalesItems
    c.data_store = {auto_load: false}
    c.scope = {:sales_order_id => component_session[:selected_parent_id]}
    c.strong_default_attrs = {:sales_order_id => component_session[:selected_parent_id]}
  end
 
end
