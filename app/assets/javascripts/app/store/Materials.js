Ext.define('AM.store.Materials', {
  	extend: 'Ext.data.Store',
		require : ['AM.model.Material'],
  	model: 'AM.model.Material',
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
