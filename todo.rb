# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/content_for'
require 'tilt/erubis'
require 'pry'

configure do
  enable :sessions
  set :session_secret, 'hello world I need a 64 bytes session password in order to make sinatra happy' # ok for development env but not ok for production
  # set :session_secret, SecureRandom.hex(32)
  set :erb, :escape_html => true
end

helpers do 
  def list_complete?(list)
    total_todos_count(list) > 0 && uncompleted_todos_count(list) == 0
  end

  def list_class(list)
    "complete" if list_complete?(list)
  end

  def uncompleted_todos_count(list)
    list[:todos].reject { |todo| todo[:completed] }.size
  end

  def total_todos_count(list)
    list[:todos].size
  end

  def uncompleted_completed_lists(lists, &block)
    completed, uncompleted = lists.partition { |list| list_complete?(list) }

    uncompleted.each { |list| yield list, lists.index(list) }
    completed.each { |list| yield list, lists.index(list) }
  end

  def uncompleted_completed_todos(todos_list, &block)
    completed, uncompleted = todos_list.partition { |todo| todo[:completed] }

    uncompleted.each { |todo| yield todo, todos_list.index(todo) }
    completed.each { |todo| yield todo, todos_list.index(todo) }
  end
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

def loading_list(index)
  if (0...session[:lists].size).include?(index)
    list = session[:lists][index]
    list if list
  else
    session[:error] = "The specified list wasn't found."
    redirect '/lists'
  end
end

before do
  session[:lists] ||= []
end

get '/' do
  redirect '/lists'
end

# renders all the lists
get '/lists' do
  @lists = session[:lists]
  erb :lists
end

# renders the new list page
get '/lists/new' do
  erb :new_list
end

# creates a new list
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

# renders a list
get "/lists/:list_id" do
  list_id = params[:list_id].to_i
  list = loading_list(list_id)
  list_name = list[:name]

  erb :list, locals: { list_id: list_id, list: list, list_name: list_name }
end

# edits a list name
get "/lists/:list_id/edit" do 
  list_id = params[:list_id].to_i
  @list = loading_list(list_id)

  erb :edit_list
end

# updates an existing list name
post "/lists/:list_id" do
  list_id = params[:list_id].to_i
  list_name = params[:list_name].strip
  @list = loading_list(list_id)

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

# deletes a list
post "/lists/:list_id/delete" do 
  list_id = params[:list_id].to_i
  list_name = session[:lists][list_id][:name]

  session[:lists].delete_at(list_id)
  session[:success] = "#{list_name} list was successfully deleted"

  redirect "/lists"
end

# creates a new todo
post "/lists/:list_id/todos" do
  list_id = params[:list_id].to_i
  list = loading_list(list_id)
  list_name = list[:name]

  todo_name = params[:todo_name].strip

  error = error_for_todo_name(todo_name)
  if error
    session[:error] = error
    erb :list, locals: { list_id: list_id, list: list, list_name: list_name }
  else
    list[:todos] << { name: todo_name, completed: false }
    session[:success] = "The todo was successfully created!"
    redirect "/lists/#{list_id}"
  end

end

# deletes a todo from a list
post "/lists/:list_id/todos/:todo_id/delete" do
  list_id = params[:list_id].to_i
  list = loading_list(list_id)
  todo_id = params[:todo_id].to_i
  todo_name = list[:todos][todo_id][:name]

  list[:todos].delete_at(todo_id)
  session[:success] = "#{todo_name} todo has been deleted successfully!"
  redirect "/lists/#{list_id}"
end

# marking a todo as completed
post "/lists/:list_id/todos/:todo_id" do
  list_id = params[:list_id].to_i
  list = loading_list(list_id)
  todo_id = params[:todo_id].to_i
  todo_name = list[:todos][todo_id][:name]

  is_completed = params[:completed] == 'true'
  list[:todos][todo_id][:completed] = is_completed
  session[:success] = "#{todo_name} has been updated"

  redirect "/lists/#{list_id}"
end

# marking all todos as completed
post "/lists/:list_id/complete_all" do
  list_id = params[:list_id].to_i
  list = loading_list(list_id)
  list[:todos].each { |todo| todo[:completed] = true }

  if list[:todos].size == 0
    session[:error] = "You don't have any todo for this list yet!"
  elsif list[:todos].size > 0
    session[:success] = "All the todos are completed"
  end

  redirect "/lists/#{list_id}"
end
