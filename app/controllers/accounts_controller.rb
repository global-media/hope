class AccountsController < ApplicationController  
  layout 'pages'
  
  before_filter :validate_logged_in, only: [:logout, :profile, :profile_edit, :profile_update]
  before_filter :validate_logged_out, except: [:logout, :profile, :profile_edit, :profile_update]
  
  def logout
    clear_session
    redirect_to :back
  end

  def signup
    @customer = Customer.new
  end
  
  def register
    @customer = Customer.new(customer_params)
    if @customer.save
      initialize_session(@customer)
      flash[:success] = 'Login success!'
      redirect_to redirect_to_url and return
    else
      @errors = @customer.errors
      flash[:error] = "Please fill up all information below and try again"
      render 'signup' and return
    end
    # redirect_to signup_accounts_url and return
  end
  
  def login
    @customer = Customer.new
  end
  
  def authenticate
    if @customer = Customer.verify?(params[:customer][:email], params[:customer][:password])
      initialize_session(@customer)
      flash[:success] = 'Login success!'
      redirect_to redirect_to_url and return 
    else
      flash[:error] = "We're sorry but your login information is invalid"
      render 'login' and return
    end    
    # redirect_to login_accounts_url and return
  end
  
  def send_forgot
    CustomerMailer.forgot_password_request(params[:email]).deliver_now
    flash[:success] = 'Please check your email to reset your password'
    redirect_to '/' and return
  end
  
  def reset
    redirect_to '/' unless verify_url?(:email)
    @customer = Customer.find_by_email(params[:email])    
  end
  
  def reset_password
    @customer = Customer.find(customer_params[:id])
    @customer.reset_password = true
    if @customer.update_attributes(customer_params)
      flash[:success] = 'We have successfully reset your password'
      redirect_to '/' and return
    else
      flash[:error] = 'We are sorry, we cannot update your password at this time'
      @errors = @customer.errors
      render 'reset' and return
    end
  end
  
  def profile
    @customer = Customer.find(customer['id'])
    initialize_customer(@customer)
  end
  
  def profile_edit
    @customer = Customer.find(customer['id'])
  end

  def profile_update
    @customer = Customer.find(customer['id'])
    if @customer.update_attributes(customer_params)
      flash[:success] = 'Update success!'
      redirect_to profile_accounts_url and return
    else
      @errors = @customer.errors
      flash[:error] = "We are sorry, we cannot update your account info at the moment"
      render 'profile_edit' and return
    end
  end
  
  protected
  
    def initialize_session(customer)
      initialize_customer(customer)
      initialize_cart(customer)
    end
    
    def clear_session
      session[:customer] = nil
      session[:cart] = nil
      initialize_cart
    end
    
    def validate_logged_in
      return true if logged_in?
      # flash[:error] = 'You are already logged out'
      redirect_to '/' and return
    end

    def validate_logged_out
      return true unless logged_in?
      # flash[:error] = 'You are already logged in'
      redirect_to '/' and return false
    end    
    
end
