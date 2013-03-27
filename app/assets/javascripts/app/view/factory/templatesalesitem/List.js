Ext.define('AM.view.factory.templatesalesitem.List' ,{
  	extend: 'Ext.grid.Panel',
  	alias : 'widget.templatesalesitemlist',

  	store: 'TemplateSalesItems',  

	initComponent: function() {
		this.columns = [
			// { header: 'Nama',  dataIndex: 'name',  flex: 1 , sortable: false},
			{
				xtype : 'templatecolumn',
				text : "Item",
				flex : 1,
				tpl : '<b>{code}</b>' + '<br />' + 
							'{name}' 
			},
			{
				xtype : 'templatecolumn',
				text : "Pola",
				flex : 1,
				tpl : 'OK: <b>{ok_pre_production}</b>' + '<br />' + 
							'Rusak: <b>{broken_pre_production}</b>' 
			},
			
			{
				xtype : 'templatecolumn',
				text : "Cor",
				flex : 1,
				tpl : 'Pending Cor: <b>{pending_production}</b>' + '<br />' + 
							'Ready Cor: <b>{ready_production}</b>' 
			},
			{
				xtype : 'templatecolumn',
				text : "Perbaiki Cor",
				flex : 1,
				tpl : 'Pending Perbaiki Cor: <b>{pending_production_repair}</b>'  
			},
			
			{
				xtype : 'templatecolumn',
				text : "Bubut",
				flex : 1,
				tpl : 'Pending Bubut: <b>{pending_post_production}</b>' + '<br />' + 
							'Ready Bubut: <b>{ready_post_production}</b>' 
			},
			 
		];

		// this.addObjectButton = new Ext.Button({
		// 	text: 'Add Item',
		// 	action: 'addObject'
		// });
		// 
		// this.editObjectButton = new Ext.Button({
		// 	text: 'Edit Item',
		// 	action: 'editObject',
		// 	disabled: true
		// });
		// 
		// this.deleteObjectButton = new Ext.Button({
		// 	text: 'Delete Item',
		// 	action: 'deleteObject',
		// 	disabled: true
		// });
 


		this.searchField = new Ext.form.field.Text({
			name: 'searchField',
			hideLabel: true,
			width: 200,
			emptyText : "Search",
			checkChangeBuffer: 300
		});



		this.tbar = [this.searchField ];
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
		// this.editObjectButton.enable();
		// this.deleteObjectButton.enable();
	},

	disableRecordButtons: function() {
		// this.editObjectButton.disable();
		// this.deleteObjectButton.disable();
	}
});
