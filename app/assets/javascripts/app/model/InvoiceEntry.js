Ext.define('AM.model.InvoiceEntry', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' },
    	{ name: 'code', type: 'string' } ,
			
			{ name: 'sales_item_id', type: 'int' },
			{ name: 'sales_item_name', type: 'string' },
			{ name: 'sales_item_code', type: 'string' },
			{ name: 'sales_item_description', type: 'string' },
			{ name: 'sales_item_is_pricing_by_weight',type: 'boolean', defaultValue: false },
			{ name: 'sales_item_is_pending_pricing',type: 'boolean', defaultValue: false },
			{ name: 'sales_item_is_pre_production',type: 'boolean', defaultValue: false },
			{ name: 'sales_item_is_production',type: 'boolean', defaultValue: false },
			{ name: 'sales_item_is_post_production',type: 'boolean', defaultValue: false },
			
			{ name: 'sales_item_pre_production_price', type: 'string'},  
			{ name: 'sales_item_production_price', type: 'string'},  
			{ name: 'sales_item_post_production_price', type: 'string'},  
			
			{ name: 'billed_quantity', type: 'int' },
			{ name: 'billed_weight', type: 'string'},
			{ name: 'total_delivery_entry_price', type: 'string'},
			
			{ name: 'entry_case', type: 'int' },
    	{ name: 'entry_case_name', type: 'string' } ,

			{ name: 'item_condition', type: 'int' },
    	{ name: 'item_condition_name', type: 'string' } ,
  	],

  	idProperty: 'id' ,proxy: {
			url: 'api/invoice_entries',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'invoice_entries',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { invoice_entry : record.data };
				}
			}
		}
	
  
});
