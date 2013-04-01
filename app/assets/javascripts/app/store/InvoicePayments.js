Ext.define('AM.store.InvoicePayments', {
  	extend: 'Ext.data.Store',
		require : ['AM.model.InvoicePayment'],
  	model: 'AM.model.InvoicePayment',
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
