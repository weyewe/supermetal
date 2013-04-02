class RemoveIsDeletedInMaterials < ActiveRecord::Migration
  def up
    remove_column :materials, :is_deleted 
  end

  def down
    
  end
end
