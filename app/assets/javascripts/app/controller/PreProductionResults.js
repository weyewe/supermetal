Ext.define('AM.controller.PreProductionResults', {
  extend: 'Ext.app.Controller',

  stores: ['PreProductionResults', 'TemplateSalesItems'],
  models: ['PreProductionResult'],

  views: [
    'factory.preproductionresult.List',
    'factory.preproductionresult.Form',
		'factory.templatesalesitem.List'
  ],

  refs: [
		{
			ref: 'list',
			selector: 'preproductionresultlist'
		},
		{
			ref : 'templateSalesItemList',
			selector : 'templatesalesitemlist'
		}
	],

  init: function() {
    this.control({
      'preproductionresultlist': {
        itemdblclick: this.editObject,
        selectionchange: this.selectionChange,
				afterrender : this.loadObjectList
      },
      'preproductionresultform button[action=save]': {
        click: this.updateObject
      },
      'preproductionresultlist button[action=addObject]': {
        click: this.addObject
      },
      'preproductionresultlist button[action=editObject]': {
        click: this.editObject
      },
      'preproductionresultlist button[action=deleteObject]': {
        click: this.deleteObject
      } 
		
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
		 
    var view = Ext.widget('preproductionresultform');
		
		view.setParentData( record );
		 
		
		
		
    view.show(); 
  },

  editObject: function() {
		var parentRecord = this.getTemplateSalesItemList().getSelectedObject();
    var record = this.getList().getSelectedObject();
		if( !parentRecord  || !record) {return;}

    var view = Ext.widget('preproductionresultform');
    view.down('form').loadRecord(record);
		view.setParentData( parentRecord );
		
		console.log("The started at : " + record.get('started_at') );
		// view.down('form').getForm().findField('started_at').setValue(record.get('started_at'));
		
		
		// try this : http://aboutfrontend.com/extjs/extjs-date-format-demystified/
		// var iso_date = Date.parseDate(record.get("started_at"), "d/m/Y H:i:s");
		
		// http://www.mysamplecode.com/2012/03/extjs-convert-string-to-date.html
		var myDate = Ext.Date.parse(record.get("started_at"), "d/m/Y H:i:s");
		console.log("The date: " + myDate);
		
		view.down('form').getForm().findField('started_at').setValue( myDate );
		
  },

  updateObject: function(button) {
    var win = button.up('window');
    var form = win.down('form');

		var parentRecord = this.getTemplateSalesItemList().getSelectedObject();
    var store = this.getPreProductionResultsStore();
    var record = form.getRecord();
    var values = form.getValues();

		
		if( record ){
			record.set( values );
			 
			form.setLoading(true);
			record.save({
				success : function(record){
					form.setLoading(false);
					//  since the grid is backed by store, if store changes, it will be updated
					form.fireEvent('item_quantity_changed');
					store.load({
						params: {
							template_sales_item_id : parentRecord.get('id')
						}
					});
					
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
			var newObject = new AM.model.PreProductionResult( values ) ;
			
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
					form.fireEvent('item_quantity_changed');
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
      var store = this.getPreProductionResultsStore();
      store.remove(record);
      store.sync();
// to do refresh programmatically
		this.getList().query('pagingtoolbar')[0].doRefresh();
    }

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
