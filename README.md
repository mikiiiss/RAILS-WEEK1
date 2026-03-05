# Rails Programming Upskilling Challenge

This project contains intentionally buggy Rails code designed to help you learn how to debug, reason about, and fix common issues in Rails applications. The bugs are not trivial and are meant to encourage you to learn Rails syntax, best practices, and how to work with real-world Rails code.

## Learning Objectives
- Navigate and understand a Rails codebase
- Debug complex Rails issues (N+1 queries, mass assignment, caching)
- Implement Rails APIs following conventions
- Apply Rails best practices (strong parameters, eager loading, cache invalidation)
- Leverage AI for deeper understanding, not just answers
- Test Rails applications

## Setup Instructions

### Option 1: Docker Setup (Recommended)
1. **Clone and navigate to the project:**
   ```sh
   cd rails-week1
   ```

2. **Start the application using Docker Compose:**
   ```sh
   docker-compose up
   ```

3. **Access the application:**
   - API: http://localhost:3000/api/v1/products
   - Health check: http://localhost:3000/health
   - Root: http://localhost:3000/

### Option 2: Local Rails Setup
1. **Create a new Rails API app:**
   ```sh
   rails new product_catalog_api --api --database=sqlite3
   ```

2. **Replace the generated files with the ones in this repository:**
   - Copy all files from this repository to your Rails app
   - Ensure all dependencies are installed: `bundle install`

3. **Run migrations and seed:**
   ```sh
   rails db:migrate
   rails db:seed
   ```

4. **Start the Rails server:**
   ```sh
   rails server
   ```

## Challenge Tasks

### Task 1: Understanding the Existing API (4-6 hours)
**Objective:** Get familiar with the Rails application structure and functionality.

**Actions:**
- Start the application and access the API endpoints
- Review the code structure (models, controllers, routes)
- Use Rails console to explore the database
- Verify health check endpoint

### Task 2: Identifying & Fixing Non-Trivial Bugs (12-16 hours)

#### Bug 2.1: The 'Missing Category Name' Mystery (N+1 Query Issue)
**Symptoms:**
- API response shows `category_name: null` for some products
- Server logs show many individual SELECT queries for categories
- Performance degradation with many products

**What to look for:**
- Products with `category_id` but no matching Category record
- Missing eager loading in controller
- Safe navigation operator (`&.`) handling nil cases

#### Bug 2.2: The 'Phantom Feature' (Mass Assignment Vulnerability)
**Symptoms:**
- Can create/update products with unexpected parameters like `is_admin: true`
- No parameter filtering in controller actions
- Security vulnerability exposure

**What to look for:**
- Direct parameter assignment: `Product.new(params[:product])`
- Use of `params.permit!` instead of strong parameters
- Missing `product_params` method

#### Bug 2.3: The 'Stale Price' Problem (Caching Invalidation Issue)
**Symptoms:**
- Updated product prices still show old values
- Cache not invalidated after updates
- Stale data served from cache

**What to look for:**
- Missing cache invalidation in update actions
- `caches_action` without proper expiration
- No `expire_action` calls

### Task 3: Implementing New Features (6-8 hours)

#### Action 3.1: Product Filtering and Pagination
**Requirements:**
- Add `category_id` filtering to products endpoint
- Implement pagination with `page` and `per_page` parameters
- Use Kaminari gem for pagination

#### Action 3.2: Product Featuring
**Requirements:**
- Add `PATCH /api/v1/products/:id/feature` endpoint
- Update `is_featured` attribute
- Ensure proper authorization (conceptual)

### Task 4: Productionizing & Testing (4-8 hours, Optional)

#### Action 4.1: Add Unit/Integration Tests
**Requirements:**
- Test N+1 query fixes
- Test mass assignment vulnerability fixes
- Test new filtering and featuring functionality

#### Action 4.2: Review Production Configuration
**Requirements:**
- Understand development vs production settings
- Review caching, logging, and error handling configurations

