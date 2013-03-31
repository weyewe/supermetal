Ext.define('AM.view.payment.invoice.Form', {
  extend: 'Ext.window.Window',
  alias : 'widget.invoiceform',

  title : 'Add / Edit Invoice',
  layout: 'fit',
	width	: 500,
  autoShow: true,  // does it need to be called?
	modal : true, 
	
  initComponent: function() {
	
		var remoteJsonStore = Ext.create(Ext.data.JsonStore, {
			storeId : 'customer_search',
			fields	: [
	 				{
						name : 'customer_id',
						mapping : "id"
					},
					{
						name : 'customer_name',
						mapping : 'name'
					}
			],
			proxy  	: {
				type : 'ajax',
				url : 'api/search_customer',
				reader : {
					type : 'json',
					root : 'records', 
					totalProperty  : 'total'
				}
			},
			autoLoad : false 
		});
	
    this.items = [{
      xtype: 'form',
			msgTarget	: 'side',
			border: false,
      bodyPadding: 10,
			fieldDefaults: {
          labelWidth: 165,
					anchor: '100%'
      },
      items: [
				 
				{
					fieldLabel: 'Jatuh Tempo',
					xtype: 'datefield',
					name : 'due_date' ,
					format: 'd/m/Y'
				}
			]
    }];

    this.buttons = [{
      text: 'Save',
      action: 'save'
    }, {
      text: 'Cancel',
      scope: this,
      handler: this.close
    }];

    this.callParent(arguments);
  },

	setComboBoxData : function( record){
		// var me = this; 
		// me.setLoading(true);
		// var comboBox = this.down('form').getForm().findField('customer_id'); 
		// var selectedRecordId = record.get("customer_id");
		// 
		// var store = comboBox.store; 
		// store.load({
		// 	params: {
		// 		selected_id : selectedRecordId
		// 	},
		// 	callback : function(records, options, success){
		// 		me.setLoading(false);
		// 		comboBox.setValue( selectedRecordId );
		// 	}
		// });
	}
});

