class CreateGuaranteeReturnEntries < ActiveRecord::Migration
  def change
    create_table :guarantee_return_entries do |t|
      t.integer :creator_id 
      t.integer :sales_item_id 
      
      t.integer :guarantee_return_id 
      t.string  :code
      
    
      t.integer :quantity_for_post_production  ,  :default => 0 
      t.decimal :weight_for_post_production  , :precision => 7, :scale => 2 , :default => 0 
      
      t.integer :quantity_for_production       ,  :default => 0 
      t.decimal :weight_for_production , :precision => 7, :scale => 2 , :default => 0
      
      
      t.integer :quantity_for_production_repair       ,  :default => 0 
      t.decimal :weight_for_production_repair , :precision => 7, :scale => 2 , :default => 0
      
      t.boolean :is_confirmed, :default => false
      
      
      t.integer :item_condition, :default => GUARANTEE_RETURN_ENTRY_ITEM_CONDITION[:production]
      
      t.boolean :is_deleted, :default => false 
      
      t.timestamps
    end
  end
end
