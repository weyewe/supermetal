Ext.define('AM.view.sales.deliveryentry.List' ,{
  	extend: 'Ext.grid.Panel',
  	alias : 'widget.deliveryentrylist',

  	store: 'DeliveryEntries', 
 

	initComponent: function() {
		this.columns = [
			{ header: 'Code',  dataIndex: 'code',  flex: 1 , sortable: false},
			{
				xtype : 'templatecolumn',
				text : "Item",
				flex : 1,
				dataIndex : 'name',
				tpl : '<b>{sales_item_code}</b>' + '<br />' + 
							'{sales_item_name}'+ '<br />' + '<br />' + 
							'Kasus Pengiriman: ' + '{entry_case_name}'+ '<br />' + 
							'Kondisi Barang: ' + '{item_condition_name}' 
				
			},
			{
				xtype : 'templatecolumn',
				text : "Pengiriman",
				flex : 1,
				tpl : 'Kuantitas: <b>{quantity_sent}</b>' + '<br />' + 
							'Berat: <b>{quantity_sent_weight}</b>' 
			},
			{
				xtype : 'templatecolumn',
				text : "Finalisasi Pengiriman",
				flex : 1,
				tpl : 'Kuantitas Terkirim: <b>{quantity_confirmed}</b>' + '<br />' +
							'Berat Terkirim: <b>{quantity_confirmed_weight}</b>' + '<br />' + '<br />' + 
							
							'Kuantitas Retur: <b>{quantity_returned}</b>'+  '<br />' +  
							'Berat Retur: <b>{quantity_returned_weight}</b>' + '<br />' + '<br />' + 
							
							'Hilang: <b>{quantity_lost}</b>'
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
		
		this.finalizeObjectButton = new Ext.Button({
			text: 'Finalize',
			action: 'finalizeObject',
			disabled: true
		});

	 
 



		this.tbar = [this.addObjectButton, this.editObjectButton,   this.deleteObjectButton, this.finalizeObjectButton  ];
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
		this.setTitle("Delivery: " + record.get("code"));
	},
	enableFinalizeButton: function(record){
		if(record.get('is_confirmed') === true ){
			this.finalizeObjectButton.enable();
		}else{
			this.finalizeObjectButton.disable();
		}
	}
});