## API Endpoints

### Products
- `GET /api/v1/products` - List all products (has N+1 bug)
- `GET /api/v1/products/:id` - Show product (has caching bug)
- `POST /api/v1/products` - Create product (has mass assignment bug)
- `PATCH /api/v1/products/:id` - Update product (has mass assignment bug)
- `DELETE /api/v1/products/:id` - Delete product
- `PATCH /api/v1/products/:id/feature` - Feature product (Task 3.2)

### Categories
- `GET /api/v1/categories` - List all categories
- `GET /api/v1/categories/:id` - Show category with products
- `POST /api/v1/categories` - Create category (has mass assignment bug)
- `PATCH /api/v1/categories/:id` - Update category (has mass assignment bug)
- `DELETE /api/v1/categories/:id` - Delete category (has dependency bug)

## Debugging Tips

### Using Rails Console
```ruby
# Explore products and categories
Product.all
Category.all

# Check for N+1 queries
Product.includes(:category).all

# Test mass assignment
Product.new(name: "Test", is_admin: true)
```

### Using Rails Logs
- Watch for multiple SELECT queries in development logs
- Look for parameter assignments in create/update actions
- Monitor cache hits/misses

### Using Tests
```bash
# Run all tests
rails test

# Run specific test files
rails test test/models/product_test.rb
rails test test/controllers/api/v1/products_controller_test.rb
```

## AI Interaction Guidance

Instead of asking "fix this bug," ask:
- "Explain N+1 query problems in Rails and how to fix them"
- "How does belongs_to and has_many work in ActiveRecord?"
- "What is mass assignment and how are strong parameters used?"
- "How does Rails caching work, particularly caches_action?"

## Files to Focus On

### Core Files (Bugs)
- `app/models/product.rb` - N+1 and nil category issues
- `app/controllers/api/v1/products_controller.rb` - All three bugs
- `app/controllers/api/v1/categories_controller.rb` - Mass assignment bugs

### Configuration Files
- `config/routes.rb` - API routing
- `config/environments/development.rb` - Debug settings
- `config/database.yml` - Database configuration

### Test Files
- `test/models/product_test.rb` - Model testing examples
- `test/controllers/api/v1/products_controller_test.rb` - Controller testing examples

## My Progress

- **Task 1 (Understanding the Existing API)**:
  - Started the application with Docker Compose and verified core endpoints: `/api/v1/products`, `/api/v1/categories`, `/health`, and `/`.
  - Explored the database via `rails console` (`Product.count`, `Category.count`, `Product.first.category`) to understand the data and associations.
  - Reviewed `config/routes.rb`, `app/models/product.rb`, `app/models/category.rb`, and `app/controllers/api/v1/products_controller.rb` to map routes → controllers → models.

- **Task 2 (Identifying & Fixing Bugs)**:
  - **Bug 2.1 (N+1 query)**: Updated `products#index` to use `Product.includes(:category)` to resolve the N+1 performance issue and handle potential nil category names correctly.
  - **Bug 2.2 (Mass assignment)**: Implemented Strong Parameters in `ProductsController` and `CategoriesController` to prevent unauthorized modification of fields like `is_admin`.
  - **Bug 2.3 (Stale caching)**: Implemented manual cache invalidation using `expire_action` in both standard (`update`, `destroy`) and custom (`feature`) controller actions.

- **Task 3 (New Features)**:
  - **Filtering & Pagination**: Added category filtering and pagination (via Kaminari) to the products index endpoint.
  - **Product Featuring**: Created a new `PATCH /feature` endpoint to mark products as featured, complete with cache expiration.

- **Task 4 (Productionizing & Testing)**:
  - **Testing**: Updated model and controller tests to verify all bug fixes and new features.
  - **Production Config**: Reviewed and verified `production.rb` for proper caching and logging settings.

- **Final Deliverables**:
  - Created a [Final Technical Report](./final_technical_report.md) as required in the challenge instructions.

Happy debugging and learning!