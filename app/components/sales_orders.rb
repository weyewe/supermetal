class SalesOrders < Netzke::Basepack::Grid
  
  # how can we not show the add, delete?
  # read only ? in the Netzke::Basepack::Grid
  # only allow add in form? How?
  
  def configure(c)
    super
    c.model = "SalesOrder"
    c.inspect_url =   '/sales_order_details'
    c.columns = [
      :code,
      :customer__name,
      {
        name: :inspect, 
        width: 20 
      }
    ]
  end
   
  # The inspect action (and column)
  include Netzke::Weyewe::Inspectable

  include PgGridTweaks # the mixin , defining sorter 
  include OnlyReadGrid
end
