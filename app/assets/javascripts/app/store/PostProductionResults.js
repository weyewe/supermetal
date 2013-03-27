Ext.define('AM.store.PostProductionResults', {
  	extend: 'Ext.data.Store',
		require : ['AM.model.PostProductionResult'],
  	model: 'AM.model.PostProductionResult',
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
