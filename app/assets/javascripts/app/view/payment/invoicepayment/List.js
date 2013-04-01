Ext.define('AM.view.payment.invoicepayment.List' ,{
  	extend: 'Ext.grid.Panel',
  	alias : 'widget.invoicepaymentlist',

  	store: 'InvoicePayments', 
 

	initComponent: function() {
		this.columns = [
			{ header: 'Code',  dataIndex: 'invoice_code',  flex: 1 , sortable: false},
			{
				xtype : 'templatecolumn',
				text : "Jumlah",
				flex : 1,
				dataIndex : 'name',
				tpl : '<b>{amount_paid}</b>'  
				
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
		
	 



		this.tbar = [this.addObjectButton, this.editObjectButton,   this.deleteObjectButton   ];
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
		this.setTitle("Payment: " + record.get("code"));
	}
});
