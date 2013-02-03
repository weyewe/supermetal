class PreProductionResult < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :template_sales_item_id 
end
