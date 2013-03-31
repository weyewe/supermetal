Ext.define('AM.model.Invoice', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' },
    	{ name: 'code', type: 'string' } ,

			{ name: 'customer_name', type: 'string'},
			{ name: 'delivery_code', type: 'string'},
			
			{ name: 'amount_payable', type: 'string'},
			{ name: 'base_amount_payable', type: 'string'},
			{ name: 'tax_amount_payable', type: 'string'},
			{ name: 'confirmed_pending_payment', type: 'string'},
			
			{ name: 'due_date', type: 'string'},
			
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
