Ext.define('AM.store.ProductionResults', {
  	extend: 'Ext.data.Store',
		require : ['AM.model.ProductionResult'],
  	model: 'AM.model.ProductionResult',
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
