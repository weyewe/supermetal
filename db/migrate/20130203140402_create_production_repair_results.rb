class CreateProductionRepairResults < ActiveRecord::Migration
  def change
    create_table :production_repair_results do |t|
      t.integer :template_sales_item_id  
      t.integer  :creator_id
      
      t.integer  :processed_quantity     ,          :default => 0
      t.integer  :ok_quantity            ,          :default => 0
      t.integer  :broken_quantity        ,          :default => 0
      t.decimal  :ok_weight,                        :precision => 7, :scale => 2, :default => 0
      t.decimal  :broken_weight,                    :precision => 7, :scale => 2, :default => 0
      t.datetime     :started_at
      t.datetime     :finished_at
      t.boolean  :is_confirmed ,      :default => false
      t.integer  :confirmer_id
      t.datetime :confirmed_at


      t.timestamps
    end
  end
end
