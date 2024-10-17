# config/puma.rb

# Set the number of worker processes
workers Integer(ENV['WEB_CONCURRENCY'] || 2)

# Set the number of threads
threads_count = Integer(ENV['MAX_THREADS'] || 5)
threads threads_count, threads_count

# Preload the application before forking worker processes
preload_app!

# Specify the rackup file
rackup DefaultRackup if defined?(DefaultRackup)

# Set the port
port ENV['PORT'] || 3000

# Set the environment
environment ENV['RACK_ENV'] || 'development'

# Optional: Worker-specific setup (if needed)
on_worker_boot do
  # Add any worker-specific setup here if needed
  # For example, you might want to establish a database connection
  # ActiveRecord::Base.establish_connection if you're using ActiveRecord
end