Ext.define('AM.controller.TemplateSalesItems', {
  extend: 'Ext.app.Controller',

  stores: ['TemplateSalesItems'],
  models: ['TemplateSalesItem'],

  views: [
    'factory.templatesalesitem.List',
    'factory.templatesalesitem.Form',
    		'factory.preproductionresult.List',
  ],

  refs: [
		{
			ref: 'list',
			selector: 'templatesalesitemlist'
		},
		{
			ref : 'preProductionResultList',
			selector : 'preproductionresultlist'
		},
		{
			ref : 'productionResultList',
			selector : 'productionresultlist'
		},
		{
			ref : 'tabWrapper',
			selector : 'templatesalesitemProcess tabpanel'
		}
	],

  init: function() {
    this.control({
      'templatesalesitemlist': {
        // itemdblclick: this.editObject,
        selectionchange: this.selectionChange,
				afterrender : this.loadObjectList,
      },
      'templatesalesitemform button[action=save]': {
        click: this.updateObject
      },
      'templatesalesitemlist button[action=addObject]': {
        click: this.addObject
      },
   
      'templatesalesitemlist button[action=deleteObject]': {
        click: this.deleteObject
      },


			'preproductionresultlist' : {
				'confirmed' : this.reloadStore
			},
			'productionresultlist' : {
				'confirmed' : this.reloadStore
			},
			
			'templatesalesitemProcess tabpanel' : {
				tabchange : this.refreshActiveTab
			}
			
		
    });
  },

	liveSearch : function(grid, newValue, oldValue, options){
		var me = this;

		me.getTemplateSalesItemsStore().getProxy().extraParams = {
		    livesearch: newValue
		};
	 
		me.getTemplateSalesItemsStore().load();
	},
 

	reloadStore : function(record){
		console.log("IT IS CONFIRMED");
		var list = this.getList();
		var store = this.getTemplateSalesItemsStore();
		
		store.load();
		
		// list.setObjectTitle(record);
	},
	
	refreshActiveTab : function(tabpanel, newCard, oldCard){
		console.log("The newCard xtype: " + newCard.getXType() );
		var record = this.getList().getSelectedObject();
		
		if( newCard.getStore ){
			console.log("The get store exists");
			newCard.getStore().load({
				params : {
					template_sales_item_id : record.get('id')
				},
			});
			
			
		}else{
			console.log("The get store doesn't exist");
		}
	},

	loadObjectList : function(me){
		me.getStore().load();
	},

  addObject: function() {
    var view = Ext.widget('templatesalesitemform');
    view.show();
  },

  editObject: function() {
    var record = this.getList().getSelectedObject();
		if(!record){return;}
    var view = Ext.widget('templatesalesitemform');

    view.down('form').loadRecord(record);
  },

  updateObject: function(button) {
    var win = button.up('window');
    var form = win.down('form');

    var store = this.getTemplateSalesItemsStore();
    var record = form.getRecord();
    var values = form.getValues();

		
		if( record ){
			record.set( values );
			 
			form.setLoading(true);
			record.save({
				success : function(record){
					form.setLoading(false);
					//  since the grid is backed by store, if store changes, it will be updated
					store.load();
					win.close();
				},
				failure : function(record,op ){
					form.setLoading(false);
					var message  = op.request.scope.reader.jsonData["message"];
					var errors = message['errors'];
					form.getForm().markInvalid(errors);
					this.reject();
				}
			});
				
			 
		}else{
			//  no record at all  => gonna create the new one 
			var me  = this; 
			var newObject = new AM.model.TemplateSalesItem( values ) ;
			
			// learnt from here
			// http://www.sencha.com/forum/showthread.php?137580-ExtJS-4-Sync-and-success-failure-processing
			// form.mask("Loading....."); 
			form.setLoading(true);
			newObject.save({
				success: function(record){
					//  since the grid is backed by store, if store changes, it will be updated
					store.load();
					form.setLoading(false);
					win.close();
					
				},
				failure: function( record, op){
					form.setLoading(false);
					var message  = op.request.scope.reader.jsonData["message"];
					var errors = message['errors'];
					form.getForm().markInvalid(errors);
					this.reject();
				}
			});
		} 
  },

  deleteObject: function() {
    var record = this.getList().getSelectedObject();

    if (record) {
      var store = this.getTemplateSalesItemsStore();
      store.remove(record);
      store.sync();
// to do refresh programmatically
		this.getList().query('pagingtoolbar')[0].doRefresh();
    }

  },

  selectionChange: function(selectionModel, selections) {
    var grid = this.getList();
		var record = this.getList().getSelectedObject();
		
		if(!record){
			return; 
		}
		var preProductionResultGrid = this.getPreProductionResultList();
		var productionResultGrid = this.getProductionResultList(); 
		
		preProductionResultGrid.setTitle("Pre Production: " + record.get('code'));
		productionResultGrid.setTitle("Cor: " + record.get("code"));
		
		
		// set active item to preProductionResultGrid
		// and load it up
		this.getTabWrapper().setActiveTab(0);
		
		if(preProductionResultGrid){
			
			preProductionResultGrid.getStore().load({
				params : {
					template_sales_item_id : record.get('id')
				},
				callback : function(records, options, success){
					var totalObject  = records.length;
					preProductionResultGrid.enableRecordButtons(); 
					productionResultGrid.enableRecordButtons();
				}
			});
		}
		

    if (selections.length > 0) {
      grid.enableRecordButtons();
    } else {
      grid.disableRecordButtons();
    }
  }

});
