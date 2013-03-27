Ext.define('AM.controller.ProductionResults', {
  extend: 'Ext.app.Controller',

  stores: ['ProductionResults', 'TemplateSalesItems'],
  models: ['ProductionResult'],

  views: [
    'factory.productionresult.List',
    'factory.productionresult.Form',
		'factory.templatesalesitem.List'
  ],

  refs: [
		{
			ref: 'list',
			selector: 'productionresultlist'
		},
		{
			ref : 'templateSalesItemList',
			selector : 'templatesalesitemlist'
		},
		{
			ref: 'viewport',
			selector: 'vp'
		}
	],

  init: function() {
    this.control({
      'productionresultlist': {
        itemdblclick: this.editObject,
        selectionchange: this.selectionChange,
				afterrender : this.loadObjectList
      },
      'productionresultform button[action=save]': {
        click: this.updateObject
      },
      'productionresultlist button[action=addObject]': {
        click: this.addObject
      },
      'productionresultlist button[action=editObject]': {
        click: this.editObject
      },
      'productionresultlist button[action=deleteObject]': {
        click: this.deleteObject
      },
			'productionresultlist button[action=confirmObject]': {
        click: this.confirmObject
      },
		
    });
  },
 
 	loadObjectList : function(me){
		me.getStore().loadData([],false);
	},
	
  addObject: function() {
		
		// I want to get the currently selected item 
		var record = this.getTemplateSalesItemList().getSelectedObject();
		if(!record){
			return; 
		}
		 
    var view = Ext.widget('productionresultform');
		
		view.setParentData( record );
		 
		
		
		
    view.show(); 
  },

  editObject: function() {
		var parentRecord = this.getTemplateSalesItemList().getSelectedObject();
    var record = this.getList().getSelectedObject();
		if( !parentRecord  || !record) {return;}

    var view = Ext.widget('productionresultform');
    view.down('form').loadRecord(record);
		view.setParentData( parentRecord );
		
  },

  updateObject: function(button) {
    var win = button.up('window');
    var form = win.down('form');
		var list = this.getList();

		var parentRecord = this.getTemplateSalesItemList().getSelectedObject();
    var store = this.getProductionResultsStore();
    var record = form.getRecord();
    var values = form.getValues();

		
		if( record ){
			record.set( values );
			 
			form.setLoading(true);
			record.save({
				success : function(record){
					form.setLoading(false);
					//  since the grid is backed by store, if store changes, it will be updated
					// form.fireEvent('item_quantity_changed');
					store.load({
						params: {
							template_sales_item_id : parentRecord.get('id')
						}
					});
					
					win.close();
					
					list.fireEvent('confirmed', record);
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
			var newObject = new AM.model.ProductionResult( values ) ;
			
			// learnt from here
			// http://www.sencha.com/forum/showthread.php?137580-ExtJS-4-Sync-and-success-failure-processing
			// form.mask("Loading....."); 
			form.setLoading(true);
			newObject.save({
				success: function(record){
					//  since the grid is backed by store, if store changes, it will be updated
					store.load({
						params: {
							template_sales_item_id : parentRecord.get('id')
						}
					});
					// form.fireEvent('item_quantity_changed');
					form.setLoading(false);
					win.close();
					list.fireEvent('confirmed', record);
				},
				failure: function( record, op){
					form.setLoading(false);
					var message  = op.request.scope.reader.jsonData["message"];
					var errors = message['errors'];
					form.getForm().markInvalid(errors);
					this.reject();
					
					if( errors["generic_errors"] ){
						Ext.MessageBox.show({
						           title: 'ERROR',
						           msg: errors["generic_errors"],
						           buttons: Ext.MessageBox.OK, 
						           icon: Ext.MessageBox.ERROR
						       });
					}
				}
			});
		} 
  },

  deleteObject: function() {
    var record = this.getList().getSelectedObject();

    if (record) {
      var store = this.getProductionResultsStore();
      store.remove(record);
      store.sync();
// to do refresh programmatically
		this.getList().query('pagingtoolbar')[0].doRefresh();
		this.getList().fireEvent('confirmed', record);
    }

  },
	confirmObject: function(){
		var me  = this;
		var record = this.getList().getSelectedObject();
		var list = this.getList();
		me.getViewport().setLoading( true ) ;
		
		if(!record){return;}
		
		Ext.Ajax.request({
		    url: 'api/confirm_production_result',
		    method: 'POST',
		    params: {
					id : record.get('id')
		    },
		    jsonData: {},
		    success: function(result, request ) {
						me.getViewport().setLoading( false );
						list.getStore().load({
							callback : function(records, options, success){
								// this => refers to a store 
								record = this.getById(record.get('id'));
								// record = records.getById( record.get('id'))
								list.fireEvent('confirmed', record);
							}
						});
						
		    },
		    failure: function(result, request ) {
						me.getViewport().setLoading( false ) ;
		    }
		});
	},
	

  selectionChange: function(selectionModel, selections) {
    var grid = this.getList();

		// var record = this.getList().getSelectedObject();

    if (selections.length > 0) {
      grid.enableRecordButtons();
    } else {
      grid.disableRecordButtons();
    }
 
  }

});
