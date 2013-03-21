Ext.define('AM.model.TemplateSalesItem', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' },
    	{ name: 'name', type: 'string' },
			{ name: 'pending_production', type: 'int' },
			{ name: 'pending_post_production', type: 'int' },
			{ name: 'pending_production_repair', type: 'int' },
			{ name: 'ready_production', type: 'int' },
			{ name: 'ready_post_production', type: 'int' }
  	],

  	idProperty: 'id' ,proxy: {
			url: 'api/template_sales_items',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'template_sales_items',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { template_sales_item : record.data };
				}
			}
		}
	
  
});
