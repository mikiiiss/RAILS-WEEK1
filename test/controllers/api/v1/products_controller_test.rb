# Test file for ProductsController
# This file contains tests that will help trainees understand Rails controller testing
# and identify the bugs in the application

require 'test_helper'

class Api::V1::ProductsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @category = create_test_category("Electronics")
    @product = create_test_product(@category, {
      name: "Test Laptop",
      price: 999.99,
      stock_quantity: 10
    })
  end

  test "should get index" do
    api_get "/api/v1/products"
    assert_json_response
    assert_not_nil json_response
  end

  test "should get show" do
    api_get "/api/v1/products/#{@product.id}"
    assert_json_response
    assert_equal @product.name, json_response["name"]
  end

  test "should create product" do
    assert_difference('Product.count') do
      api_post "/api/v1/products", {
        product: {
          name: "New Product",
          description: "New Description",
          price: 50.00,
          stock_quantity: 5,
          category_id: @category.id
        }
      }
    end
    assert_json_response(:created)
  end

  test "should not create product with invalid data" do
    assert_no_difference('Product.count') do
      api_post "/api/v1/products", {
        product: {
          name: nil,
          price: -1
        }
      }
    end
    assert_json_response(:unprocessable_entity)
  end

  test "should update product" do
    api_patch "/api/v1/products/#{@product.id}", {
      product: {
        name: "Updated Product",
        price: 1500.00
      }
    }
    assert_json_response
    @product.reload
    assert_equal "Updated Product", @product.name
    assert_equal 1500.00, @product.price
  end

  test "should delete product" do
    assert_difference('Product.count', -1) do
      api_delete "/api/v1/products/#{@product.id}"
    end
    assert_response :no_content
  end

  test "should feature product" do
    api_patch "/api/v1/products/#{@product.id}/feature"
    assert_json_response
    @product.reload
    assert @product.is_featured?
  end

  # Tests for security and bug fixes

  test "should not allow mass assignment of is_admin through create" do
    api_post "/api/v1/products", {
      product: {
        name: "Admin Product",
        description: "Admin Description",
        price: 100.00,
        stock_quantity: 1,
        category_id: @category.id,
        is_admin: true  # This should be ignored
      }
    }
    assert_json_response(:created)
    product = Product.last
    assert_not product.is_admin?, "is_admin should not be set via create params"
  end

  test "should not allow mass assignment of is_admin through update" do
    api_patch "/api/v1/products/#{@product.id}", {
      product: {
        name: "Updated Admin Product",
        is_admin: true  # This should be ignored
      }
    }
    assert_json_response
    @product.reload
    assert_not @product.is_admin?, "is_admin should not be set via update params"
  end

  test "should handle products with nil categories" do
    # This test demonstrates the N+1 query and nil category bugs
    product_without_category = create_test_product(nil, {
      name: "Product Without Category",
      category_id: nil
    })
    
    api_get "/api/v1/products"
    assert_json_response
    
    product_response = json_response.find { |p| p["id"] == product_without_category.id }
    assert_nil product_response["category_name"]
  end

  test "should handle products with non-existent category_id" do
    # With proper foreign key constraints, attempting to persist a product
    # with a non-existent category_id should raise an error.
    assert_raises ActiveRecord::InvalidForeignKey do
      create_test_product(nil, {
        name: "Product With Bad Category",
        category_id: 99999  # Non-existent category
      })
    end
  end

  test "should filter products by category_id" do
    other_category = create_test_category("Books")
    create_test_product(other_category, {
      name: "Book Product",
      price: 20.0,
      stock_quantity: 3
    })

    api_get "/api/v1/products?category_id=#{@category.id}"
    assert_json_response

    # All returned products should have the requested category_id
    assert json_response.all? { |p| p["category_id"] == @category.id }
  end

  test "should paginate products with page and per_page" do
    5.times do |i|
      create_test_product(@category, {
        name: "Extra Product #{i}",
        price: 10.0 + i,
        stock_quantity: 1
      })
    end

    api_get "/api/v1/products?page=2&per_page=2"
    assert_json_response

    # We requested 2 per page, so we should get at most 2 items back
    assert json_response.size <= 2
  end
end 