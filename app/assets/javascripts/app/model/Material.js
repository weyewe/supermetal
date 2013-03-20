Ext.define('AM.model.Material', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' },
    	{ name: 'name', type: 'string' } ,
			{ name: 'code', type: 'string' } 
  	],

	 


   
  	idProperty: 'id' ,proxy: {
			url: 'api/materials',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'materials',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { material : record.data };
				}
			}
		}
	
  
});
