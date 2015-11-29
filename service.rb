require 'rubygems'
require 'active_record'
require 'sinatra'
require './models/user'

# setting up the environment
env_index = ARGV.index("-e")  # get the index of the -e entry from command line (ARGV is an array...)
env_arg = ARGV[env_index + 1] if env_index # assign the value after '-e' provided in the command line
env = env_arg || ENV["SINATRA_ENV"] || "development"

databases = YAML.load_file("config/database.yml")
ActiveRecord::Base.establish_connection(databases[env])

# ('The interface of a service is created through its HTTP entry points')
# ('These represent the implementation of the testable public interface')

#####################
# HTTP entry points #
#####################

# get a user by name:

get '/api/v1/users/:name' do
  user = User.find_by_name(params[:name])
  if user
    user.to_json
    #Sinatra puts this value in the response body with a 200 status code
  else
    error 404, {error: 'user not found'}.to_json
  end
end
