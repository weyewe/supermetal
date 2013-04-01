Ext.define('AM.store.CashAccounts', {
  	extend: 'Ext.data.Store',
		require : ['AM.model.CashAccount'],
  	model: 'AM.model.CashAccount',
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
