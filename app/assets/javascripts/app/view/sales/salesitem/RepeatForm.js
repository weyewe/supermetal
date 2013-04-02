Ext.define('AM.view.sales.salesitem.RepeatForm', {
  extend: 'Ext.window.Window',
  alias : 'widget.salesitemrepeatform',

  title : 'Add / Edit ',
  layout: 'fit',
	width	: 500,
  autoShow: true,  // does it need to be called?
	modal : true, 
// win.show() 
// if autoShow == true.. on instantiation, will automatically be called 
	
  initComponent: function() {
	 	var remoteJsonStore = Ext.create(Ext.data.JsonStore, {
			storeId : 'template_sales_item_search',
			fields	: [
				{
					name : 'template_sales_item_id',
					mapping  :'id'
				},
				{
					name : 'template_sales_item_name',
					mapping : 'name'
				},
				{
					name : 'template_sales_item_code',
					mapping : 'code'
				}
			],
			proxy  	: {
				type : 'ajax',
				url : 'api/search_template_sales_item',
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
					xtype: 'hiddenfield',
					name: 'is_repeat_order',
					value: true 
				},
				{
					fieldLabel: ' Sales Item ',
					xtype: 'combo',
					queryMode: 'remote',
					forceSelection: true, 
					displayField : 'template_sales_item_code',
					valueField : 'template_sales_item_id',
					pageSize : 5,
					minChars : 1, 
					allowBlank : false, 
					triggerAction: 'all',
					store : remoteJsonStore, 
					listConfig : {
						getInnerTpl: function(){
							return '<div data-qtip="{template_sales_item_code}">' +  
												'<div class="combo-name">{template_sales_item_code}</div>' + 
												'<div>{template_sales_item_name}</div>' +
										 '</div>';
						}
					},
					name : 'template_sales_item_id' 
				},
				{
					fieldLabel : 'Tunda Harga?',
					name : 'is_pending_pricing',
					xtype : 'checkbox'
				},
				
				
				
				{
					xtype : 'fieldset',
					title : "Pattern/Pola",
					items : [
						{
							fieldLabel : 'Pattern / Pola?',
							name : 'is_pre_production',
							xtype : 'checkbox'
						},
						{
							fieldLabel : 'Biaya Pola',
							name : 'pre_production_price' ,
							xtype : 'field'
						}
					]
				},
				
				{
					xtype : 'fieldset',
					title : "Cor",
					items : [
						{
							fieldLabel : 'Cor?',
							name : 'is_production',
							xtype : 'checkbox'
						},
						{
							fieldLabel : 'Biaya Cor',
							name : 'production_price'  ,
							xtype : 'field'
						},
						{
							fieldLabel : 'Biaya Berdasarkan Berat?',
							name : 'is_pricing_by_weight' ,
							xtype : 'checkbox'
						},
						{
							fieldLabel : 'Jumlah yang di cor',
							name : 'quantity_for_production' ,
							xtype : 'field' 
						}
					]
				},
				
				{
					xtype : 'fieldset',
					title : "Bubut",
					items : [
						{
							fieldLabel : 'Bubut?',
							name : 'is_post_production',
							xtype : 'checkbox'
						},
						{
							fieldLabel : 'Biaya Bubut',
							name : 'post_production_price'  ,
							xtype : 'field'
						},
						{
							fieldLabel : 'Jumlah yang di bubut',
							name : 'quantity_for_post_production' ,
							xtype : 'field' 
						}
					]
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

		var me = this; 
		me.setLoading(true);
		var comboBox = this.down('form').getForm().findField('template_sales_item_id'); 
		
		var store = comboBox.store; 
		store.load({
			params: {
				selected_id : record.get("template_sales_item_id")
			},
			callback : function(records, options, success){
				me.setLoading(false);
				comboBox.setValue( record.get("template_sales_item_id"));
			}
		});
	},

	setParentData: function( record ){
		// this.down('form').getForm().findField('template_sales_item_id').setValue(record.get('id'));
		// this.down('form').getForm().findField('template_sales_item_name').setValue( record.get('name'));
		// this.down('form').getForm().findField('template_sales_item_code').setValue( record.get('code'));
	}
});

