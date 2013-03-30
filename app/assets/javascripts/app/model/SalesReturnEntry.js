Ext.define('AM.model.SalesReturnEntry', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' },
			{ name: 'sales_return_code', type: 'string' },
			{ name: 'sales_return_id', type: 'int' },
			
			{ name: 'sales_item_name', type: 'string' },
			{ name: 'sales_item_code', type: 'string' },
			{ name: 'sales_item_id', type: 'string' },
			{ name: 'delivery_entry_id', type: 'string' },
			{ name: 'delivery_entry_code', type: 'string' },
			
			{ name: 'quantity_returned', type: 'int' },
			
			{ name: 'delivery_entry_item_condition_name', type: 'string' },
			{ name: 'delivery_entry_entry_case_name', type: 'string' },
			
			{ name: 'quantity_for_post_production', type: 'int' },
			{ name: 'quantity_for_production', type: 'int' },
			{ name: 'quantity_for_production_repair', type: 'int' },
			
			{ name: 'weight_for_post_production', type: 'string' },
			{ name: 'weight_for_production', type: 'string' },
			{ name: 'weight_for_production_repair', type: 'string' },
			
	   
			 
			{ name: 'is_confirmed',type: 'boolean', defaultValue: false } 
		 
			
  	],

  	idProperty: 'id' ,proxy: {
			url: 'api/sales_return_entries',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'sales_return_entries',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { sales_return_entry : record.data };
				}
			}
		}
	
  
});
