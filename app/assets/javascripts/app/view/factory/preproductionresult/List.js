Ext.define('AM.view.factory.preproductionresult.List' ,{
  	extend: 'Ext.grid.Panel',
  	alias : 'widget.preproductionresultlist',

  	store: 'PreProductionResults', 
 

	initComponent: function() {
		this.columns = [
			{ header: 'ID',  dataIndex: 'id',  flex: 1 , sortable: false},
			{
				xtype : 'templatecolumn',
				text : "Item",
				flex : 1,
				tpl : '<b>{template_sales_item_code}</b>' + '<br />' + 
							'{template_sales_item_name}' 
			},
			{ header: 'Quantity OK',  dataIndex: 'ok_quantity',  flex: 1 , sortable: false},
			{ header: 'Quantity Rusak',  dataIndex: 'broken_quantity',  flex: 1 , sortable: false},
			{ header: 'Mulai',  dataIndex: 'started_at',  flex: 1 , sortable: false} ,
			{ header: 'Selesai',  dataIndex: 'finished_at',  flex: 1 , sortable: false}  
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
		this.addObjectButton.enable();
		this.editObjectButton.enable();
		this.deleteObjectButton.enable();
		this.confirmObjectButton.enable();
	},

	disableRecordButtons: function() {
		this.addObjectButton.disable();
		this.editObjectButton.disable();
		this.deleteObjectButton.disable();
		this.confirmObjectButton.disable();
	},
	enableAddButton: function(){
		this.addObjectButton.enable();
	},
	disableAddButton : function(){
		this.addObjectButton.disable();
	}
});
