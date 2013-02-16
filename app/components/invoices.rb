class Invoices < Netzke::Basepack::Grid
   
  
  def configure(c)
    super
    c.model = "Invoice"
    c.columns = [
      :code,
      :customer__name,
      {
        name: :amount_payable,
        header: "Jumlah"
      },
      {
        name: :confirmed_pending_payment, 
        header: "Belum Terbayar"
      }
    ]
  end

  include PgGridTweaks # the mixin , defining sorter 
end
