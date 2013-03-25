Ext.define('AM.model.PreProductionResult', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' },
    	{ name: 'template_sales_item_id', type: 'int' },
			{ name: 'template_sales_item_name', type: 'string' },
			{ name: 'template_sales_item_code', type: 'string' },

			{ name: 'processed_quantity', type: 'int' },
			{ name: 'ok_quantity', type: 'int' },
			{ name: 'broken_quantity', type: 'int' },
			
			{ name: 'started_at', type: 'datetime' },
			{ name: 'finished_at', type: 'datetime' }, 
			{ name: 'is_confirmed',type: 'boolean', defaultValue: false }
			
			
  	],

  	idProperty: 'id' ,proxy: {
			url: 'api/pre_production_results',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'pre_production_results',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { pre_production_result : record.data };
				}
			}
		}
	
  
});
