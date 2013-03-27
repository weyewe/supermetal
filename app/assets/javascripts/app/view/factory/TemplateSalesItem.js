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
						title: 'Hasil Pola'
					},
					{
						xtype: 'productionresultlist',
						title: 'Hasil Cor'
					},
			 
					{
						xtype: 'productionrepairresultlist',
						title: 'Perbaiki Cor'
					},
					{
						xtype : "postproductionresultlist",
						title : 'Bubut'
					}
				]
			}
		]
		 

});