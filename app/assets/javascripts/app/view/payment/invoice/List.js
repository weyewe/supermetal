Ext.define('AM.view.payment.invoice.List' ,{
  	extend: 'Ext.grid.Panel',
  	alias : 'widget.invoicelist',

  	store: 'Invoices', 
 

	initComponent: function() {
		this.columns = [
			{ header: 'ID', dataIndex: 'id'},
			{
				xtype : 'templatecolumn',
				text : "Code",
				flex : 1,
				tpl : '<b>{code}</b>' + 
							'<br />' +  '<br />' +
							'Delivery: <b>{delivery_code}</b>'
				
			},
			{ header: 'Jatuh Tempo',  dataIndex: 'due_date',  flex: 1 , sortable: false},
			
			{
				xtype : 'templatecolumn',
				text : "Total",
				flex : 1,
				tpl : 'Total: <b>{amount_payable}</b>' + 	'<br />' +
						  																		'<br />' +
							'Harga Jual: <b>{base_amount_payable}</b>'		+ 	'<br />' +
							'PPn (10%): <b>{tax_amount_payable}</b>' + '<br />'
				
			},
			{ header: 'Belum Dibayar',  dataIndex: 'confirmed_pending_payment',  flex: 1 , sortable: false}
		];

		this.addObjectButton = new Ext.Button({
			text: 'Add Invoice',
			action: 'addObject'
		});

		this.editObjectButton = new Ext.Button({
			text: 'Edit Invoice',
			action: 'editObject',
			disabled: true
		});

		this.deleteObjectButton = new Ext.Button({
			text: 'Delete Invoice',
			action: 'deleteObject',
			disabled: true
		});
		
		this.confirmObjectButton = new Ext.Button({
			text: 'Confirm',
			action: 'confirmObject',
			disabled: true
		});



		this.tbar = [  this.editObjectButton ];
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
