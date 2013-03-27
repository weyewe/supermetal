Ext.define('AM.store.ProductionRepairResults', {
  	extend: 'Ext.data.Store',
		require : ['AM.model.ProductionRepairResult'],
  	model: 'AM.model.ProductionRepairResult',
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
