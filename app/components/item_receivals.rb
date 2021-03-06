class ItemReceivals < Netzke::Basepack::Grid
   
  
  def configure(c)
    super
    c.model = "ItemReceival"
    c.inspect_url =   '/item_receival_details'
    c.columns = [
      :code,
      :customer__name,
      :confirmed_at ,
      {
        name: :inspect, 
        width: 20 
      } 
    ]
  end

  include Netzke::Weyewe::Inspectable
  include PgGridTweaks # the mixin , defining sorter 
  include OnlyReadGrid
end
