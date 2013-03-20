Ext.define('AM.view.inventory.material.List' ,{
  	extend: 'Ext.grid.Panel',
  	alias : 'widget.materiallist',

  	store: 'Materials', 
 

	initComponent: function() {
		this.columns = [
			{ header: 'ID', dataIndex: 'id'},
			{ header: 'Name',  dataIndex: 'name',  flex: 1 , sortable: false} ,
			{ header: 'Code',  dataIndex: 'code',  flex: 1 , sortable: false} 
		];

		this.addObjectButton = new Ext.Button({
			text: 'Add Material',
			action: 'addObject'
		});

		this.editObjectButton = new Ext.Button({
			text: 'Edit Material',
			action: 'editObject',
			disabled: true
		});

		this.deleteObjectButton = new Ext.Button({
			text: 'Delete Material',
			action: 'deleteObject',
			disabled: true
		});
		
		this.searchField = new Ext.form.field.Text({
			name: 'searchField',
			hideLabel: true,
			width: 200,
			emptyText : "Search",
			checkChangeBuffer: 300
		});



		this.tbar = [this.addObjectButton, this.editObjectButton, this.deleteObjectButton, this.searchField];
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
	},

	disableRecordButtons: function() {
		this.editObjectButton.disable();
		this.deleteObjectButton.disable();
	}
});
