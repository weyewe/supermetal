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
			{
				xtype : 'deliverylist' ,
				flex : 1  
			}// ,
			// 			{
			// 				xtype : 'salesitemlist',
			// 				flex : 1 
			// 			}
		]
});