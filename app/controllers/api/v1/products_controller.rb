# This controller is designed to have multiple bugs:
# 1. N+1 Query (part of Bug 2.1): The `index` action fetches products without eager loading categories.
# 2. Mass Assignment Vulnerability (Bug 2.2): The `create` and `update` actions use `params.permit!`
#    or directly assign `params[:product]`, making them vulnerable.
# 3. Stale Price/Data Caching (Bug 2.3): The `show` action uses simple action caching without proper invalidation.
module Api
  module V1
    class ProductsController < ApplicationController
      # BUG 2.3 (Part 1): Basic action caching without proper invalidation.
      # This cache will not be automatically busted when a product is updated.
      # Requires `gem 'actionpack-action_caching'` to be installed and configured.
      caches_action :show, expires_in: 5.minutes

      # GET /api/v1/products
      def index
        # Base scope with eager loaded categories (fixes N+1 from Bug 2.1)
        @products = Product.includes(:category)

        # Task 3.1: optional filtering by category_id
        if params[:category_id].present?
          @products = @products.where(category_id: params[:category_id])
        end

        # Task 3.1: pagination via Kaminari (page & per_page)
        @products = @products.page(params[:page]).per(params[:per_page] || 20)

        # Simplified JSON rendering for illustration.
        # In a real app, you'd typically use serializers (e.g., Active Model Serializers, jbuilder).
        render json: @products.map { |product|
          {
            id: product.id,
            name: product.name,
            description: product.description,
            price: product.price,
            stock_quantity: product.stock_quantity,
            category_id: product.category_id,
            category_name: product.category_name, # This call triggers the N+1 query
            published_at: product.published_at,
            is_featured: product.is_featured,
            is_admin: product.is_admin # Exposing this for the mass assignment demo
          }
        }
      end

      # GET /api/v1/products/:id
      def show
        @product = Product.find(params[:id])
        render json: {
          id: @product.id,
          name: @product.name,
          description: @product.description,
          price: @product.price,
          stock_quantity: @product.stock_quantity,
          category_id: @product.category_id,
          category_name: @product.category_name,
          published_at: @product.published_at,
          is_featured: @product.is_featured,
          is_admin: @product.is_admin
        }
      end

      # POST /api/v1/products
      def create
        # BUG 2.2: Mass assignment vulnerability.
        # This allows any attribute in the `product` hash to be set,
        # including potentially malicious or unintended ones (e.g., `is_admin`).
        @product = Product.new(product_params)

        if @product.save
          render json: @product, status: :created
        else
          render json: @product.errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/products/:id
      def update
        @product = Product.find(params[:id])
        # BUG 2.2: Mass assignment vulnerability.
        # This allows any attribute in the `product` hash to be set,
        # including potentially malicious or unintended ones.
        if @product.update(product_params)
          # Bug 2.3 fix: expire cached show response so updated data is returned
          expire_action action: :show, id: @product.id
          render json: @product
        else
          render json: @product.errors, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/products/:id
      def destroy
        @product = Product.find(params[:id])
        product_id = @product.id
        @product.destroy
        # Bug 2.3 fix: ensure any cached show response is removed after delete
        expire_action action: :show, id: product_id
        head :no_content
      end

      # Custom action for featuring a product (for Task 3.2)
      def feature
        @product = Product.find(params[:id])
        # Task 3.2: mark product as featured.
        # In a real app you would also enforce authorization so only admins can do this.
        if @product.update(is_featured: true)
          # Bug 2.3 fix: featuring should also invalidate cached show output
          expire_action action: :show, id: @product.id
          render json: @product
        else
          render json: @product.errors, status: :unprocessable_entity
        end
      end

      # Private method for strong parameters (fix for Bug 2.2)
      private
      def product_params
        params.require(:product).permit(
          :name,
          :description,
          :price,
          :stock_quantity,
          :category_id,
          :published_at,
          :is_featured
        )
      end
    end
  end
end 