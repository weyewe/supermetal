class ItemReceivals < Netzke::Basepack::Grid
   
  
  def configure(c)
    super
    c.model = "ItemReceival"
    c.columns = [
      :code,
      :customer__name,
      :confirmed_at  
    ]
  end

  include PgGridTweaks # the mixin , defining sorter 
  include OnlyReadGrid
end
