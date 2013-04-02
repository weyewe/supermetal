Ext.define('AM.model.ItemReceivalEntry', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' },
			{ name: 'code', type: 'string' } ,
			
			{ name: 'item_receival_id', type: 'int' },
			{ name: 'item_receival_code', type: 'int' },
			
			{ name: 'sales_item_id', type: 'int' },
			{ name: 'sales_item_name', type: 'string' },
			{ name: 'sales_item_code', type: 'string' },
 

			{ name: 'quantity', type: 'string' },
			{ name: 'is_confirmed',type: 'boolean', defaultValue: false } 
			
  	],

  	idProperty: 'id' ,proxy: {
			url: 'api/item_receival_entries',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'item_receival_entries',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { item_receival_entry : record.data };
				}
			}
		}
	
  
});
