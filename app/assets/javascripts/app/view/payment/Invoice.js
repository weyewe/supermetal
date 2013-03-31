Ext.define('AM.view.payment.Invoice', {
    extend: 'AM.view.Worksheet',
    alias: 'widget.invoiceProcess',
	 
		layout : {
			type : 'vbox',
			align : 'stretch'
		},
		
		items : [
			// {
			// 	html: "awesome invoice",
			// 	title: " Invoice Boom "
			// }
			{
				xtype : 'invoicelist' ,
				flex : 1  
			},
			// {
			// 	xtype : 'invoiceentrylist',
			// 	flex : 1 
			// }
		]
});