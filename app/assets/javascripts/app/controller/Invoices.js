Ext.define('AM.controller.Invoices', {
  extend: 'Ext.app.Controller',

  stores: ['Invoices'],
  models: ['Invoice'],

  views: [
    'payment.invoice.List',
    'payment.invoice.Form' 
  ],

  refs: [
		{
			ref: 'list',
			selector: 'invoicelist'
		} ,
		{
			ref: 'viewport',
			selector: 'vp'
		}
	],

  init: function() {
    this.control({
      'invoicelist': {
        itemdblclick: this.editObject,
        selectionchange: this.selectionChange,
				afterrender : this.loadObjectList
				
      },
      'invoiceform button[action=save]': {
        click: this.updateObject
      },
 
      'invoicelist button[action=editObject]': {
        click: this.editObject
      },
			'invoicelist button[action=downloadObject]': {
        click: this.downloadObject
      },
			'invoicelist textfield[name=searchField]': {
        change: this.liveSearch
      }
    });
  },

 
	liveSearch : function(grid, newValue, oldValue, options){
		var me = this;

		me.getInvoicesStore().getProxy().extraParams = {
		    livesearch: newValue
		};
	 
		me.getInvoicesStore().load();
	},
	
	downloadObject : function(){
		var me  = this;
		var record = this.getList().getSelectedObject();
		if(!record){ return; }
		
		window.open( '/print_invoice/' +  record.get("id") + '.pdf' , "_blank");
	},

	loadObjectList : function(me){
		me.getStore().load();
	},
 

  editObject: function() {
    var record = this.getList().getSelectedObject();
		if(!record){return;}
    var view = Ext.widget('invoiceform');
	
    view.down('form').loadRecord(record);
		view.setComboBoxData(record); 
  },

  updateObject: function(button) {
    var win = button.up('window');
    var form = win.down('form');

    var store = this.getInvoicesStore();
		var list = this.getList();
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
					list.fireEvent('updated', record );
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
			var newObject = new AM.model.Invoice( values ) ;
			
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
					list.fireEvent('updated', record);
					
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
		if(!record){return;}
		var list  = this.getList();
		list.setLoading(true); 
		
    if (record) {
			record.destroy({
				success : function(record){
					list.setLoading(false);
					list.fireEvent('deleted');	
					// this.getList().query('pagingtoolbar')[0].doRefresh();
					// console.log("Gonna reload the shite");
					// this.getInvoicesStore.load();
					list.getStore().load();
				},
				failure : function(record,op ){
					list.setLoading(false);
				}
			});
    }

  },

  selectionChange: function(selectionModel, selections) {
    var grid = this.getList();
		var record = this.getList().getSelectedObject();
		
		if(!record){
			return; 
		}
 
    if (selections.length > 0) {
      grid.enableRecordButtons();
    } else {
      grid.disableRecordButtons();
    }
  } 
	

});
