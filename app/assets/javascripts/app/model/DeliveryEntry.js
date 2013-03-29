Ext.define('AM.model.DeliveryEntry', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' },
    	{ name: 'code', type: 'string' } ,
			{ name: 'delivery_code', type: 'string' },
			{ name: 'delivery_id', type: 'int' },
			
			{ name: 'sales_item_id', type: 'int' },
			{ name: 'sales_item_name', type: 'string' },
			{ name: 'sales_item_code', type: 'string' },
			 
			{ name: 'quantity_sent', type: 'int' },
			{ name: 'quantity_sent_weight', type: 'string' },
			
			{ name: 'quantity_confirmed', type: 'int' },
			{ name: 'quantity_confirmed_weight', type: 'string' },
			
			{ name: 'quantity_lost', type: 'int' },
			
			{ name: 'quantity_returned', type: 'int' },
			{ name: 'quantity_returned_weight', type: 'string' },
			
			{ name: 'entry_case', type: 'int' },
			{ name: 'entry_case_name', type: 'string' },
			{ name: 'item_condition', type: 'int'},
			{ name: 'item_condition_name', type : 'string'},
			
			{ name: 'is_confirmed',type: 'boolean', defaultValue: false } ,
			{ name: 'is_finalized',type: 'boolean', defaultValue: false } 
			
  	],

  	idProperty: 'id' ,proxy: {
			url: 'api/delivery_entries',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'delivery_entries',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { delivery_entry : record.data };
				}
			}
		}
	
  
});
