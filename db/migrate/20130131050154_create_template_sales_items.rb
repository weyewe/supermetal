class CreateTemplateSalesItems < ActiveRecord::Migration
  def change
    create_table :template_sales_items do |t|
      t.string :code 
      t.boolean :is_internal_production, :default => true 
      t.integer :main_sales_item_id
      
      
      t.integer :material_id 
      t.string :name
      t.decimal :weight_per_piece, :precision => 7, :scale => 2 , :default => 0 
      t.text :description 
      t.timestamps
    end
  end
end
