Ext.define('AM.view.sales.Delivery', {
    extend: 'AM.view.Worksheet',
    alias: 'widget.deliveryProcess',
	 
		layout : {
			type : 'vbox',
			align : 'stretch'
		},
		
		items : [
			// {
			// 	type : 'panel',
			// 	html : 'this is the sales order'
			// }
			// {
			// 	type : 'panel',
			// 	html : "ths is the delivery panel"
			// }
			{
				xtype : 'deliverylist' ,
				flex : 1  
			},
			{
				xtype : 'deliveryentrylist',
				flex : 1 
			}
		]
});