require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

set :session_secret, SecureRandom.hex(32)

get "/" do
  erb "having fun and trying to speedup my workflow.", layout: :layout
end
