Ext.define('AM.view.factory.TemplateSalesItem', {
    extend: 'AM.view.Worksheet',
    alias: 'widget.templatesalesitemProcess',
	 
		
 		layout : {
			type : 'vbox',
			align : 'stretch'
		},
		
		items : [
			{
				xtype: 'templatesalesitemlist',
				flex : 1  
			},
			{
				xtype : 'tabpanel',
				activeTab : 0 ,
				flex : 1  ,
				items : [
					{
						xtype: 'preproductionresultlist',
						// html : "Big MOrono",
						title: 'Hasil Pola'
					},
					{
						html : "Production",
						title : 'Hasil Cor'
					},
					{
						html : "Production Repair",
						title : 'Hasil Perbaiki Cor'
					},
					{
						html : "Post Production",
						title : 'Hasil Bubut'
					}
				]
			}
		]
		 

});