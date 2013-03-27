Ext.define('AM.model.ProductionRepairResult', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' },
    	{ name: 'template_sales_item_id', type: 'int' },
			{ name: 'template_sales_item_name', type: 'string' },
			{ name: 'template_sales_item_code', type: 'string' },

			{ name: 'ok_quantity', type: 'int' },
			{ name: 'broken_quantity', type: 'int' },
			
			{ name: 'ok_weight', type: 'string' },
			{ name: 'broken_weight', type: 'string' },
		
			
			
			{ name: 'started_at', type: 'string'},
			{ name: 'finished_at', type: 'string'}, 
			
			{ name: 'is_confirmed',type: 'boolean', defaultValue: false }
  	],

  	idProperty: 'id' ,proxy: {
			url: 'api/production_repair_results',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'production_repair_results',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { production_repair_result : record.data };
				}
			}
		}
	
  
});
