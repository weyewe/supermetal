Ext.define('AM.view.payment.Payment', {
    extend: 'AM.view.Worksheet',
    alias: 'widget.paymentProcess',
	 
		layout : {
			type : 'vbox',
			align : 'stretch'
		},
		
		items : [
			// {
			// 	html: "awesome payment",
			// 	title: " Payment Boom "
			// }
			{
				xtype : 'paymentlist' ,
				flex : 1  
			},
			{
				xtype : 'invoicepaymentlist',
				flex : 1 
			}
		]
});