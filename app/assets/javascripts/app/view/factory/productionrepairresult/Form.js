Ext.define('AM.view.factory.productionrepairresult.Form', {
  extend: 'Ext.window.Window',
  alias : 'widget.productionrepairresultform',

  title : 'Add / Edit Pola',
  layout: 'fit',
	width	: 500,
  autoShow: true,  // does it need to be called?
	modal : true, 
// win.show() 
// if autoShow == true.. on instantiation, will automatically be called 
	
  initComponent: function() {
	 
		
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
					xtype : 'fieldset',
					title : "OK Cor",
					items : [
						{
							fieldLabel: 'Jumlah OK',
							name: 'ok_quantity' ,
							xtype : 'textfield'
						},
						{
							fieldLabel: 'Berat OK',
							name: 'ok_weight' ,
							xtype : 'textfield'
						}
					]
				},
			
				
				{
					xtype : "fieldset",
					title : "Rusak",
					items : [
						{
							fieldLabel: 'Jumlah Rusak',
							name: 'broken_quantity' ,
							xtype : 'textfield'
						},
						{
							fieldLabel: 'Berat Rusak',
							name: 'broken_weight' ,
							xtype : 'textfield'
						},
					]
				},
				
				
				
				{
					fieldLabel: 'Mulai',
					name: 'started_at' ,
					xtype : 'datetimefield',
					format: 'd/m/Y'
				},
				{
					fieldLabel: 'Selesai',
					name: 'finished_at' ,
					xtype : 'datetimefield',
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


	setParentData: function( record ){
		this.down('form').getForm().findField('template_sales_item_id').setValue(record.get('id'));
		this.down('form').getForm().findField('template_sales_item_name').setValue( record.get('name'));
		this.down('form').getForm().findField('template_sales_item_code').setValue( record.get('code'));
	}
});
