Ext.define('AM.model.SalesItem', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' },
    	{ name: 'code', type: 'string' } ,
			{ name: 'sales_order_code', type: 'string' },
			{ name: 'sales_order_id', type: 'int' },
			
			{ name: 'name', type: 'string'},
			{ name: 'description', type: 'string'},
			{ name: 'material_id', type: 'int'},
			{ name: 'weight_per_piece', type: 'string'},
			
			{ name: 'is_pending_pricing',type: 'boolean', defaultValue: false },
			
			{ name: 'is_pre_production',type: 'boolean', defaultValue: false },
			{ name: 'pre_production_price', type: 'string'},  
			
			{ name: 'is_production',type: 'boolean', defaultValue: false } ,
			{ name: 'production_price', type: 'string'}, 
			{ name: 'is_pricing_by_weight',type: 'boolean', defaultValue: false },
			{ name: 'quantity_for_production', type: 'int'},
			
			
			{ name: 'is_post_production',type: 'boolean', defaultValue: false }  ,
			{ name: 'post_production_price', type: 'string'}, 
			{ name: 'quantity_for_post_production', type: 'int'},
			
			{ name: 'is_delivered',type: 'boolean', defaultValue: false },
			{ name: 'delivery_address', type: 'string'},
			
			{ name: 'case', type: 'int'},
			
			{ name: 'is_repeat_order',type: 'boolean', defaultValue: false },
			{ name: 'template_sales_item_id', type: 'int' }
			
			
			
  	],

  	idProperty: 'id' ,proxy: {
			url: 'api/sales_items',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'sales_items',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { sales_item : record.data };
				}
			}
		}
	
  
});
