# Comprehensive Technical Report: Product Catalog API

## 1. Architecture Overview
The Product Catalog API is built using the **Ruby on Rails** framework following the **MVC (Model-View-Controller)** pattern.
- **Models**: `Product` and `Category` handle data logic and associations. A Product `belongs_to` a Category.
- **Controllers**: Namespaced under `Api::V1`, the `ProductsController` and `CategoriesController` handle RESTful requests and return JSON responses.
- **Routing**: Defined in `config/routes.rb` with versioning and custom member routes for specific actions like featuring a product.

## 2. Bug Fixes

### Bug 2.1: N+1 Query (The 'Missing Category Name' Mystery)
- **Problem**: The `index` action fetched products, but for each product, it made a separate query to fetch the category name, leading to $N+1$ database queries.
- **Root Cause**: Lazy loading of associations during JSON rendering.
- **Solution**: Implemented **Eager Loading** using `.includes(:category)` in the `index` action.
- **Best Practice**: Always use `includes`, `preload`, or `eager_load` for associated data that will be accessed in a collection.

### Bug 2.2: Mass Assignment Vulnerability
- **Problem**: Parameters were directly assigned to models, allowing unauthorized fields (like `is_admin`) to be modified via the API.
- **Root Cause**: Use of `params[:product]` or `params.permit!` without filtering.
- **Solution**: Implemented **Strong Parameters** using private `product_params` and `category_params` methods to whitelist only allowed attributes.
- **Best Practice**: Use `require` and `permit` to strictly control which attributes can be mass-assigned.

### Bug 2.3: 'Stale Price' Problem (Caching Invalidation)
- **Problem**: Product details were cached using `caches_action`, but updates to products didn't clear the cache, serving old data.
- **Root Cause**: Missing explicit cache expiration after write operations.
- **Solution**: Added `expire_action` calls in the `update`, `destroy`, and `feature` actions of the `ProductsController`.
- **Best Practice**: Ensure every write operation that affects cached data also triggers a cache invalidation.

## 3. New Feature Implementation

### 3.1 Product Filtering and Pagination
- **Filtering**: Added support for an optional `category_id` parameter in `api/v1/products` to filter results.
- **Pagination**: Integrated the `kaminari` gem to provide `page` and `per_page` controls, preventing large data dumps and improving performance.

### 3.2 Product Featuring
- **Endpoint**: Added `PATCH /api/v1/products/:id/feature`.
- **Logic**: A dedicated action that updates the `is_featured` boolean to `true`. This also correctly invalidates the product's cache.

## 4. Testing & Production Considerations
- **Testing**: Comprehensive tests were added/updated in `test/models/product_test.rb` and `test/controllers/api/v1/products_controller_test.rb`. These tests specifically verify the N+1 fix, mass assignment protection, and the new features.
- **Production**: The `production.rb` configuration has been reviewed to ensure caching is enabled (`config.action_controller.perform_caching = true`) and logging is optimized for a live environment.

## 5. Conclusion & Learnings
This challenge successfully demonstrated the importance of Rails conventions and security best practices. By identifying and fixing N+1 queries and mass assignment vulnerabilities, the API is now more performant and secure. The addition of pagination and filtering makes it production-ready for real-world e-commerce usage.
