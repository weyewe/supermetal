Ext.define('AM.view.sales.Customer', {
    extend: 'AM.view.Worksheet',
    alias: 'widget.customerProcess',
	 
		
		items : [
			{
				xtype : 'customerlist' ,
				flex : 1 
			} 
		]
});