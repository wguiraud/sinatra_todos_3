# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/content_for'
require 'tilt/erubis'
require 'pry'

configure do
  enable :sessions
  set :session_secret, 'hello world I need a 64 bytes session password in order to make sinatra happy' # ok for development env but not ok for production
  # set :session_secret, SecureRandom.hex(32)
end

def non_unique_name?(given_list_name)
  used_names = []
  session[:lists].each { |list| used_names << list[:name] }
  used_names.include?(given_list_name)
end

def invalid_name?(list_name)
  !list_name.match?(/^(?!.*([.?!@#$%\^&*()\-_+=\[\]{}|;:<>]).*\1)[A-Za-z0-9\s,.?!@#$%\^&*()\-_+=\[\]{}|;:<>]{1,100}$/)
end

def error_for_list_name(list_name)
  if invalid_name?(list_name)
    'Please enter a valid list name.'
  elsif non_unique_name?(list_name)
    'Sorry, this list name is already being used.'
  end
end

def error_for_todo_name(todo_name)
  if invalid_name?(todo_name)
    'Please enter a valid todo name.'
  end
end

before do
  session[:lists] ||= []
end

get '/' do
  redirect '/lists'
end

get '/lists' do
  @lists = session[:lists]
  erb :lists
end

get '/lists/new' do
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
    redirect '/lists'
  end
end

get "/lists/:list_id" do
  ### Using instance variables to pass data to the templates
  # @list_id = params[:list_id].to_i
  # @list = session[:lists][@list_id]
  # @list_name = @list[:name]
  ### Using a hash of local variables in conjunction with the locals option to pass data down to the templates
  list_id = params[:list_id].to_i
  list = session[:lists][list_id]
  list_name = list[:name]
  erb :list, locals: { list_id: list_id, list: list, list_name: list_name }
  #erb :list
end

get "/lists/:list_id/edit" do 
  @list_id = params[:list_id].to_i
  @list = session[:lists][@list_id]
  erb :edit_list
end

post "/lists/:list_id" do 
  list_name = params[:list_name].strip
  list_id = params[:list_id].to_i
  @list = session[:lists][list_id]
  error = error_for_list_name(list_name)
  if error 
    session[:error] = error
    erb :edit_list
  else
    @list[:name] = list_name 
    session[:success] = "The list was successfully updated!"
    redirect "/lists/#{list_id}"
  end
end

post "/lists/:list_id/delete" do 
  list_id = params[:list_id].to_i
  list_name = session[:lists][list_id][:name]
  session[:lists].delete_at(list_id)
  session[:success] = "#{list_name} was successfully deleted"
  redirect "/lists"
end

post "/lists/:list_id/todos" do
  #Using instance variables to pass data to the templates
#  @list_id = params[:list_id].to_i
#  todo_name = params[:todo_name].strip
#  @list = session[:lists][@list_id]
#  @list_name = @list[:name]
  # Using a hash of local variables in conjunction with the locals option to
  # pass data down to the templates
  list_id = params[:list_id].to_i
  list = session[:lists][list_id]
  list_name = list[:name]

  todo_name = params[:todo_name].strip



    error = error_for_todo_name(todo_name)
  if error
    session[:error] = error
    erb :list, locals: { list_id: list_id, list: list, list_name: list_name }
    #erb :list
  else
    #@list[:todos] << { name: todo_name, completed: false }
    list[:todos] << { name: todo_name, completed: false }
    session[:success] = "The todo was successfully created!"
    redirect "/lists/#{list_id}"
  end
end


