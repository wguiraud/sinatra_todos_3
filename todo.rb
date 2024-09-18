require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

configure do 
  enable :sessions
  set :session_secret, 'hello world I need a 64 bytes session password in order to make sinatra happy' #ok for development env but not ok for production
  #set :session_secret, SecureRandom.hex(32)
end

before do 
  session[:lists] ||= []
end

get "/" do
  redirect "/lists"
end

get "/lists" do 
  @lists = session[:lists] 
  erb :lists
end

get "/lists/new" do 
  erb :new_list
end

post "/lists" do
  list_name = params[:list_name]
  session[:lists] << { name: list_name, todos: [] }
  session[:success] = "#{list_name} was successfully created"
  redirect "/lists"
end
