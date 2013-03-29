Ext.define('AM.view.sales.deliveryentry.FinalizeForm', {
  extend: 'Ext.window.Window',
  alias : 'widget.deliveryentryfinalizeform',

  title : 'Finalisasi Pengiriman',
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
					xtype: 'fieldset',
					title: "Pengiriman Diterima",
					items : [
						 {
							fieldLabel : 'Jumlah Diterima',
							name : 'quantity_confirmed',
							xtype : 'field'
						},
						{
							fieldLabel : 'Berat Diterima(kg)',
							name : 'quantity_confirmed_weight',
							xtype : 'field'
						}
						
					]
				},
				{
					xtype: 'fieldset',
					title: "Retur Pengiriman",
					items : [
						 {
							fieldLabel : 'Jumlah Retur',
							name : 'quantity_returned',
							xtype : 'field'
						},
						{
							fieldLabel : 'Berat Retur(kg)',
							name : 'quantity_returned_weight',
							xtype : 'field'
						} 
					]
				},
				
				{
					xtype: 'fieldset',
					title: "Pengiriman Hilang",
					items : [
						 {
							fieldLabel : 'Jumlah Hilang',
							name : 'quantity_lost',
							xtype : 'field'
						} 
					]
				},
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
		this.down('form').getForm().findField('delivery_code').setValue(record.get('code')); 
	} 
});

