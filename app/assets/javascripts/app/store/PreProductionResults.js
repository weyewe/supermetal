Ext.define('AM.store.PreProductionResults', {
  	extend: 'Ext.data.Store',
		require : ['AM.model.PreProductionResult'],
  	model: 'AM.model.PreProductionResult',
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
