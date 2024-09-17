require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

set :session_secret, SecureRandom.hex(32)

get "/" do
  redirect "/lists"
end

get "/lists" do 
  @lists = [ 
    { name: :list1, todos: [ {}, {}, {}] }, 
    { name: :list2, todos: [ {} ] }
  ]
  erb :lists
end


