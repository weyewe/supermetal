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
  
  
  def extract_date( date ) 
    if date.nil? or date.length == 0 
      return nil 
    end
    
    date_array = date.split("/")
    
    year  = 0
    month = 0 
    day   = 0
    if date_array.nil? || date_array.length == 0  
    else
      year  = date_array[2].to_i
      month = date_array[1].to_i 
      day   = date_array[0].to_i 
      
      # puts "year: #{year}"
      # puts "month : #{month}"
      # puts "day : #{day}"
    end
    
    new_date = Date.new( year, month, day)
    return new_date 
  end
  
  def extract_datetime( datetime )
    if datetime.nil? or datetime.length ==0 
      return  nil 
    end
    
    date_array = datetime.split(" ").first 
    # puts "The date_array : #{date_array}"
    date_array = date_array.split('/')
    
    time_array =  datetime.split(" ").last 
    # puts "The time_array : #{time_array}"
    time_array = time_array.split(':')
    
    
    
    year  = 0
    month = 0 
    day   = 0
    if date_array.nil? || date_array.length == 0  
    else
      year  = date_array[2].to_i
      month = date_array[1].to_i 
      day   = date_array[0].to_i 
      
      # puts "year: #{year}"
      # puts "month : #{month}"
      # puts "day : #{day}"
    end
 
    hour   = 0 
    minute = 0 
    second = 0 
    if time_array.nil? || time_array.length == 0  
    else
      hour    = time_array[0].to_i
      minute  = time_array[1].to_i
      second  = time_array[2].to_i
      # puts "hour: #{hour}"
      # puts "minute : #{minute}"
      # puts "second : #{second}"
    end        
              
     
     
    new_datetime = DateTime.new( year, 
                  month, 
                  day, 
                  hour, 
                  minute, 
                  second, 
                  Rational( UTC_OFFSET , 24) )
              
    return new_datetime.getutc 
    
    # get the utc: new_datetime.getutc
  end
  
  # def format_datetime( datetime ) 
  #   return nil if datetime.nil? 
  #   
  #   a = datetime.in_time_zone("Jakarta")
  #   
  #   return "#{a.day}/#{a.month}/#{a.year}" + " " + 
  #           "#{a.hour}:#{a.min}:#{a.sec}"
  # end
end