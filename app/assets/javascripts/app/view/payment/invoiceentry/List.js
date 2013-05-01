Ext.define('AM.view.payment.invoiceentry.List' ,{
  	extend: 'Ext.grid.Panel',
  	alias : 'widget.invoiceentrylist',

  	store: 'InvoiceEntries', 
 

	initComponent: function() {
		this.columns = [
			{
				xtype : 'templatecolumn',
				text : "Item",
				flex : 1,
				tpl : '<b>{sales_item_code}</b>'  + '<br />' + 
							"{sales_item_name}" + '<br />' + 
							"{sales_item_description}" + "<br /><br />" + 
							"Kondisi barang: {item_condition_name}" + "<br />" + 
							"Jenis Pengiriman: {entry_case_name}"
			},
			{
				xtype : 'templatecolumn',
				text : "Quantity",
				flex : 1,
				tpl : "{billed_quantity} ({billed_weight} kg)"
			},
			
			{
				xtype : 'templatecolumn',
				text : "Harga",
				flex : 1,
				tpl : Ext.create('Ext.XTemplate',
				
						'<tpl if="sales_item_is_pending_pricing == true">',
							"<b>PENDING PRICING</b>",
						'</tpl>',
						
						'<tpl if="sales_item_is_pending_pricing == false">',
						
							'<tpl if="sales_item_is_pre_production == true">',
								"Pola: <b>{sales_item_pre_production_price}</b><br />",
							'</tpl>',

							'<tpl if="sales_item_is_production == true">',
								"Cor: <b>{sales_item_production_price}</b>",
									'<tpl if="sales_item_is_pricing_by_weight == true">',
										'	(per kg)<br />',
									'</tpl>',

									'<tpl if="sales_item_is_pricing_by_weight == false">',
										' (per pcs)<br />',
									'</tpl>',
							'</tpl>',

							'<tpl if="sales_item_is_post_production == true">',
								"Bubut: <b>{sales_item_post_production_price}</b><br />",
							'</tpl>',
							
						'</tpl>'
						
						
         )
			},
			{
				xtype : 'templatecolumn',
				text : "Total",
				flex : 1,
				tpl : "{total_delivery_entry_price}"
			},
			{
				xtype : 'templatecolumn',
				text : "Tax",
				flex : 1,
				tpl : "{tax_amount}"
			},
			
			 
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
		// this.addObjectButton.enable();
		// this.editObjectButton.enable();
		// this.deleteObjectButton.enable();
	},

	disableRecordButtons: function() {
		// this.addObjectButton.disable();
		// this.editObjectButton.disable();
		// this.deleteObjectButton.disable();
	},
	
	setObjectTitle : function(record){
		this.setTitle("Invoice: " + record.get("code"));
	}
});
