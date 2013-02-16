class Deliveries < Netzke::Basepack::Grid
  
  
  
  def configure(c)
    super
    c.model = "Delivery"
    c.columns = [
      :code,
      :customer__name,
      :confirmed_at  
    ]
  end

  include PgGridTweaks # the mixin , defining sorter 
end
