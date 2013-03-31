class AddBaseAmountAndTaxAmountForAmountPayable < ActiveRecord::Migration
  def up
    add_column  :invoices, :base_amount_payable, :decimal, :default => 0,  :precision => 11, :scale => 2
    add_column  :invoices, :tax_amount_payable, :decimal, :default => 0,  :precision => 11, :scale => 2
  end

  def down
    remove_column  :invoices, :base_amount_payable
    remove_column  :invoices, :tax_amount_payable
  end
end
