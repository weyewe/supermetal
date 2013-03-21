Ext.define('AM.store.TemplateSalesItems', {
	extend: 'Ext.data.Store',
	require : ['AM.model.TemplateSalesItem'],
	model: 'AM.model.TemplateSalesItem',
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
