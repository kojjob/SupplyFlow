# SupplyFlow Project Documentation

## 1. Project Overview

### Purpose
SupplyFlow is a comprehensive inventory and supply chain management system designed specifically for small to medium-sized businesses (SMEs) in Ghana's retail and distribution sectors. It aims to provide a user-friendly, real-time inventory tracking solution that addresses the unique business practices and challenges of these SMEs.

### Target Audience / Problem Statement
SMEs constitute a significant portion of businesses in Ghana but often struggle with inventory management and supply chain visibility. Existing solutions can be costly, complex, or ill-suited to local business practices. SupplyFlow aims to offer:
- An affordable alternative to enterprise solutions.
- An accessible, user-friendly interface.
- Real-time inventory tracking.
- Offline functionality for areas with unstable internet.
- Integration with local payment platforms.

## 2. Tech Stack

-   **Backend Framework:** Ruby on Rails 8.0.2
-   **Frontend Toolkit:** Hotwire (Turbo + Stimulus)
-   **CSS Framework:** TailwindCSS
-   **JavaScript Management:** Importmap (no bundler)
-   **Database:** PostgreSQL (via `pg` gem)
-   **Web Server:** Puma
-   **API Development:** Jbuilder
-   **Authentication:** Devise
-   **Authorization:** Pundit
-   **Multi-tenancy:** `acts_as_tenant` gem
-   **Pagination:** Kaminari
-   **Background Jobs:** Solid Queue (PostgreSQL-based)
-   **Caching:** Solid Cache
-   **WebSockets:** Solid Cable
-   **Deployment:** Kamal (Docker-based)
-   **Templating:** HTML, ERB

## 3. Core Features (as per `supplyflow-readme.md`)

-   **Real-time Inventory Tracking:** Live stock level updates, view inventory by product/category/location, audit trail.
-   **Low Stock Alerts:** Configurable reorder levels, automated notifications.
-   **Supplier Management & Automated Ordering:** Supplier database, purchase order management, automated draft POs.
-   **Mobile-Responsive Design:** Usable across devices.
-   **Sales Forecasting:** Basic forecasting based on historical data.
-   **Payment Integration:** Planned integration with local platforms (MTN Mobile Money, Hubtel).
-   **Offline Capabilities:** PWA-based caching and transaction queuing.

## 4. Application Structure

### Key Models (`app/models/`)
-   `User`: Manages user accounts, authentication, roles, and permissions. Associated with an `Organization`.
-   `Organization`: Represents a tenant in the multi-tenant system. Users belong to an Organization.
-   `Location`: Physical or logical locations for inventory (e.g., warehouses, stores). Belongs to an `Organization`.
-   `Product`: Catalog of items managed by the system. Belongs to an `Organization`.
-   `InventoryItem`: Represents specific stock of a `Product` at a `Location`, potentially with lot/serial numbers, expiry dates.
-   `InventoryTransaction`: Records all movements of inventory (e.g., received, shipped, adjusted).
-   `Supplier`: Information about suppliers. Belongs to an `Organization`.
-   `Customer`: Information about customers. Belongs to an `Organization`.
-   `Order`: General order model. The system also has specific `PurchaseOrder` and `SalesOrder` models.
-   `OrderItem`: Line items for an `Order`.
-   `PurchaseOrder`: Orders placed with `Suppliers`.
-   `PurchaseOrderItem`: Line items for `PurchaseOrders`.
-   `SalesOrder`: Orders placed by `Customers`.
-   `SalesOrderItem`: Line items for `SalesOrders`.
-   `Payment`: Records payments made or received.
-   `UserActivity`: Tracks user actions within the system.
-   `Current`: Likely used by `acts_as_tenant` or for managing current request context (e.g., current user, IP).
-   `concerns/`: Directory for shared model logic.

### Key Controllers (`app/controllers/`)
-   **Web Application Controllers:**
    -   `ApplicationController`: Base controller for the web application.
    -   `DashboardController`: Handles the main user dashboard.
    -   `CustomersController`, `InventoryController`, `LocationsController`, `OrderItemsController`, `OrdersController`, `OrganizationsController`, `ProductsController`, `SuppliersController`, `UsersController`: Standard CRUD operations and custom actions for their respective resources.
    -   `PostsController`: Currently handles the root route (`/`). Its role in the core application flow needs clarification.
    -   `PagesController`: Serves static pages (about, contact, offline, etc.).
    -   `SettingsController`: Manages various user and organization settings.
    -   `users/`: Contains Devise controllers for authentication (Sessions, Registrations, Passwords).
-   **API Controllers (`app/controllers/api/v1/`):**
    -   `Api::V1::BaseController`: Base controller for the v1 API.
    -   `Api::V1::AuthController`: Handles API authentication (token generation, verification).
    -   Mirrors most web controllers for resources like `Customers`, `Dashboard`, `Inventory`, `Locations`, `Products`, `PurchaseOrders`, `Reports`, `SalesOrders`, `Settings`, `Suppliers`, `Users`.

### Routing Overview (`config/routes.rb`)
-   Devise routes for user authentication.
-   Standard RESTful routes for core resources (Orders, Products, Locations, etc.).
-   Custom routes for specific actions like inventory adjustments, order status changes.
-   Extensive settings section with dedicated routes for profile, account, organization, etc.
-   A versioned API (`/api/v1/`) providing endpoints for most application functionalities.
-   PWA routes (`/manifest`, `/service-worker`).
-   Root route is `posts#index`.

