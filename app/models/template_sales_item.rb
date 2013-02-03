class TemplateSalesItem < ActiveRecord::Base
  # attr_accessible :title, :body
  
  has_many :sales_items 
  has_many :sales_item_subcriptions
  has_many :customers, :through => :sales_item_subcriptions 
  has_many :production_orders   # , :post_production_orders
  has_many :pre_production_results
  has_many :production_results
  has_many :production_repair_results
  has_many :post_production_results 
  
  validates_presence_of :code 
  
  def has_unconfirmed_production_result?
    self.production_results.where(:is_confirmed => false ).count != 0 
  end
  
  def has_unconfirmed_post_production_result?
    self.post_production_results.where(:is_confirmed => false ).count != 0 
  end
  
  def self.create_based_on_sales_item( sales_item )
    new_object = self.new
    new_object.code = sales_item.code 
  
    new_object.save 
    
    return new_object 
  end
  
  def confirmed_sales_items
    self.sales_items.where(:is_confirmed => true ).order("created_at ASC")
  end
end
