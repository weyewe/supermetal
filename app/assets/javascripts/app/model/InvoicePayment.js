Ext.define('AM.model.Invoice', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' },
    	{ name: 'code', type: 'string' } ,

			{ name: 'payment_id', type: 'int'},
			{ name: 'payment_code', type: 'string'},
			
			{ name: 'invoice_id', type: 'int'},
			{ name: 'invoice_code', type: 'string'},
			
			{ name: 'amount_paid', type: 'string'}, 
			
			{ name: 'is_confirmed',type: 'boolean', defaultValue: false } 
  	],

	 

  	idProperty: 'id' ,proxy: {
			url: 'api/invoices',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'invoices',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { invoice : record.data };
				}
			}
		}
	
  
});
