class AddIsDeletedToMaterials < ActiveRecord::Migration
  def change
    add_column :materials, :is_deleted, :boolean, :default => false 
  end
end
