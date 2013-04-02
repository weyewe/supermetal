Ext.define("AM.controller.Authorization", {
	extend : "Ext.app.Controller",
	views : [
		"ProtectedContent"
	],

	 
	
	refs: [
		{
			ref: 'protectedContent',
			selector: 'protected'
		},
		{
			ref : 'userMenu',
			selector : 'appHeader #optionsMenu'
		}
	],
	

	 
	init : function( application ) {
		var me = this; 
		 
		me.control({
			"protected" : {
				activate : this.onActiveProtectedContent
			} 
			
		});
		
	},
	
	onActiveProtectedContent: function( panel, options) {
		var me  = this; 
		var currentUser = Ext.decode( localStorage.getItem('currentUser'));
		var email = currentUser['email'];
		// console.log("onActive Protected Content");
		
		// build the navigation tree 
		var processList = panel.down('processList');
		processList.setLoading(true);
	
		var treeStore = processList.getStore();
		treeStore.removeAll(); 
		 
		
		var data = {
		    text:"text root",
		    children: 
		        [
		            {
		                text:'Management', 
		                viewClass:'', 
		                iconCls:'text-folder', 
		                expanded: true,
		                children:
		                [
		                    
	                    { 
	                        text:'Employee', 
	                        viewClass:'AM.view.management.Employee', 
	                        leaf:true, 
	                        iconCls:'text' 
	                    },
	                    { 
	                        text:'User', 
	                        viewClass:'AM.view.management.User', 
	                        leaf:true, 
	                        iconCls:'text' 
	                    },
											{ 
	                        text:'Cash Account', 
	                        viewClass:'AM.view.management.CashAccount', 
	                        leaf:true, 
	                        iconCls:'text' 
	                    }
		                    
		                ]
		            },
 								{
 									text:'Inventory', 
 	                viewClass:'Will', 
 	                iconCls:'text-folder', 
 	                expanded: true,
 	                children:
 	                [
 										{ 
 		                     text:'Material', 
 		                     viewClass:'AM.view.inventory.Material', 
 		                     leaf:true, 
 		                     iconCls:'text' 
 		                 }
 	                ]
 								},
								{
									text:'Pabrik', 
	                viewClass:'Will', 
	                iconCls:'text-folder', 
	                expanded: true,
	                children:
	                [
	                
                    { 
                        text:'Penerimaan Bahan Bubut', 
                        viewClass:'AM.view.factory.ItemReceival', 
                        leaf:true, 
                        iconCls:'text' 
                    },
                    { 
                        text:'Pengerjaan Pabrik', 
                        viewClass:'AM.view.factory.TemplateSalesItem', 
                        leaf:true, 
                        iconCls:'text' 
                    }
	                ]
								},
 								{
 									text:'Sales', 
 	                viewClass:'Will', 
 	                iconCls:'text-folder', 
 	                expanded: true,
 	                children:
 	                [
 	                    
                     { 
                         text:'Customer', 
                         viewClass:'AM.view.sales.Customer', 
                         leaf:true, 
                         iconCls:'text' 
                     },
                     { 
                         text:'Penjualan', 
                         viewClass:'AM.view.sales.SalesOrder', 
                         leaf:true, 
                         iconCls:'text' 
                     },
 										{ 
                         text:'Pengiriman', 
                         viewClass:'AM.view.sales.Delivery', 
                         leaf:true, 
                         iconCls:'text' 
                     },
 										{ 
                         text:'Sales Return', 
                         viewClass:'AM.view.sales.SalesReturn', 
                         leaf:true, 
                         iconCls:'text' 
                     },
										{ 
                         text:'Guarantee Return', 
                         viewClass:'AM.view.sales.GuaranteeReturn', 
                         leaf:true, 
                         iconCls:'text' 
                     }
										
 	                    
 	                ]
 								},
								{
 									text:'Payment', 
 	                viewClass:'Will', 
 	                iconCls:'text-folder', 
 	                expanded: true,
 	                children:
 	                [
 	                    
                     { 
                         text:'Invoice', 
                         viewClass:'AM.view.payment.Invoice', 
                         leaf:true, 
                         iconCls:'text' 
                     },
                     { 
                         text:'Pembayaran', 
                         viewClass:'AM.view.payment.Payment', 
                         leaf:true, 
                         iconCls:'text' 
                     }
 	                    
 	                ]
 								}
		        ]
	
		    };
		
		
		treeStore.setRootNode(data);
		processList.setLoading(false);
		
		// Update the title of the menu button
		// console.log("Gonna update the user menu");
		var userMenu = me.getUserMenu();

		userMenu.setText( email );
	}
});