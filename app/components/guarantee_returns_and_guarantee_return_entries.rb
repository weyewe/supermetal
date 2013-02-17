class GuaranteeReturnsAndGuaranteeReturnEntries < Netzke::Base
  # Remember regions collapse state and size
  include Netzke::Basepack::ItemPersistence

  def configure(c)
    super
    c.items = [
      { netzke_component: :guarantee_returns, region: :center },
      { netzke_component: :guarantee_return_entries, region: :south, height: 250 }
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
        var view = this.getComponent('guarantee_returns').getView();
        view.on('itemclick', function(view, record){
          // The beauty of using Ext.Direct: calling 3 endpoints in a row, which results in a single call to the server!
          this.selectParent({parent_id: record.get('id')});
          this.getComponent('guarantee_return_entries').getStore().load();
        }, this);
      }
    JS
  end

  endpoint :select_parent do |params, this|
    # store selected boss id in the session for this component's instance
    component_session[:selected_parent_id] = params[:parent_id]
  end
  
  component :guarantee_returns do |c|
    c.klass = GuaranteeReturns
  end
 

  component :guarantee_return_entries do |c|
    c.klass = GuaranteeReturnEntries
    c.data_store = {auto_load: false}
    c.scope = {:guarantee_return_id => component_session[:selected_parent_id]}
    c.strong_default_attrs = {:guarantee_return_id => component_session[:selected_parent_id]}
  end
 
end
