Ext.define('AM.store.ItemReceivals', {
  	extend: 'Ext.data.Store',
		require : ['AM.model.ItemReceival'],
  	model: 'AM.model.ItemReceival',
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
