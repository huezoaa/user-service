require File.dirname(__FILE__) + '/../service'
require 'rspec'
# require 'test/unit'
require 'rack/test'

# set :environment, :test
# Test::Unit::TestCase.send :include, Rack::Test::Methods

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end

def app
  Sinatra::Application
end

# Everything up to here sets up the basic framework for running specs against a Sinatra service

describe "service" do
  before(:each) do
    User.delete_all
  end

  puts "The File.dirname(__FILE__) is: #{File.dirname(__FILE__)}"
  puts "And the /../service is #{'/../service'}"

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

  describe "POST on /api/v1/users" do
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


  end

