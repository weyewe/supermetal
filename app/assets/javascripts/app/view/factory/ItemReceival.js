Ext.define('AM.view.factory.ItemReceival', {
    extend: 'AM.view.Worksheet',
    alias: 'widget.itemreceivalProcess',
	 
		layout : {
			type : 'vbox',
			align : 'stretch'
		},
		
		items : [
			// {
			// 	type : 'panel',
			// 	html : 'this is the factory order'
			// }
			{
				xtype : 'itemreceivallist' ,
				flex : 1  
			},
			{
				xtype : 'itemreceivalentrylist',
				flex : 1 
			}
		]
});