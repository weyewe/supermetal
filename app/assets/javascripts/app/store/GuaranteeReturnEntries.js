Ext.define('AM.store.GuaranteeReturnEntries', {
  	extend: 'Ext.data.Store',
		require : ['AM.model.GuaranteeReturnEntry'],
  	model: 'AM.model.GuaranteeReturnEntry',
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
