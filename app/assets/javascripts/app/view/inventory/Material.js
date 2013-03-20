Ext.define('AM.view.inventory.Material', {
    extend: 'AM.view.Worksheet',
    alias: 'widget.materialProcess',
	 
		
		items : [
			{
				xtype : 'materiallist' ,
				flex : 1 
			} 
		]
});