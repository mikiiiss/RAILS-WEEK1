class ApplicationController < ActionController::API
  # Common logic for all controllers
  before_action :set_default_response_format

  # Health check endpoint (Task 1.1 requirement)
  def health
    render json: { 
      status: 'healthy', 
      timestamp: Time.current,
      database: database_connected?
    }
  end

  # Root endpoint (Task 1.1 requirement)
  def index
    render json: { 
      message: 'Rails API Challenge - Product Catalog',
      version: '1.0.0',
      endpoints: {
        products: '/api/v1/products',
        categories: '/api/v1/categories',
        health: '/health'
      }
    }
  end

  private

  def set_default_response_format
    request.format = :json
  end

  def database_connected?
    ActiveRecord::Base.connection.active?
  rescue ActiveRecord::NoDatabaseError
    false
  end
end 