Ext.define('AM.model.ItemReceival', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' },
    	{ name: 'code', type: 'string' } ,

			{ name: 'customer_id', type: 'int' },
			{ name: 'customer_name', type: 'string'},
			
			{ name: 'receival_date', type: 'string'},
			
			{ name: 'is_confirmed',type: 'boolean', defaultValue: false } 
  	],

	 

  	idProperty: 'id' ,proxy: {
			url: 'api/item_receivals',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'item_receivals',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { item_receival : record.data };
				}
			}
		}
	
  
});
