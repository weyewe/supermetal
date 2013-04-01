Ext.define('AM.model.Payment', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' },
    	{ name: 'code', type: 'string' } ,

			{ name: 'customer_id', type: 'int'},
			{ name: 'customer_name', type: 'string'},

			{ name: 'cash_account_id', type: 'int'},
			{ name: 'cash_account_name', type: 'string'},
			
			{ name: 'payment_method', type: 'int'},
			{ name: 'payment_method_name', type: 'string'},
			
			{ name: 'amount_paid', type: 'string'},
			{ name: 'downpayment_usage_amount', type: 'string'},
			{ name: 'downpayment_addition_amount', type: 'string'},
			
			{ name: 'note', type: 'string'},
			
			{ name: 'confirmed_at', type: 'string'},
			{ name: 'is_confirmed',type: 'boolean', defaultValue: false } 
  	],

	 

  	idProperty: 'id' ,proxy: {
			url: 'api/payments',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'payments',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { payment : record.data };
				}
			}
		}
	
  
});
