require File.dirname(__FILE__) + '/../service'
require 'rspec'
# require 'test/unit'
require 'rack/test'

# set :environment, :test
# Test::Unit::TestCase.send :include, Rack::Test::Methods

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end

RSpec.configure do |config|
  config.expect_with(:rspec) do |c|
    c.syntax = :should
  end
end

def app
  Sinatra::Application
end

# Everything up to here sets up the basic framework for running specs against a Sinatra service

describe "service" do
  before(:each) do
    User.delete_all
  end

  # puts "The File.dirname(__FILE__) is: #{File.dirname(__FILE__)}"
  # puts "And the /../service is #{'/../service'}"

  describe "GET on /api/v1/users/:id" do
    before(:each) do
      User.create(
        name: "paul",
        email: "paul@pauldix.net",
        password: "strongpass",
        bio: "rubyist")
      end

      it "should return a user by name" do
        get '/api/v1/users/paul'
        last_response.should be_ok
        #last_response.body is a JSON
        attributes = JSON.parse(last_response.body)
        attributes["name"].should == "paul"
      end

      it "should return a user with an email" do
        get '/api/v1/users/paul'
        last_response.should be_ok
        attributes = JSON.parse(last_response.body)
        attributes["email"].should == "paul@pauldix.net"
      end

      it "should not return a user's password" do
        get '/api/v1/users/paul'
        last_response.should be_ok
        attributes = JSON.parse(last_response.body)
        attributes.should_not have_key("password")
      end

      it "should return a user with a bio" do
        get '/api/v1/users/paul'
        last_response.should be_ok
        attributes = JSON.parse(last_response.body)
        attributes["bio"].should == "rubyist"
      end

      it "should return a 404 for a user that doesn't exist" do
        get '/api/v1/users/foo'
        last_response.status.should == 404
      end
    end # end of GET describe

  describe "POST on /api/v1/users" do # creating a user
    it "should create a user" do
        hash = {
          name: "trotter",
          email: "no spam",
          password: "whatever",
          bio: "southern belle"
        }

        post '/api/v1/users', hash.to_json
        # turn hash to json before transmitting, otherwise the params
        # messes up the query string...
        # will have to JSON.parse it at the service.rb
        last_response.should be_ok

        get '/api/v1/users/trotter'
        attributes = JSON.parse(last_response.body)
        attributes["name"].should == "trotter"
        attributes["email"].should == "no spam"
        attributes["bio"].should == "southern belle"
      end
    end # end of POST describe

  describe "PUT on /api.v1/users/:id"   do
     it "should update a user" do
        User.create(
          name: "bryan",
          email: "no spam",
          password: "whatever",
          bio: "rspec master"
          )

        hash = {bio: "testing freak"}
        put '/api/v1/users/bryan', hash.to_json

        last_response.should be_ok

        get '/api/v1/users/bryan'
        attributes = JSON.parse(last_response.body)
        attributes["bio"].should == "testing freak"
      end
    end # end of PUT describe

  describe "DELETE on /api/v1/users/:id" do
      it "should delete a user" do
        User.create(
          name: "francis",
          email: "no spam",
          password: "whatever",
          bio: "williamsburg hipster"
          )

        # AH: I added the next 4 lines.  Not in the book. unnecessary...
        get '/api/v1/users/francis'
        last_response.should be_ok
        attributes = JSON.parse(last_response.body)
        attributes["name"].should == "francis"
        ############################################

        delete '/api/v1/users/francis'
        # the delete action only cares that the service response is a
        # 200 error
        get '/api/v1/users/francis'
        last_response.status.should == 404
      end
  end # end of DELETE describe

  describe "POST on /api/v1/users/:id/sessions" do #creating a session
      before(:each) do
        User.create(
          name: "josh",
          password: "nyc.rb rules",
          email: "no email",
          bio: "who cares"
          )
      end

        it "should return the user object on valid credentials" do
          hash = {password: "nyc.rb rules"}
          post '/api/v1/users/josh/sessions', hash.to_json

          last_response.should be_ok
          attributes = JSON.parse(last_response.body)
          attributes["name"].should == "josh"
        end

        it "should fail on invalid credentials" do
          hash = {password: "wrong"}
          post '/api/v1/users/josh/sessions', hash.to_json

          last_response.status.should == 400
        end

  end # end of Verification describe

  end

