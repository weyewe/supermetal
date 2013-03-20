class Material < ActiveRecord::Base
  include UniqueNonDeleted
  attr_accessible :name, :code 
  
  validates_presence_of :name  
  validates_presence_of :code 
  validate :unique_non_deleted_name 
  
  def self.active_objects
    self.where(:is_deleted => false).order("id DESC")
  end
  
  def self.all_selectables
    selectables  =  self.active_objects 
    result = []
    selectables.each do |selectable| 
      result << [ "#{selectable.name}" , 
                      selectable.id ]  
    end
    return result
  end
  
  
  
  def delete
    self.is_deleted = true 
    self.save 
  end
end
