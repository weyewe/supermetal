Ext.define('AM.view.factory.preproductionresult.Form', {
  extend: 'Ext.window.Window',
  alias : 'widget.preproductionresultform',

  title : 'Add / Edit Pola',
  layout: 'fit',
	width	: 500,
  autoShow: true,  // does it need to be called?
	modal : true, 
// win.show() 
// if autoShow == true.. on instantiation, will automatically be called 
	
  initComponent: function() {
		// var remoteJsonStore = Ext.create(Ext.data.JsonStore, {
		// 	storeId : 'template_sales_item_search',
		// 	fields	: [
		// 		{
		// 			name : 'template_sales_item_id',
		// 			mapping  :'id'
		// 		},
		// 		{
		// 			name : 'template_sales_item_name',
		// 			mapping : 'name'
		// 		},
		// 		{
		// 			name : 'template_sales_item_code',
		// 			mapping : 'code'
		// 		}
		// 	],
		// 	proxy  	: {
		// 		type : 'ajax',
		// 		url : 'api/search_template_sales_item',
		// 		reader : {
		// 			type : 'json',
		// 			root : 'records', 
		// 			totalProperty  : 'total'
		// 		}
		// 	}
		// });
		
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
	        xtype: 'hidden',
	        name : 'template_sales_item_id',
	        fieldLabel: 'template_sales_item_id'
	      },
				{
					xtype: 'displayfield',
					fieldLabel: 'Nama Item',
					name: 'template_sales_item_name',
					value: '10'
				},
				{
					xtype: 'displayfield',
					fieldLabel: 'Code',
					name: 'template_sales_item_code',
					value: '10'
				},
				
				 
				{
					fieldLabel: 'Jumlah OK',
					name: 'ok_quantity' ,
					xtype : 'textfield'
				},
				{
					fieldLabel: 'Jumlah Rusak',
					name: 'broken_quantity' ,
					xtype : 'textfield'
				},
				{
					fieldLabel: 'Mulai',
					name: 'started_at' ,
					xtype : 'datetimefield'
				},
				{
					fieldLabel: 'Selesai',
					name: 'finished_at' ,
					xtype : 'datetimefield'
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
		this.down('form').getForm().findField('template_sales_item_id').setValue(record.get('id'));
		this.down('form').getForm().findField('template_sales_item_name').setValue( record.get('name'));
		this.down('form').getForm().findField('template_sales_item_code').setValue( record.get('code'));
	}
});

