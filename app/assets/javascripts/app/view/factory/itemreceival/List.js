Ext.define('AM.view.factory.itemreceival.List' ,{
  	extend: 'Ext.grid.Panel',
  	alias : 'widget.itemreceivallist',

  	store: 'ItemReceivals', 
 

	initComponent: function() {
		this.columns = [
			{ header: 'ID', dataIndex: 'id'} 
		];

		this.addObjectButton = new Ext.Button({
			text: 'Add Item Receival',
			action: 'addObject'
		});

		this.editObjectButton = new Ext.Button({
			text: 'Edit Item Receival',
			action: 'editObject',
			disabled: true
		});

		this.deleteObjectButton = new Ext.Button({
			text: 'Delete Item Receival',
			action: 'deleteObject',
			disabled: true
		});
		
		this.confirmObjectButton = new Ext.Button({
			text: 'Confirm',
			action: 'confirmObject',
			disabled: true
		});



		this.tbar = [this.addObjectButton, this.editObjectButton, this.deleteObjectButton, this.confirmObjectButton ];
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
		this.editObjectButton.enable();
		this.deleteObjectButton.enable();
		this.confirmObjectButton.enable();
	},

	disableRecordButtons: function() {
		this.editObjectButton.disable();
		this.deleteObjectButton.disable();
		this.confirmObjectButton.disable();
	}
});
