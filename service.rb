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
######################

get '/api/v1/users/:name' do
  user = User.find_by_name(params[:name])
  if user
    user.to_json
    #Sinatra puts this value in the response body with a 200 status code
  else
    error 404, {error: 'user not found'}.to_json
  end
end # end of 'get' implementation

# create a new user:
######################

post '/api/v1/users' do
  begin
    hash = (JSON.parse(request.body.read))
    # Sinatra exposes a request object StringIO that needs be read in
    # puts "hash = #{hash}"
    user = User.create(hash)

    if user.valid?
      user.to_json
    else
      error 400, user.errors.to_json
    end # end of if
  rescue => e
    puts "had to get rescued"
    error 400, {:error => e.message}.to_json
  end # end of rescue
end # end of post implementation

# PUT or update an existing user:
######################

put '/api/v1/users/:name' do
  user = User.find_by_name(params[:name])
  hash = JSON.parse(request.body.read)

  if user

    begin

      if user.update_attributes(hash)
        user.to_json
      else
        error 400, user.errors.to_json
      end #end if

    rescue => e
      error 400, {error: e.message}.to_json
    end # end rescue

  else
    error 404, {error: "user not found"}.to_json
  end # end if

end # end of put implementation


# DELETE (DESTROY)an existing user:
######################

delete '/api/v1/users/:name' do
  user = User.find_by_name(params[:name])

  if user
    user.destroy
    user.to_json
  else
    error 404, {error: "user not found"}.to_json
  end # end if
end # end of delete implementation

# VERIFY user name and password:
######################

post '/api/v1/users/:name/sessions' do

  begin
    attributes = JSON.parse(request.body.read)
    puts "\n\nattributes hash is:  #{attributes}\n"
    puts "params[:name] is : #{params[:name]}\n"
    puts "attributes['password'] is : #{attributes["password"]}\n"

    user = User.find_by_name_and_password(
      params[:name], attributes['password']
      )

    if user
      puts "$$$$$ FOUND THE USER BY NAME AND PASSWORD \n\n\n"
      user.to_json
    else
      puts "\n\n COULD NOT FIND THE USER"
      error 400, {error: "invalid login credentials"}.to_json
    end # end if
  rescue => e
    puts "\n\n 000000000 HAD TO RESCUE YOU..."
    error 400, {error: e.message}.to_json
  end # end of rescue block
end # end of VERIFY implementation






