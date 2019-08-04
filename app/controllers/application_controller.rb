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
    user = User.new(params) if params[:username] && params[:password]

    redirect to !user.username.empty? && user.save ? "/login" : "/failure"
  end

  get '/account' do
    @user = User.find(session[:user_id])
    erb :account
  end


  get "/login" do
    erb :login
  end

  post "/login" do
    # binding.pry
    if !params[:username].empty? && !params[:password].empty?
      user = User.find_by(username: params[:username])
      session[:user_id] = user.id
    end
    if user && user.authenticate(params[:password])
      redirect to '/account'
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
