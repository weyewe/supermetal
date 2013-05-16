Ext.define('AM.view.factory.postproductionresult.List' ,{
  	extend: 'Ext.grid.Panel',
  	alias : 'widget.postproductionresultlist',

  	store: 'PostProductionResults', 
 

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
			
			{ header: 'Dalam Pengerjaan',  dataIndex: 'in_progress_quantity',  flex: 1 , sortable: false},
			{
				xtype : 'templatecolumn',
				text : "OK",
				flex : 1,
				tpl : 'Jumlah: <b>{ok_quantity}</b>' + '<br />' + 
							'Berat: <b>{ok_weight}</b>'  
			},
			{
				xtype : 'templatecolumn',
				text : "Gagal",
				flex : 1,
				tpl : 'Jumlah: <b>{broken_quantity}</b>' + '<br />' + 
							'Berat: <b>{broken_weight}</b>'  
			},
			{
				xtype : 'templatecolumn',
				text : "Keropos",
				flex : 1,
				tpl : 'Jumlah: <b>{bad_source_quantity}</b>' + '<br />' + 
							'Berat: <b>{bad_source_weight}</b>'
			},
		
			{ header: 'Mulai',  dataIndex: 'started_at',  flex: 1 , sortable: false} ,
			{ header: 'Selesai',  dataIndex: 'finished_at',  flex: 1 , sortable: false} ,
			{ header: 'Konfirmasi',  dataIndex: 'is_confirmed',  flex: 1 , sortable: false}
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
