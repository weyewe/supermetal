Ext.define('AM.view.sales.salesitem.Form', {
  extend: 'Ext.window.Window',
  alias : 'widget.salesitemform',

  title : 'Add / Edit Entry',
  layout: 'fit',
	width	: 960,
  autoShow: true,  // does it need to be called?
	modal : true, 
// win.show() 
// if autoShow == true.. on instantiation, will automatically be called 
	parentRecord : null, 
	// autoHeight : true, 
	height : 500,
	
	
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
          labelWidth: 100,
					anchor: '100%'
      },
			height : 350,
			overflowY : 'auto', 
			layout : 'hbox', 
			// height : 400,
			items : [
				me.itemInfo(), 
				me.pricingInfo()
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

	itemInfo : function(){
		var remoteJsonStore = Ext.create(Ext.data.JsonStore, {
			storeId : 'material_search',
			fields	: [
				{
					name : 'material_id',
					mapping  :'id'
				},
				{
					name : 'material_name',
					mapping : 'name'
				},
				{
					name : 'material_code',
					mapping : 'code'
				}
			],
			proxy  	: {
				type : 'ajax',
				url : 'api/search_material',
				reader : {
					type : 'json',
					root : 'records', 
					totalProperty  : 'total'
				}
			}
		});
		
		
		var itemInfo = {
			xtype : 'fieldset',
			title : "Item Info",
			flex : 1 , 
			border : true, 
			labelWidth: 60,
			defaultType : 'field',
			width : '90%',
			defaults : {
				anchor : '-10'
			},
			items : [
				{
					xtype: 'displayfield',
					fieldLabel: 'Sales Order',
					name: 'sales_order_code',
					value: '10'
				},
				{
					fieldLabel : 'Item Name',
					name : 'name'
				},
				{
					fieldLabel : 'Deskripsi',
					name : 'description',
					xtype : 'textarea'
				},
				// change this to combobox
				// {
				// 	fieldLabel : 'Material',
				// 	name : 'material_id'
				// },
				{
					fieldLabel: ' Material ',
					xtype: 'combo',
					queryMode: 'remote',
					forceSelection: true, 
					displayField : 'material_name',
					valueField : 'material_id',
					pageSize : 5,
					minChars : 1, 
					allowBlank : false, 
					triggerAction: 'all',
					store : remoteJsonStore, 
					listConfig : {
						getInnerTpl: function(){
							return '<div data-qtip="{material_name}">' +  
												'<div class="combo-name">{material_name}</div>' + 
												'<div class="">Kode: {material_code}</div>' +
										 '</div>';
						}
					},
					name : 'material_id' 
				},
				{
					fieldLabel : 'Berat per set (kg)',
					name : 'weight_per_piece'
				},
				{
					fieldLabel : 'PPN',
					name : 'vat_tax' ,
					xtype : 'field'
				}
			]
		};
		
		var deliveryInfo = {
			xtype : 'fieldset',
			title : "Delivery Info",
			flex : 1 , 
			border : true,
			width : '90%', 
			labelWidth: 60,
			defaultType : 'field',
			defaults : {
				anchor : '-10'
			},
			items : [
				{
					fieldLabel : 'Dikirim?',
					name : 'is_delivered',
					xtype : 'checkbox'
				},
				{
					fieldLabel : 'Alamat Pengiriman',
					name : 'delivery_address',
					xtype : 'textarea'
				}
			]
		};
		
	 
		
		var container = {
			xtype : 'container',
			layoutConfig: {
				align :'stretch'
			},
			flex: 1, 
			width : 500,
			layout : 'vbox',
			items : [
				itemInfo,
				deliveryInfo 
			]
		};
		
		return container; 
		
		
	},
	
	
	pricingInfo : function(){
		var preProductionFieldset = {
			xtype : 'fieldset',
			title : "Pre Production",
			flex : 1 , 
			border : true, 
			labelWidth: 30,
			width : '90%',
			defaultType : 'field',
			defaults : {
				anchor : '-10'
			},
			items : [
				{
					fieldLabel : 'Pattern / Pola?',
					name : 'is_pre_production',
					xtype : 'checkbox'
				},
				{
					fieldLabel : 'Biaya Pola',
					name : 'pre_production_price' 
				}
			]
		};
		
		var productionFieldset = {
			xtype : 'fieldset',
			title : "Production",
			flex : 1 , 
			border : true, 
			labelWidth: 30,
			width : '90%',
			defaultType : 'field',
			defaults : {
				anchor : '-10'
			},
			items : [
				{
					fieldLabel : 'Cor?',
					name : 'is_production',
					xtype : 'checkbox'
				},
				{
					fieldLabel : 'Biaya Cor',
					name : 'production_price' 
				},
				{
					fieldLabel : 'Biaya Berdasarkan Berat?',
					name : 'is_pricing_by_weight' ,
					xtype : 'checkbox'
				},
				{
					fieldLabel : 'Jumlah yang di cor',
					name : 'quantity_for_production' 
				}
			]
		};
		
		var postProductionFieldset = {
			xtype : 'fieldset',
			title : "Post Production",
			flex : 1 , 
			border : true, 
			labelWidth: 30,
			width : '90%',
			defaultType : 'field',
			defaults : {
				anchor : '-10'
			},
			items : [
				{
					fieldLabel : 'Bubut?',
					name : 'is_post_production',
					xtype : 'checkbox'
				},
				{
					fieldLabel : 'Biaya Bubut',
					name : 'post_production_price' 
				},
				{
					fieldLabel : 'Jumlah yang di bubut',
					name : 'quantity_for_post_production' 
				}
			]
		};
		
		var container = {
			xtype : 'container',
			layoutConfig: {
				align :'stretch'
			},
			width : '100%',
			flex :  1, 
			layout : 'vbox',
			items : [
				{
					fieldLabel : 'Pending Pricing?',
					xtype : 'checkbox',
					name : 'is_pending_pricing'
				},
				preProductionFieldset,
				productionFieldset,
				postProductionFieldset
			]
		};
		
		return container;
	},



	setParentData: function( record ){
		this.down('form').getForm().findField('sales_order_code').setValue(record.get('code')); 
	},
	
	setComboBoxData : function( record){

		var me = this; 
		me.setLoading(true);
		var comboBox = this.down('form').getForm().findField('material_id'); 
		
		var store = comboBox.store; 
		store.load({
			params: {
				selected_id : record.get("material_id")
			},
			callback : function(records, options, success){
				me.setLoading(false);
				comboBox.setValue( record.get("material_id"));
			}
		});
	}
});

