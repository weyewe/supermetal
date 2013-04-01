Ext.define('AM.model.CashAccount', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' },
    	{ name: 'name', type: 'string' } ,
			{ name: 'description', type: 'string' } ,
			{ name: 'case', type: 'int' } ,
			{ name: 'case_name', type: 'int' }   
  	],

	 


   
  	idProperty: 'id' ,proxy: {
			url: 'api/cash_accounts',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'cash_accounts',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { cash_account : record.data };
				}
			}
		}
	
  
});
