Ext.define('AM.model.GuaranteeReturnEntry', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' },
			{ name: 'code', type: 'string' } ,
			
			{ name: 'guarantee_return_id', type: 'int' },
			
			{ name: 'sales_item_id', type: 'int' },
			{ name: 'sales_item_name', type: 'int' },
			{ name: 'sales_item_code', type: 'int' },
			
			{ name: 'item_condition', type: 'int' },
			{ name: 'item_condition_name', type: 'string' },
			
    	

			{ name: 'quantity_for_production', type: 'string' },
			{ name: 'quantity_for_production_repair', type: 'string' },
			{ name: 'quantity_for_post_production', type: 'string' },
			
			{ name: 'weight_for_production', type: 'string' },
			{ name: 'weight_for_production_repair', type: 'string' },
			{ name: 'weight_for_post_production', type: 'string' },
			
  	],

  	idProperty: 'id' ,proxy: {
			url: 'api/guarantee_return_entries',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'guarantee_return_entries',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { guarantee_return_entry : record.data };
				}
			}
		}
	
  
});
