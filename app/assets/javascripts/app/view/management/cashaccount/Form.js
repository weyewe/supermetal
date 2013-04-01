Ext.define('AM.view.management.cashaccount.Form', {
  extend: 'Ext.window.Window',
  alias : 'widget.cashaccountform',

  title : 'Add / Edit Cash Account',
  layout: 'fit',
	width	: 500,
  autoShow: true,  // does it need to be called?
// win.show() 
// if autoShow == true.. on instantiation, will automatically be called 
	
  initComponent: function() {
	
		var remoteJsonStore = Ext.create(Ext.data.JsonStore, {
			storeId : 'cash_account_search',
			fields	: [
	 				{
						name : 'case',
						mapping : "value"
					},
					{
						name : 'case_name',
						mapping : 'text'
					}
			],
			proxy  	: {
				type : 'ajax',
				url : 'api/search_cash_account_case',
				reader : {
					type : 'json',
					root : 'records', 
					totalProperty  : 'total'
				}
			},
			autoLoad : false 
		});
		
		
    this.items = [{
      xtype: 'form',
			msgTarget	: 'side',
			border: false,
      bodyPadding: 10,
			fieldDefaults: {
          labelWidth: 165,
					anchor: '100%'
      },
      items: [
				{
					xtype: 'textfield',
					name : 'description',
					fieldLabel: 'Deskripsi'
				},
				{
					xtype: 'textfield',
					name : 'name',
					fieldLabel: 'Nama'
				},
				{
					fieldLabel: 'Cash Account Case',
					xtype: 'combo',
					queryMode: 'remote',
					forceSelection: true, 
					displayField : 'case_name',
					valueField : 'case',
					pageSize : 5,
					minChars : 1, 
					allowBlank : false, 
					triggerAction: 'all',
					store : remoteJsonStore , 
					listConfig : {
						getInnerTpl: function(){
							return  	'<div data-qtip="{case_name}">' +  
													'<div class="combo-name">{case_name}</div>' +  
							 					'</div>';
						}
					},
					name : 'case' 
				}
			]
    }];

    this.buttons = [{
      text: 'Save',
      action: 'save'
    }, {
      text: 'Cancel',
      scope: this,
      handler: this.close
    }];

    this.callParent(arguments);
  },

	setComboBoxData : function( record){
	
		var case_value = record.get("case");
		var comboBox = this.down('form').getForm().findField('case'); 
		var me = this; 
		var store = comboBox.store; 
		store.load({
			params: {
				selected_id : case_value 
			},
			callback : function(records, options, success){
				me.setLoading(false);
				comboBox.setValue( case_value );
			}
		});
	}
});

