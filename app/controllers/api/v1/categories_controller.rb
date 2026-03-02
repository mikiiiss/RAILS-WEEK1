# Categories controller with intentional bugs for learning
# This controller has some issues that trainees should identify and fix
module Api
  module V1
    class CategoriesController < ApplicationController
      # GET /api/v1/categories
      def index
        # Add basic error handling and pagination
        @categories = Category.all

        # Optional pagination for categories (similar to products)
        @categories = @categories.page(params[:page]).per(params[:per_page] || 20) if @categories.respond_to?(:page)

        render json: @categories.map { |category|
          {
            id: category.id,
            name: category.name,
            products_count: category.products.count,
            created_at: category.created_at,
            updated_at: category.updated_at
          }
        }
      end

      # GET /api/v1/categories/:id
      def show
        @category = Category.find_by(id: params[:id])
        return render json: { error: "Category not found" }, status: :not_found unless @category
        
        render json: {
          id: @category.id,
          name: @category.name,
          products: @category.products.map { |product|
            {
              id: product.id,
              name: product.name,
              price: product.price,
              stock_quantity: product.stock_quantity
            }
          }
        }
      end

      # POST /api/v1/categories
      def create
        # BUG: Mass assignment vulnerability - no strong parameters
        @category = Category.new(category_params)
        
        if @category.save
          render json: @category, status: :created
        else
          render json: @category.errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/categories/:id
      def update
        @category = Category.find(params[:id])
        
        # BUG: Mass assignment vulnerability - using permit!
        if @category.update(category_params)
          render json: @category
        else
          render json: @category.errors, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/categories/:id
      def destroy
        @category = Category.find(params[:id])

        # Handle dependent records explicitly: prevent deletion if products exist
        if @category.products.exists?
          return render json: {
            error: "Cannot delete category with associated products"
          }, status: :unprocessable_entity
        end

        @category.destroy
        head :no_content
      end

      # Private method for strong parameters (fix for mass assignment)
      private
      def category_params
        params.require(:category).permit(:name)
      end
    end
  end
end 