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
		
		var remoteJsonStore = Ext.create(Ext.data.JsonStore, {
			storeId : 'invoice_search',
			fields	: [
	 				{
						name : 'invoice_id',
						mapping : "id"
					},
					{
						name : 'invoice_code',
						mapping : 'code'
					},
					{
						name :'invoice_customer_name',
						mapping : 'customer_name'
					},
					{
						name :'invoice_pending_payment',
						mapping : 'confirmed_pending_payment'
					},
					
			],
			proxy  	: {
				type : 'ajax',
				url : 'api/search_invoice',
				extraParams: {
					customer_id : this.parentRecord.get('customer_id')
		    },
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
					fieldLabel: 'Invoice',
					xtype: 'combo',
					queryMode: 'remote',
					forceSelection: true, 
					displayField : 'invoice_code',
					valueField : 'invoice_id',
					pageSize : 5,
					minChars : 1, 
					allowBlank : false, 
					triggerAction: 'all',
					store : remoteJsonStore , 
					listConfig : {
						getInnerTpl: function(){
							return  	'<div data-qtip="{invoice_code}">' +  
													'<div class="combo-name">{invoice_code}</div>' + 
													'<div>Customer: {invoice_customer_name}</div>' + 
													'<div>Belum Dibayar: {invoice_pending_payment}</div>' + 
							 					'</div>';
						}
					},
					name : 'invoice_id' 
				},
				
				{
					fieldLabel : 'Jumlah Pembayaran',
					name : 'amount_paid',
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
		// this.down('form').getForm().findField('payment_code').setValue(record.get('code')); 
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
		var invoice_id = record.get("invoice_id");
		var comboBox = this.down('form').getForm().findField('invoice_id'); 
		var me = this; 
		var store = comboBox.store; 
		store.load({
			params: {
				selected_id : invoice_id 
			},
			callback : function(records, options, success){
				me.setLoading(false);
				comboBox.setValue( invoice_id );
			}
		});
	}
});

