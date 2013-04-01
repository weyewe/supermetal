Ext.define('AM.view.sales.guaranteereturnentry.List' ,{
  	extend: 'Ext.grid.Panel',
  	alias : 'widget.guaranteereturnentrylist',

  	store: 'GuaranteeReturnEntries', 
 

	initComponent: function() {
		this.columns = [
			{ header: 'Code',  dataIndex: 'code',  flex: 1 , sortable: false},
			{
				xtype : 'templatecolumn',
				text : "Item",
				flex : 1,
				dataIndex : 'name',
				tpl : '<b>{name}</b>' + 
							'<br />' + 
							'{description}'
				
			},
			{
				xtype : 'templatecolumn',
				text : "Spec",
				flex : 1,
				dataIndex : 'weight_per_piece',
				tpl : 'Kuantitas Cor: <b>{quantity_for_production}</b>' + '<br />' + 
							'Kuantitas Bubut: <b>{quantity_for_post_production}</b>'+  '<br />' +  
							'Berat Satuan: <b>{weight_per_piece}</b> kg'
			},
			{
				xtype : 'templatecolumn',
				text : "Service",
				flex : 1,
				tpl : 'Pola: <b>{is_pre_production}</b>' + '<br />' + 
							'Cor: <b>{is_production}</b>'+  '<br />' +  
							'Bubut: <b>{is_post_production}</b>'
			},
			{
				xtype : 'templatecolumn',
				text : "Biaya",
				flex : 1,
				tpl : 'Pending Pricing: <b>{is_pending_pricing}</b>' + '<br />' + 
							'Pola: <b>{pre_production_price}</b>' + '<br />' + 
							'Cor: <b>{production_price}</b>'+  '<br />' +  
							'Biaya Cor berdasar berat: <b>{is_pricing_by_weight}</b>'+  '<br />' +  
							'Bubut: <b>{post_production_price}</b>'
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

	 
 



		this.tbar = [this.addObjectButton, this.editObjectButton, this.deleteObjectButton ];
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
		this.setTitle("Guarantee Return: " + record.get("code"));
	}
});
