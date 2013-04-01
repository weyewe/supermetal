Ext.define('AM.model.GuaranteeReturn', {
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
			url: 'api/guarantee_returns',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'guarantee_returns',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { guarantee_return : record.data };
				}
			}
		}
	
  
});
