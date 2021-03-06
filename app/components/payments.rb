class Payments < Netzke::Communitypack::LiveSearchGrid
   
  
  def configure(c)
    super
    c.model = "Payment"
    c.inspect_url =   '/payment_details'
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
