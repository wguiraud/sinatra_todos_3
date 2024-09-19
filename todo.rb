require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"
require "pry"

configure do 
  enable :sessions
  set :session_secret, 'hello world I need a 64 bytes session password in order to make sinatra happy' #ok for development env but not ok for production
  #set :session_secret, SecureRandom.hex(32)
end

before do 
  session[:lists] ||= []
end

def non_unique_name?(given_list_name)
  used_names = []
  session[:lists].each { |list| used_names << list[:name] }
  used_names.include?(given_list_name)
end

def invalid_list_name?(list_name)
  !list_name.match?(/^(?!.*([\.\?\!@#\$%\^&\*\(\)\-_\+=\[\]\{\}\|;:<>]).*\1)[A-Za-z0-9\s,\.\?\!@#\$%\^&\*\(\)\-_\+=\[\]\{\}\|;:<>]{1,100}$/) 
end

def error_for_list_name(list_name)
  if invalid_list_name?(list_name)
    "Please enter a valid input. The input must be between 1 and 100 characters long and contain only alphanumeric and common punctuation characters."
  elsif non_unique_name?(list_name) 
    "Sorry, this list name is already used!"
  else 
    nil
  end
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
  list_name = params[:list_name].strip
  error = error_for_list_name(list_name)
  if error
    session[:error] = error
    erb :new_list
  else
    session[:lists] << { name: list_name, todos: [] }
    session[:success] = "#{list_name} was successfully created"
    redirect "/lists"
  end
end
