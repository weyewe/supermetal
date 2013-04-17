Ext.define('AM.store.InvoiceEntries', {
  	extend: 'Ext.data.Store',
		require : ['AM.model.InvoiceEntry'],
  	model: 'AM.model.InvoiceEntry',
  	// autoLoad: {start: 0, limit: this.pageSize},
		autoLoad : false, 
  	autoSync: false,
	pageSize : 10, 
	
	
		
		
	sorters : [
		{
			property	: 'id',
			direction	: 'DESC'
		}
	], 

	listeners: {

	} 
});
