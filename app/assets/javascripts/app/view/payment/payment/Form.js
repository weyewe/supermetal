Ext.define('AM.view.payment.payment.Form', {
  extend: 'Ext.window.Window',
  alias : 'widget.paymentform',

  title : 'Add / Edit Invoice',
  layout: 'fit',
	width	: 500,
  autoShow: true,  // does it need to be called?
	modal : true, 
	
  initComponent: function() {
	
		var remoteCashAccountStore = Ext.create(Ext.data.JsonStore, {
			storeId : 'cash_account_search',
			fields	: [
	 				{
						name : 'cash_account_id',
						mapping : "id"
					},
					{
						name : 'cash_account_name',
						mapping : 'name'
					},
					{
						name : 'cash_account_description',
						mapping : 'description'
					}
			],
			proxy  	: {
				type : 'ajax',
				url : 'api/search_cash_account',
				reader : {
					type : 'json',
					root : 'records', 
					totalProperty  : 'total'
				}
			},
			autoLoad : false 
		});
		
		var remotePaymentMethodStore = Ext.create(Ext.data.JsonStore, {
			storeId : 'payment_method_search',
			fields	: [
	 				{
						name : 'payment_method',
						mapping : "value"
					},
					{
						name : 'payment_method_name',
						mapping : 'text'
					}
			],
			proxy  	: {
				type : 'ajax',
				url : 'api/search_payment_method',
				reader : {
					type : 'json',
					root : 'records', 
					totalProperty  : 'total'
				}
			},
			autoLoad : false 
		});
		
		var remoteCustomerStore = Ext.create(Ext.data.JsonStore, {
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
					fieldLabel: 'Customer',
					xtype: 'combo',
					queryMode: 'remote',
					forceSelection: true, 
					displayField : 'customer_name',
					valueField : 'customer_id',
					pageSize : 5,
					minChars : 1, 
					allowBlank : false, 
					triggerAction: 'all',
					store : remoteCustomerStore , 
					listConfig : {
						getInnerTpl: function(){
							return  	'<div data-qtip="{cash_account_name}">' +  
													'<div class="combo-name">{customer_name}</div>' + 
							 					'</div>';
						}
					},
					name : 'customer_id' 
				},
			 
				{
					fieldLabel: 'Tujuan Pembayaran',
					xtype: 'combo',
					queryMode: 'remote',
					forceSelection: true, 
					displayField : 'cash_account_name',
					valueField : 'cash_account_id',
					pageSize : 5,
					minChars : 1, 
					allowBlank : false, 
					triggerAction: 'all',
					store : remoteCashAccountStore, 
					listConfig : {
						getInnerTpl: function(){
							return  	'<div data-qtip="{cash_account_name}">' +  
													'<div class="combo-name">{cash_account_name}</div>' + 
													'<div>{cash_account_description}</div>' + 
							 					'</div>';
						}
					},
					name : 'cash_account_id' 
				},
				{
					fieldLabel: 'Metode Pembayaran',
					xtype: 'combo',
					queryMode: 'remote',
					forceSelection: true, 
					displayField : 'payment_method_name',
					valueField : 'payment_method',
					pageSize : 5,
					minChars : 1, 
					allowBlank : false, 
					triggerAction: 'all',
					store : remotePaymentMethodStore, 
					listConfig : {
						getInnerTpl: function(){
							return  	'<div data-qtip="{payment_method_name}">' +  
													'<div class="combo-name">{payment_method_name}</div>' + 
							 					'</div>';
						}
					},
					name : 'payment_method' 
				},
				{
					fieldLabel: 'Jumlah untuk Pembayaran',
					name: 'amount_paid' ,
					xtype : 'textfield'
				},
				{
					fieldLabel: 'Jumlah untuk Penambahan DP',
					name: 'downpayment_addition_amount' ,
					xtype : 'textfield'
				},
				{
					fieldLabel: 'Penggunaan DP',
					name: 'downpayment_usage_amount' ,
					xtype : 'textfield'
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


	setSelectedCashAccount: function( cash_account_id ){
		var comboBox = this.down('form').getForm().findField('cash_account_id'); 
		var me = this; 
		var store = comboBox.store; 
		store.load({
			params: {
				selected_id : cash_account_id 
			},
			callback : function(records, options, success){
				me.setLoading(false);
				comboBox.setValue( cash_account_id );
			}
		});
	},

	setSelectedPaymentMethod: function( payment_method ){
		var comboBox = this.down('form').getForm().findField('payment_method'); 
		var me = this; 
		var store = comboBox.store; 
		store.load({
			params: {
				selected_id : payment_method 
			},
			callback : function(records, options, success){
				me.setLoading(false);
				comboBox.setValue( payment_method );
			}
		});
	},

 	setSelectedCustomer: function( customer_id ){
		var comboBox = this.down('form').getForm().findField('customer_id'); 
		var me = this; 
		var store = comboBox.store; 
		store.load({
			params: {
				selected_id : customer_id 
			},
			callback : function(records, options, success){
				me.setLoading(false);
				comboBox.setValue( customer_id );
			}
		});
	},
	
	setComboBoxData : function( record){
		var me = this; 
		me.setLoading(true);
		
		
		me.setSelectedCustomer( record.get("customer_id")  ) ;
		me.setSelectedPaymentMethod( record.get("payment_method")  ) ;
		me.setSelectedCashAccount( record.get("cash_account_id")  ) ;
	 
	}
});

