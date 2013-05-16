class AddOnProgressToFactoryPhases < ActiveRecord::Migration
  def change
    add_column :pre_production_results, :in_progress_quantity, :integer , :default => 0
    add_column :production_results, :in_progress_quantity, :integer , :default => 0
    add_column :post_production_results, :in_progress_quantity, :integer , :default => 0
    add_column :production_repair_results, :in_progress_quantity, :integer , :default => 0
  end
end
