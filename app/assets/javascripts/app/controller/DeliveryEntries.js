Ext.define('AM.controller.DeliveryEntries', {
  extend: 'Ext.app.Controller',

  stores: ['DeliveryEntries', 'Deliveries'],
  models: ['DeliveryEntry'],

  views: [
    'sales.deliveryentry.List',
    'sales.deliveryentry.Form',
		'sales.delivery.List'
  ],

  refs: [
		{
			ref: 'list',
			selector: 'deliveryentrylist'
		},
		{
			ref : 'parentList',
			selector : 'deliverylist'
		},
		{
			ref: 'viewport',
			selector: 'vp'
		}
	],

  init: function() {
    this.control({
      'deliveryentrylist': {
        itemdblclick: this.editObject,
        selectionchange: this.selectionChange ,
				afterrender : this.loadObjectList
      },
      'deliveryentryform button[action=save]': {
        click: this.updateObject
      },
			'deliveryentryfinalizeform button[action=save]': {
        click: this.updatePostDeliveryObject
      },
      'deliveryentrylist button[action=addObject]': {
        click: this.addObject
      },
      'deliveryentrylist button[action=editObject]': {
        click: this.editObject
      },
      'deliveryentrylist button[action=deleteObject]': {
        click: this.deleteObject
      },
			'deliveryentrylist button[action=finalizeObject]': {
        click: this.finalizeObject
      },

			// monitor parent(delivery) update
			'deliverylist' : {
				'updated' : this.reloadStore,
				'confirmed' : this.reloadStore,
				'deleted' : this.cleanList
			}
		
    });
  },

	loadObjectList : function(me){
		me.getStore().loadData([],false);
	},


	
	
	reloadStore : function(record){
		var list = this.getList();
		var store = this.getDeliveryEntriesStore();
		
		store.load({
			params : {
				delivery_id : record.get('id')
			}
		});
		
		list.setObjectTitle(record);
	},
	
	cleanList : function(){
		var list = this.getList();
		var store = this.getDeliveryEntriesStore();
		
		list.setTitle('');
		// store.removeAll(); 
		store.loadRecords([], {addRecords: false});
	},
 

  addObject: function() {
		
		// I want to get the currently selected item 
		var record = this.getParentList().getSelectedObject();
		if(!record){
			return; 
		}
		 
    var view = Ext.widget('deliveryentryform', {
			parentRecord : record 
		});
		view.setParentData( record );
    view.show(); 
  },

  editObject: function() {
		var parentRecord = this.getParentList().getSelectedObject();
		
    var record = this.getList().getSelectedObject();
		if(!record || !parentRecord){
			return; 
		}

    var view = Ext.widget('deliveryentryform', {
			parentRecord : parentRecord
		});

    view.down('form').loadRecord(record);
		view.setParentData( parentRecord );
		// console.log("selected record id: " + record.get('id'));
		// console.log("The selected poe id: " + record.get('purchase_order_entry_id'));
		view.setComboBoxData(record); 
  },

	updatePostDeliveryObject : function(button){
		var me = this; 
		var win = button.up('window');
    var form = win.down('form');

		var parentRecord = this.getParentList().getSelectedObject();
	
    var store = this.getDeliveryEntriesStore();
    var record = form.getRecord();
    var values = form.getValues();

		form.setLoading( true ) ;
 
		
		if(record){
			
			record.set( values );
			 
			form.query('checkbox').forEach(function(checkbox){
				record.set( checkbox['name']  ,checkbox['checked'] ) ;
			});
			
			form.setLoading(true);
			record.save({
				params : {
					delivery_id : parentRecord.get('id'),
					update_post_delivery: true 
				},
				success : function(record){
					form.setLoading(false);
					//  since the grid is backed by store, if store changes, it will be updated
					// form.fireEvent('item_quantity_changed');
					store.load({
						params: {
							delivery_id : parentRecord.get('id')
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
			
		}
	},

  updateObject: function(button) {
    var win = button.up('window');
    var form = win.down('form');

		var parentRecord = this.getParentList().getSelectedObject();
	
    var store = this.getDeliveryEntriesStore();
    var record = form.getRecord();
    var values = form.getValues();

		
		if( record ){
			record.set( values );
			 
			form.query('checkbox').forEach(function(checkbox){
				record.set( checkbox['name']  ,checkbox['checked'] ) ;
			});
			
			form.setLoading(true);
			record.save({
				params : {
					delivery_id : parentRecord.get('id')
				},
				success : function(record){
					form.setLoading(false);
					//  since the grid is backed by store, if store changes, it will be updated
					// form.fireEvent('item_quantity_changed');
					store.load({
						params: {
							delivery_id : parentRecord.get('id')
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
		
			var newObject = new AM.model.DeliveryEntry( values ) ;
			
		 
			
			form.query('checkbox').forEach(function(record){
				newObject.set( record['name']  ,record['checked'] ) ;
			});
			
			// populate the checkbox value to the object 
			
			// learnt from here
			// http://www.sencha.com/forum/showthread.php?137580-ExtJS-4-Sync-and-success-failure-processing
			// form.mask("Loading....."); 
			form.setLoading(true);
			newObject.save({
				params : {
					delivery_id : parentRecord.get('id')
				},
				success: function(record){
					//  since the grid is backed by store, if store changes, it will be updated
					store.load({
						params: {
							delivery_id : parentRecord.get('id')
						}
					});
					// form.fireEvent('item_quantity_changed');
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
		if(!record){return;}
		var parent_id = record.get('delivery_id');
		var list  = this.getList();
		list.setLoading(true); 
		
    if (record) {
			record.destroy({
				success : function(record){
					list.setLoading(false);
					list.fireEvent('deleted');	
					// this.getList().query('pagingtoolbar')[0].doRefresh();
					// console.log("Gonna reload the shite");
					// this.getPurchaseOrdersStore.load();
					list.getStore().load({
						params : {
							delivery_id : parent_id
						}
					});
				},
				failure : function(record,op ){
					list.setLoading(false);
					
					var message  = op.request.scope.reader.jsonData["message"];
					var errors = message['errors'];
					
					if( errors["generic_errors"] ){
						Ext.MessageBox.show({
						           title: 'DELETE FAIL',
						           msg: errors["generic_errors"],
						           buttons: Ext.MessageBox.OK, 
						           icon: Ext.MessageBox.ERROR
						       });
					}
					
				}
			});
    }

  },

	finalizeObject: function(){
		var parentRecord = this.getParentList().getSelectedObject();
    var record = this.getList().getSelectedObject();
		if(!record || !parentRecord){
			return; 
		}

    var view = Ext.widget('deliveryentryfinalizeform', {
			parentRecord : parentRecord
		});

    view.down('form').loadRecord(record);
		view.setParentData( parentRecord );
		// console.log("selected record id: " + record.get('id'));
		// console.log("The selected poe id: " + record.get('purchase_order_entry_id'));
		// view.setComboBoxData(record);
		
	},

  selectionChange: function(selectionModel, selections) {
    var grid = this.getList();

		var record = this.getList().getSelectedObject();
		
		if(!record){return;}
		

    if (selections.length > 0) {
      grid.enableRecordButtons();
			grid.enableFinalizeButton(record) ;
    } else {
      grid.disableRecordButtons();
    }
  }

});
