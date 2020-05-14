# Add your unit tests.
# You want to test your interaction with the database here.
require_relative '../app.rb'
require 'minitest/autorun'
require 'rack/test'

class UnitTestClass < Test::Unit::TestCase
  include Rack::Test::Methods

	def app
		Sinatra::Application
	end

  def test_route
    get '/search?query=hi'
    assert_equal 200, last_response.status
    assert last_response.ok?
  end

end