## 5. Key Architectural Decisions

-   **Multi-tenancy:** Implemented using the `acts_as_tenant` gem, scoping data primarily by `Organization`. The `ApplicationController` likely sets the current tenant based on the logged-in user.
-   **Frontend:** Modern Rails frontend stack with Hotwire (Turbo for SPA-like navigation and Stimulus for JavaScript interactions) and TailwindCSS for styling. This minimizes the need for a separate JavaScript frontend framework for many parts of the application.
-   **API:** A versioned JSON API (`v1`) is available, built using Jbuilder. This allows integration with other services or potentially a dedicated mobile/frontend application in the future.
-   **Background Processing:** Uses `SolidQueue`, a PostgreSQL-backed job queue, for handling asynchronous tasks (e.g., notifications, report generation, potentially payment processing).
-   **PWA & Offline Strategy:** The application is designed as a Progressive Web App (PWA) with plans for offline capabilities using Service Workers and client-side storage (IndexedDB/localStorage) for data caching and queuing operations.
-   **Authentication & Authorization:** Devise for robust authentication and Pundit for managing permissions.

## 6. Database

-   **Adapter:** PostgreSQL.
-   **Key Tables (derived from models and `supplyflow-readme.md`):**
    -   `organizations`: Stores tenant data.
    -   `users`: User accounts, roles, linked to `organizations`.
    -   `products`: Product catalog.
    -   `locations`: Inventory storage locations.
    -   `inventory_items` (or similar, e.g., `inventory_levels` mentioned in readme): Tracks stock quantities per product per location.
    -   `inventory_transactions` (or `stock_movements` mentioned in readme): Audit trail of all inventory changes.
    -   `suppliers`: Supplier details.
    -   `customers`: Customer details.
    -   `orders`, `order_items`: General order structure.
    -   `purchase_orders`, `purchase_order_items`: For procurement.
    -   `sales_orders`, `sales_order_items`: For customer sales.
    -   `payments`: Payment records.
    -   `user_activities`: Logs user actions.
    -   `active_storage_attachments`, `active_storage_blobs`, `active_storage_variant_records`: For file uploads (e.g., user avatars).
-   The schema includes appropriate indexing and foreign key constraints.

## 7. Setup and Running (from `supplyflow-readme.md`)

### Prerequisites
-   Ruby 3.2+
-   PostgreSQL 14+
-   Node.js and Yarn (for `tailwindcss-rails` and `importmap-rails` asset tasks)

### Installation
1.  Clone the repository.
2.  Install dependencies: `bundle install` (and `yarn install` if frontend JS packages were managed by Yarn, though importmap might reduce this need).
3.  Set up the database: `rails db:create`, `rails db:migrate`, `rails db:seed`.
4.  Start the development server: `./bin/dev` (likely runs Puma and TailwindCSS watcher).

## 8. Potential TODOs / Areas for Review or Future Work (Inferred)

As no explicit `#TODO` comments were found, these are based on observations:

-   **Clarify `PostsController` Role:** The `PostsController` handles the root path. Its exact function (blog, placeholder, conditional redirect) should be documented or reviewed.
-   **Image Processing for Active Storage:** The `image_processing` gem is commented out in the `Gemfile`. If advanced image transformations (beyond basic variants) are needed for avatars or product images, this should be enabled and configured.
-   **Payment Gateway Integration:** The `supplyflow-readme.md` mentions plans for MTN Mobile Money and Hubtel integration. This is a significant feature to be implemented.
-   **Complete PWA Offline Functionality:** While PWA setup is present, the full scope of offline data caching, transaction queuing, and synchronization logic is a complex feature that may require further development and testing.
-   **Sales Forecasting Implementation:** The readme mentions basic forecasting. The actual implementation status and algorithms used could be further detailed or developed.
-   **Automated Ordering:** The feature for automated draft purchase orders based on low stock is mentioned; its implementation status could be reviewed.
-   **Comprehensive Testing:** Ensure all critical paths, especially around inventory, orders, and multi-tenancy, have robust test coverage (unit, integration, system). The readme outlines a testing strategy.
-   **API Endpoint Review:** Ensure all necessary API endpoints for planned mobile or third-party integrations are present and well-documented (e.g., using Swagger/OpenAPI).
-   **Security Audit:** While Brakeman is in the Gemfile, regular security reviews, especially around API authentication, authorization (Pundit policies), and multi-tenancy, are crucial.
-   **User Documentation/Guides:** Beyond this technical documentation, user-facing guides and tutorials (mentioned in the dashboard welcome banner) will be needed.
-   **Seed Data Refinement:** Review `db/seeds.rb` to ensure it provides adequate and realistic sample data for development and testing across different organizations/tenants.
-   **Accessibility (WCAG AA):** The readme mentions WCAG AA compliance as a goal. A thorough accessibility audit would be beneficial.
-   **Internationalization (i18n):** While not explicitly mentioned as a primary goal for the Ghanaian market initially, if expansion is considered, i18n infrastructure might be a future TODO.
-   **Error Monitoring & Logging:** Ensure robust error monitoring (e.g., Sentry, Honeybadger) and structured logging are in place for production.

This documentation provides a snapshot based on the current codebase structure and available project descriptions. It should be regularly updated as the project evolves.
