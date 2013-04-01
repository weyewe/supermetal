Ext.define('AM.view.payment.invoicepayment.Form', {
  extend: 'Ext.window.Window',
  alias : 'widget.invoicepaymentform',

  title : 'Add / Edit Entry',
  layout: 'fit',
	width	: 500,
  autoShow: true,  // does it need to be called?
	modal : true, 
// win.show() 
// if autoShow == true.. on instantiation, will automatically be called 
	parentRecord : null, 
	// autoHeight : true, 
	
	
	// overflow : auto, 

	constructor : function(cfg){
		this.parentRecord = cfg.parentRecord;
		this.callParent(arguments);
	},
	
  initComponent: function() {

		if( !this.parentRecord){ return; }
		var me = this; 
		
 
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
					xtype: 'displayfield',
					fieldLabel: 'Delivery',
					name: 'delivery_code',
					value: '10'
				},
				
				{
					fieldLabel : 'Jumlah Dikirim',
					name : 'quantity_sent',
					xtype : 'field'
				},
				{
					fieldLabel : 'Berat Dikirim (kg)',
					name : 'quantity_sent_weight',
					xtype : 'field'
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

	


	setParentData: function( record ){
		this.down('form').getForm().findField('payment_code').setValue(record.get('code')); 
	},
	 
	setComboBoxData : function( record){
		// var me = this; 
		// me.setLoading(true);
		// 
		// 
		// me.setSelectedSalesItem( record.get("payment_item_id")  ) ;
		// me.setSelectedEntryCase( record.get("entry_case")  ) ;
		// me.setSelectedItemCondition( record.get("item_condition")  ) ;
		// 	 
	}
});

