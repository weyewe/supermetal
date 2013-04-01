Ext.define('AM.store.Payments', {
  	extend: 'Ext.data.Store',
		require : ['AM.model.Payment'],
  	model: 'AM.model.Payment',
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
