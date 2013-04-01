Ext.define('AM.view.sales.GuaranteeReturn', {
    extend: 'AM.view.Worksheet',
    alias: 'widget.guaranteereturnProcess',
	 
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
				xtype : 'guaranteereturnlist' ,
				flex : 1  
			},
			{
				xtype : 'guaranteereturnentrylist',
				flex : 1 
			}
		]
});