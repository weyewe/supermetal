Ext.define('AM.model.Delivery', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' },
    	{ name: 'code', type: 'string' } ,
			{ name: 'customer_id', type: 'int' },
			{ name: 'customer_name', type: 'string'},
			
			{ name: 'delivery_address', type: 'string'},
			{ name: 'delivery_date', type: 'string'},
			
			{ name: 'is_confirmed',type: 'boolean', defaultValue: false },
			{ name: 'is_finalized',type: 'boolean', defaultValue: false } 
  	],

	 

  	idProperty: 'id' ,proxy: {
			url: 'api/deliveries',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'deliveries',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { delivery : record.data };
				}
			}
		}
	
  
});
