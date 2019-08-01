require "./config/environment"
require "./app/models/user"
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

  post "/signup" do
    #your code here
    user = User.create(username: params[:username], password: params[:password])
    if user.save && user.username != "" && user.password != ""
    # if user is able to be saved, redirect to '/login'
      redirect to '/login'
    # if user signs up unsuccessfully, redirect to /failure
    else 
      redirect to '/failure'
    end
  end

  get '/account' do
    if logged_in?
      erb :account
    else
      redirect to '/failure'
    end
  end


  get "/login" do
    erb :login
  end

  post "/login" do
    ##your code here
    user = User.find_by(username: params[:username])
    # if params[:username] = :username in the session hash, route to '/account'
      if user && user.authenticate(params[:password])
        session[:user_id] = user.id
        redirect to '/account'
    # else, redirect to '/failure'
      else 
        redirect to '/failure'
    end
  end

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
