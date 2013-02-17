class SalesItems < Netzke::Basepack::Grid
  
  # how can we not show the add, delete?
  # read only ? in the Netzke::Basepack::Grid
  # only allow add in form? How?
  
  def configure(c)
    super
    c.model = "SalesItem"
    c.columns = [
      :code 
    ]
  end
   
  # The inspect action (and column)

  include PgGridTweaks # the mixin , defining sorter 
  include OnlyReadGrid
end
