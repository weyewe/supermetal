class SalesReturns < Netzke::Basepack::Grid
   
  def configure(c)
    super
    c.model = "SalesReturn"
    c.columns = [
      :code,
      :delivery__code  
    ]
  end

  include PgGridTweaks # the mixin , defining sorter 
end
