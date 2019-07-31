require "./config/environment"
require "./app/models/user"
require 'pry'
class ApplicationController < Sinatra::Base

  configure do
    set :views, "app/views"
    enable :sessions
    set :session_secret, "password_security"
  end

  get "/" do
    erb :index
  end

  get "/signup" do
    erb :signup
  end

  # Create new user from username and password. If password isn't filled, user.save will return false and redirect to failure page.
  post "/signup" do
    if params[:username].empty? || params[:password].empty?
      redirect "/failure"
    else 
      user = User.new(username: params[:username], password: params[:password])
    end
    
		if user.save
			redirect "/login"
		else
			redirect "/failure"
		end
  end

  # Display after successful login
  get '/account' do
    if logged_in?
      erb :account
    else 
      redirect "/failure"
    end
  end

  # Process deposits and withdrawls
  patch '/account' do
    if current_user
      new_amount = 0
      amount = params[:amount].to_f

      # Create new balance
      new_amount = current_user.balance + amount

      # Ensure that money is available for withdrawl
      if new_amount < 0
        @message = "Not enough money in account! Please withdraw less than your current balance."
      else 
        current_user.update(balance: new_amount)
        current_user.save
        @message = "Success! Your account has been updated."
      end

      erb :account
    else
      redirect "/failure" 
    end
  end

  get "/login" do
    erb :login
  end

  # Find user, compare password with stored version. Redirect for success or failure.
  post "/login" do
		user = User.find_by(username: params[:username])
		if user && user.authenticate(params[:password])
			session[:user_id] = user.id
			redirect "/account"
		else
			redirect "/failure"
		end
  end

  # Display upon failed login or sign up
  get "/failure" do
    erb :failure
  end

  get "/logout" do
    session.clear
    redirect "/"
  end

  helpers do
    def logged_in?
      !!session[:user_id]
    end

    def current_user
      User.find(session[:user_id])
    end
  end

end
