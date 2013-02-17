class TemplateSalesItems < Netzke::Basepack::Grid
  
  # how can we not show the add, delete?
  # read only ? in the Netzke::Basepack::Grid
  # only allow add in form? How?
  
  def configure(c)
    super
    c.model = "TemplateSalesItem"
    c.columns = [
      {name: :code,
        header: 'Item Code'  },
      :name,
      :description,
      {name: :pending_production,
        header: 'Pending Cor'  },
      {name: :pending_production_repair,
        header: 'Pending Perbaiki Cor'  },
      {name: :pending_post_production,
        header: 'Pending Bubut'  },
      {name: :pending_guarantee_return,
        header: 'Pending Retur Garansi'  },
    ]
  end

  include PgGridTweaks # the mixin , defining sorter 
  include OnlyReadGrid
end
