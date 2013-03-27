Ext.define('AM.view.sales.deliveryentry.Form', {
  extend: 'Ext.window.Window',
  alias : 'widget.deliveryentryform',

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
		
		var salesItemRemoteJsonStore = Ext.create(Ext.data.JsonStore, {
			storeId : 'sales_item_search',
			fields	: [
				{
					name : 'sales_item_id',
					mapping  :'id'
				},
				{
					name : 'sales_item_name',
					mapping : 'name'
				},
				{
					name : 'sales_item_code',
					mapping : 'code'
				},
				{
					name : 'ready_production',
					mapping : 'ready_production'
				},
				{
					name : 'ready_post_production',
					mapping : 'ready_post_production'
				}
			],
			proxy  	: {
				type : 'ajax',
				url : 'api/search_sales_items',
				extraParams: {
					customer_id : this.parentRecord.get('customer_id')
		    },
				reader : {
					type : 'json',
					root : 'records', 
					totalProperty  : 'total'
				}
			}
		});
		
		var entryCaseRemoteJsonStore = Ext.create(Ext.data.JsonStore, {
			storeId : 'delivery_entry_case_search',
			fields	: [
				{
					name : 'value',
					mapping  :'value'
				},
				{
					name : 'text',
					mapping : 'text'
				}
			],
			proxy  	: {
				type : 'ajax',
				url : 'api/search_delivery_entry_case',
				reader : {
					type : 'json',
					root : 'records', 
					totalProperty  : 'total'
				}
			}
		});
		
		var itemConditionRemoteJsonStore = Ext.create(Ext.data.JsonStore, {
			storeId : 'delivery_entry_item_condition',
			fields	: [
				{
					name : 'value',
					mapping  :'value'
				},
				{
					name : 'text',
					mapping : 'text'
				}
			],
			proxy  	: {
				type : 'ajax',
				url : 'api/search_delivery_item_condition',
				reader : {
					type : 'json',
					root : 'records', 
					totalProperty  : 'total'
				}
			}
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
					xtype: 'displayfield',
					fieldLabel: 'Delivery',
					name: 'delivery_code',
					value: '10'
				},
				{
					xtype: 'fieldset',
					title: "Item Info",
					items : [
						{
							fieldLabel: 'Item',
							xtype: 'combo',
							queryMode: 'remote',
							forceSelection: true, 
							displayField : 'sales_item_code',
							valueField : 'sales_item_id',
							pageSize : 5,
							minChars : 1, 
							allowBlank : false, 
							triggerAction: 'all',
							store : salesItemRemoteJsonStore, 
							listConfig : {
								getInnerTpl: function(){
									return '<div data-qtip="{text}">' +  
														'<div class="combo-name">{sales_item_name} ({sales_item_code})</div>' + 
														'<div>Ready Cor: {ready_production}</div>' + 
														'<div>Ready Bubut: {ready_post_production}</div>' + 
												 '</div>'; 
								}
							},
							name : 'sales_item_id' 
						},
						{
							fieldLabel: 'Kondisi Barang',
							xtype: 'combo',
							queryMode: 'remote',
							forceSelection: true, 
							displayField : 'text',
							valueField : 'value',
							pageSize : 5,
							minChars : 1, 
							allowBlank : false, 
							triggerAction: 'all',
							store : itemConditionRemoteJsonStore, 
							listConfig : {
								getInnerTpl: function(){
									return  	'<div data-qtip="{text}">' +  
															'<div class="combo-name">{text}</div>' + 
									 					'</div>';
								}
							},
							name : 'item_condition' 
						},
						{
							fieldLabel: 'Kasus Pengiriman',
							xtype: 'combo',
							queryMode: 'remote',
							forceSelection: true, 
							displayField : 'text',
							valueField : 'value',
							pageSize : 5,
							minChars : 1, 
							allowBlank : false, 
							triggerAction: 'all',
							store : entryCaseRemoteJsonStore, 
							listConfig : {
								getInnerTpl: function(){
									return '<div data-qtip="{text}">' +  
														'<div class="combo-name">{text}</div>' + 
												 '</div>';
								}
							},
							name : 'entry_case' 
						}
						
					]
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
		this.down('form').getForm().findField('delivery_code').setValue(record.get('code')); 
	},
	
	setComboBoxData : function( record){
		var me = this; 
		me.setLoading(true);
		
		var comboBox = this.down('form').getForm().findField('sales_item_id'); 
		var store = comboBox.store; 
		store.load({
			params: {
				selected_id : record.get("sales_item_id")
			},
			callback : function(records, options, success){
				me.setLoading(false);
				comboBox.setValue( record.get("sales_item_id"));
			}
		});
		
		var comboBox = this.down('form').getForm().findField('entry_case'); 
		var store = comboBox.store; 
		store.load({
			params: {
				selected_id : record.get("entry_case")
			},
			callback : function(records, options, success){
				me.setLoading(false);
				comboBox.setValue( record.get("entry_case"));
			}
		});
		
		var comboBox = this.down('form').getForm().findField('item_condition'); 
		var store = comboBox.store; 
		store.load({
			params: {
				selected_id : record.get("item_condition")
			},
			callback : function(records, options, success){
				me.setLoading(false);
				comboBox.setValue( record.get("item_condition"));
			}
		});
	}
});

