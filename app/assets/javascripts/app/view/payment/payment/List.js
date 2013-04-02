Ext.define('AM.view.payment.payment.List' ,{
  	extend: 'Ext.grid.Panel',
  	alias : 'widget.paymentlist',

  	store: 'Payments', 
 

	initComponent: function() {
		this.columns = [
			{ header: 'ID', dataIndex: 'id'},
			{
				xtype : 'templatecolumn',
				text : "Code",
				flex : 1,
				tpl : '<b>{code}</b>' + 
							'<br />' +  '<br />' +
							'Customer: <b>{customer_name}</b>' +
							'<br />' +  
							'Tanggal Pembayaran: <b>{confirmed_at}</b>'
				
			},
			{
				xtype : 'templatecolumn',
				text : "Status Konfirmasi",
				flex : 1,
				tpl : '<b>{is_confirmed}</b>' + 
							'<br />' +  '<br />' +
							'Methode Pembayaran: <b>{payment_method_name}</b>' +
							'<br />' +  
							'Akun Pembayaran: <b>{cash_account_name}</b>'
				
			},
			
			{
				xtype : 'templatecolumn',
				text : "Total",
				flex : 1,
				tpl : 'Pembayaran: <b>{amount_paid}</b>' + 	'<br />' +
						  																		'<br />' +
							'Penggunaan DP: <b>{downpayment_usage_amount}</b>'		+ 	'<br />' +
							'Penambahan DP: <b>{downpayment_addition_amount}</b>' + '<br />'
				
			}
		];

		this.addObjectButton = new Ext.Button({
			text: 'Add Payment',
			action: 'addObject'
		});

		this.editObjectButton = new Ext.Button({
			text: 'Edit Payment',
			action: 'editObject',
			disabled: true
		});

		this.deleteObjectButton = new Ext.Button({
			text: 'Delete Payment',
			action: 'deleteObject',
			disabled: true
		});
		
		this.confirmObjectButton = new Ext.Button({
			text: 'Confirm',
			action: 'confirmObject',
			disabled: true
		});
		
		this.searchField = new Ext.form.field.Text({
			name: 'searchField',
			hideLabel: true,
			width: 200,
			emptyText : "Search",
			checkChangeBuffer: 300
		});



		this.tbar = [ this.addObjectButton , this.editObjectButton, this.deleteObjectButton, this.confirmObjectButton, this.searchField ];
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
