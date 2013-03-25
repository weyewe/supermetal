class Api::BaseApiController < ApplicationController
  respond_to :json
  
  def extjs_error_format( errors ) 
    new_error = {}
    errors.messages.each do |field, messages|
      aggregated_messages = "" 
      
      new_error[field.to_s] = messages.join(' | ')
    end
    
    return new_error 
  end
  
  
  def extract_datetime( datetime )
    if datetime.nil? or datetime.length ==0 
      return  nil 
    end
    
    date_array = datetime.split(" ").first 
    date_array = date_array.split('/')
    
    time_array =  datetime.split(" ").last 
    time_array = time_array.split(':')
    
    year  = 0
    month = 0 
    day   = 0
    if date_array.nil? || date_array.length == 0  
    else
      year  = date_array[0]
      month = date_array[1]
      day   = date_array[2]
    end
 
    hour   = 0 
    minute = 0 
    second = 0 
    if time_array.nil? || time_array.length == 0  
    else
      year   = time_array[0]
      month  = time_array[1]
      day    = time_array[2]
    end        
              
              
              
    new_datetime = DateTime.new( year, 
                  month, 
                  day, 
                  hour, 
                  minute, 
                  second, 
                  Rational( UTC_OFFSET , 24) )
              
    return new_datetime 
    
    # get the utc: new_datetime.getutc
  end
end