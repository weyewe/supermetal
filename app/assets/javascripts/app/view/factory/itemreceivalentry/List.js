Ext.define('AM.view.factory.itemreceivalentry.List' ,{
  	extend: 'Ext.grid.Panel',
  	alias : 'widget.itemreceivalentrylist',

  	store: 'ItemReceivalEntries', 
 

	initComponent: function() {
		this.columns = [
			{ header: 'Code',  dataIndex: 'code',  flex: 1 , sortable: false},
			{
				xtype : 'templatecolumn',
				text : "Item",
				flex : 1,
				tpl : '<b>{factory_item_code}</b>' + 
							'<br />' + '<br />' + 
							'{factory_item_name}' + '<br />' + 
							"Kondisi barang: <b>{item_condition_name}</b>" 
			},
			{
				xtype : 'templatecolumn',
				text : "Lebur Ulang",
				flex : 1,
				tpl : 'Kuantitas: <b>{quantity_for_production}</b>' + '<br />' + 
							'Berat: <b>{weight_for_production}</b> kg'
			},
			{
				xtype : 'templatecolumn',
				text : "Perbaiki Cor",
				flex : 1,
				tpl : 'Kuantitas: <b>{quantity_for_production_repair}</b>' + '<br />' + 
							'Berat: <b>{weight_for_production_repair}</b> kg'
			},
			{
				xtype : 'templatecolumn',
				text : "Perbaiki Bubut",
				flex : 1,
				tpl : 'Kuantitas: <b>{quantity_for_post_production}</b>' + '<br />' + 
							'Berat: <b>{weight_for_post_production}</b> kg'
			}
			 
		];
		

		this.addObjectButton = new Ext.Button({
			text: 'Add',
			action: 'addObject',
			disabled : true 
		});

		this.editObjectButton = new Ext.Button({
			text: 'Edit',
			action: 'editObject',
			disabled: true
		});
		
		this.deleteObjectButton = new Ext.Button({
			text: 'Delete',
			action: 'deleteObject',
			disabled: true
		});

	 
 



		this.tbar = [this.addObjectButton, this.editObjectButton, this.deleteObjectButton ];
		this.bbar = Ext.create("Ext.PagingToolbar", {
			store	: this.store, 
			displayInfo: true,
			displayMsg: 'Displaying topics {0} - {1} of {2}',
			emptyMsg: "No topics to display" 
		});

		this.callParent(arguments);
	},
 
	loadMask	: true,
 
	
	getSelectedObject: function() {
		return this.getSelectionModel().getSelection()[0];
	},

	enableRecordButtons: function() {
		this.addObjectButton.enable();
		this.editObjectButton.enable();
		this.deleteObjectButton.enable();
	},

	disableRecordButtons: function() {
		this.addObjectButton.disable();
		this.editObjectButton.disable();
		this.deleteObjectButton.disable();
	},
	
	setObjectTitle : function(record){
		this.setTitle("Item Receival: " + record.get("code"));
	}
});
