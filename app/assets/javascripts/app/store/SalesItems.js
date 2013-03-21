Ext.define('AM.store.SalesItems', {
  	extend: 'Ext.data.Store',
		require : ['AM.model.SalesItem'],
  	model: 'AM.model.SalesItem',
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
