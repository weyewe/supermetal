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
		}
	],

  init: function() {
    this.control({
      'templatesalesitemlist': {
        itemdblclick: this.editObject,
        selectionchange: this.selectionChange,
				afterrender : this.loadObjectList,
      },
      'templatesalesitemform button[action=save]': {
        click: this.updateObject
      },
      'templatesalesitemlist button[action=addObject]': {
        click: this.addObject
      },
      'templatesalesitemlist button[action=editObject]': {
        click: this.editObject
      },
      'templatesalesitemlist button[action=deleteObject]': {
        click: this.deleteObject
      }// ,
      // 			'preproductionresultform form' : {
      // 				'item_quantity_changed' : function(){
      // 					this.getTemplateSalesItemsStore().load();
      // 				}
      // 			},
      // 			'templatesalesitemlist textfield[name=searchField]': {
      //         change: this.liveSearch
      //       }
			
		
    });
  },

	liveSearch : function(grid, newValue, oldValue, options){
		var me = this;

		me.getTemplateSalesItemsStore().getProxy().extraParams = {
		    livesearch: newValue
		};
	 
		me.getTemplateSalesItemsStore().load();
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
		
		if(preProductionResultGrid){
			preProductionResultGrid.setTitle("Pre Production: " + record.get('code'));
			preProductionResultGrid.getStore().load({
				params : {
					template_sales_item_id : record.get('id')
				},
				callback : function(records, options, success){
					var totalObject  = records.length;
					if( totalObject ===  0 ){
						preProductionResultGrid.enableRecordButtons(); 
					}else{
						preProductionResultGrid.disableRecordButtons(); 
					}
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
