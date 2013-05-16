Ext.define('AM.model.PostProductionResult', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' },
    	{ name: 'template_sales_item_id', type: 'int' },
			{ name: 'template_sales_item_name', type: 'string' },
			{ name: 'template_sales_item_code', type: 'string' },

			{ name: 'ok_quantity', type: 'int' },
			{ name: 'broken_quantity', type: 'int' },
			{ name: 'bad_source_quantity', type: 'int' },
			
			{ name: 'in_progress_quantity', type: 'int' },
			
			{ name: 'ok_weight', type: 'string' },
			{ name: 'broken_weight', type: 'string' },
			{ name: 'bad_source_weight', type: 'string' },
			
			 
			
			
			{ name: 'started_at', type: 'string'},
			{ name: 'finished_at', type: 'string'}, 
			
			{ name: 'is_confirmed',type: 'boolean', defaultValue: false }
  	],

  	idProperty: 'id' ,proxy: {
			url: 'api/post_production_results',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'post_production_results',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { post_production_result : record.data };
				}
			}
		}
	
  
});
