Ext.define('AM.view.sales.guaranteereturn.List' ,{
  	extend: 'Ext.grid.Panel',
  	alias : 'widget.guaranteereturnlist',

  	store: 'GuaranteeReturns', 
 

	initComponent: function() {
		this.columns = [
			{ header: 'ID', dataIndex: 'id'},
			{ header: 'Code',  dataIndex: 'code',  flex: 1 , sortable: false},
			{ header: 'Customer',  dataIndex: 'customer_name',  flex: 1 , sortable: false},
			{ header: 'Confirmed?',  dataIndex: 'is_confirmed',  flex: 1 , sortable: false},
		];

		this.addObjectButton = new Ext.Button({
			text: 'Add Guarantee Return',
			action: 'addObject'
		});

		this.editObjectButton = new Ext.Button({
			text: 'Edit Guarantee Return',
			action: 'editObject',
			disabled: true
		});

		this.deleteObjectButton = new Ext.Button({
			text: 'Delete Guarantee Return',
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
