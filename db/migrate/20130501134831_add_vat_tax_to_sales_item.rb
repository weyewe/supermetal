class AddVatTaxToSalesItem < ActiveRecord::Migration
  def change
    add_column  :sales_items, :vat_tax, :decimal,  :precision => 5, :scale => 2
  end
end
