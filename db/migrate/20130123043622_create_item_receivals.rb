class CreateItemReceivals < ActiveRecord::Migration
  def change
    create_table :item_receivals do |t|
      t.string  :code 
      
      
      t.date        :receival_date
      t.integer     :creator_id 
      t.integer     :customer_id
      # confirmed means that the goods are ready to leave the office.
      # the employee holds full responsibility for it
      t.boolean :is_confirmed, :default => false 
      t.integer :confirmer_id 
      t.datetime  :confirmed_at
      
      t.boolean :is_deleted, :default => false 

      t.timestamps
    end
  end
end
