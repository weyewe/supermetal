Ext.define('AM.store.GuaranteeReturns', {
  	extend: 'Ext.data.Store',
		require : ['AM.model.GuaranteeReturn'],
  	model: 'AM.model.GuaranteeReturn',
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
