class CreateProductionRepairOrders < ActiveRecord::Migration
  def change
    create_table :production_repair_orders do |t|
      t.integer :template_sales_item_id  
      t.integer :creator_id 
      
      
      t.integer :case     , :default  => PRODUCTION_REPAIR_ORDER[:production_repair]
      
      t.integer :quantity 
      
      t.string  :source_document_entry
      t.integer :source_document_entry_id
      t.string  :source_document 
      t.integer :source_document_id

      t.timestamps
    end
  end
end
