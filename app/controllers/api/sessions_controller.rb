class Api::SessionsController < Api::BaseApiController
  before_filter :say_moron
  # before_filter :authenticate_user!, :except => [:create, :destroy, :say_hi ]
  before_filter :ensure_params_exist, :except => [:say_hi, :destroy, :authenticate_auth_token]
  skip_before_filter :authenticate_user! #, :only => [:create, :destroy, :say_hi ]
  respond_to :json
 
  def say_moron
    puts "YOU are moron.. here we are.. what is happening?\n"*10
    if  params[:user_login].nil?
      return nil
    end
    puts "The password: #{params[:user_login][:password]}" 
    puts "The email: #{params[:user_login][:email]}"
    
    puts "The params: #{params.inspect}"
    
    puts "**********************\n"*10
    puts "In the create-emulation"
    resource = User.find_for_database_authentication(:email => params[:user_login][:email])
    
    if not resource.nil?
      puts "The resource is not nil"
      puts "The resource: #{resource.inspect}"
    else
      return
    end
    
    if resource.valid_password?(params[:user_login][:password])
      puts "THe password is valid"
    end
    
    puts "********************* end of say_moron"
    
    
  end
 
  def create
    
    puts "**********************\n"*10
    puts "In the create"
    resource = User.find_for_database_authentication(:email => params[:user_login][:email])
    puts "The resource: #{resource.inspect}"
    return invalid_login_attempt unless resource
    
    puts "Resurce is valid"
 
    if resource.valid_password?(params[:user_login][:password])
      puts "The password is valid"
      sign_in(:user, resource)
      resource.ensure_authentication_token!
      render :json=> {:success=>true, 
                      :auth_token=>resource.authentication_token, 
                      :email=>resource.email,
                      :role => resource.role.to_json
              }
      return
    end
    
    puts "The password is invalid"
    invalid_login_attempt
  end
  
  def say_hi
    render :json=> {:success=>true, 
                    :msg => "Server: This is your coffee!"
            }
  end
  
  def authenticate_auth_token
    render :json => {:success => true }
  end
 
  def destroy
    # resource = User.find_for_database_authentication(:email => params[:user_login][:email])
    resource = User.find_by_authentication_token( params[:auth_token])
    if resource
      resource.authentication_token = nil
    end
    # resource.save
    
    if resource and resource.save
      render :json=> {:success=>true}
    else
      render :json=> {:success=>false}
    end
    
  end
 
  protected
  def ensure_params_exist
    puts "We are inside the ensure params_exist"
    return unless params[:user_login].blank?
    puts "haiz, params does not exists!!!!!"
    render :json=>{:success=>false, :message=>"missing user_login parameter"}, :status=>422
  end
 
  def invalid_login_attempt
    puts "888\n"*5
    puts "Invalid login attempt"
    render :json=> {:success=>false, :message=>"Error with your login or password"}, :status=>401
  end
end