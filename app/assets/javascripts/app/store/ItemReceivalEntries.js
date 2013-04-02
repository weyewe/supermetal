Ext.define('AM.store.ItemReceivalEntries', {
  	extend: 'Ext.data.Store',
		require : ['AM.model.ItemReceivalEntry'],
  	model: 'AM.model.ItemReceivalEntry',
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
