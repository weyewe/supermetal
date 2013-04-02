class CreateMaterials < ActiveRecord::Migration
  def change
    create_table :materials do |t|
      t.string :name 
      
      # t.boolean :is_deleted , :default => false 
      
      t.timestamps
    end
  end
end
