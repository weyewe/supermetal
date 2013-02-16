class ProductionRepairResults < Netzke::Basepack::Grid
  
  # how can we not show the add, delete?
  # read only ? in the Netzke::Basepack::Grid
  # only allow add in form? How?
  
  def configure(c)
    super
    c.model = "ProductionRepairResult"
    c.columns = [
      {name: :template_sales_item__code,
        header: 'Item Code'  },
      :ok_quantity,
      :broken_quantity 
    ]
  end

  include PgGridTweaks # the mixin , defining sorter 
end
