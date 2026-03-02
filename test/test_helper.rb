# Test helper file for Rails API Challenge
# This file sets up the testing environment and provides common test utilities

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  
  # Helper method to create test data
  def create_test_category(name = "Test Category")
    # Use find_or_create_by! to avoid uniqueness violations on name
    Category.find_or_create_by!(name: name)
  end

  def create_test_product(category = nil, attributes = {})
    category ||= create_test_category
    Product.create!({
      name: "Test Product",
      description: "Test Description",
      price: 10.00,
      stock_quantity: 5,
      category: category,
      published_at: Time.current
    }.merge(attributes))
  end

  # Helper method to make API requests
  def api_get(path, headers = {})
    get path, headers: headers.merge({ 'Accept' => 'application/json' })
  end

  def api_post(path, data = {}, headers = {})
    post path,
         params: data.to_json,
         headers: headers.merge({ 'Accept' => 'application/json', 'Content-Type' => 'application/json' })
  end

  def api_put(path, data = {}, headers = {})
    put path,
        params: data.to_json,
        headers: headers.merge({ 'Accept' => 'application/json', 'Content-Type' => 'application/json' })
  end

  def api_patch(path, data = {}, headers = {})
    patch path,
          params: data.to_json,
          headers: headers.merge({ 'Accept' => 'application/json', 'Content-Type' => 'application/json' })
  end

  def api_delete(path, headers = {})
    delete path, headers: headers.merge({ 'Accept' => 'application/json' })
  end

  # Helper method to assert JSON response
  def assert_json_response(expected_status = :ok)
    assert_response expected_status
    # Allow charset suffix (e.g., "application/json; charset=utf-8")
    assert_match %r{\Aapplication/json}, response.content_type
  end

  # Helper method to parse JSON response
  def json_response
    JSON.parse(response.body)
  end
end 