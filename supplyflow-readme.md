# SupplyFlow: Inventory Management System for Ghanaian SMEs

SupplyFlow is a comprehensive inventory and supply chain management system designed specifically for small to medium-sized businesses in Ghana's retail and distribution sectors. The application provides a user-friendly, real-time inventory tracking solution that addresses the unique business practices and challenges of SMEs in Ghana.

## Problem Statement

SMEs constitute approximately 85% of businesses in Ghana but often face challenges in managing their inventory and gaining visibility into their supply chain. Current solutions often come at a high cost, are overly complex, or fail to cater to the unique business practices of SMEs. SupplyFlow addresses these issues by offering:

- An affordable alternative to expensive enterprise solutions
- A user-friendly interface accessible to users with varying digital literacy
- Real-time inventory tracking capabilities
- Offline functionality for areas with unstable internet connectivity
- Integration with local payment platforms

## Tech Stack

- **Backend Framework:** Ruby on Rails 8
- **Frontend Toolkit:** Hotwire (Turbo + Stimulus)
- **CSS Framework:** TailwindCSS
- **Database:** PostgreSQL
- **Templating:** HTML, ERB
- **Background Jobs:** Solid Job (PostgreSQL-based)
- **Authentication:** Devise
- **Authorization:** Pundit or CanCanCan

## Core Features

### 1. Real-time Inventory Tracking

- Live updates of stock levels triggered by sales, purchases, and adjustments
- View inventory by product, category, and location
- Stock movement audit trail

**Technical Implementation:**
- Use Hotwire's Turbo Streams for real-time updates
- All inventory changes flow through a `StockMovement` model
- Broadcast updates via Turbo Streams using `broadcast_update_later_to` or similar
- Implement proper multi-tenancy with organization scoping

```ruby
# Example implementation in StockMovement model
after_commit on: :create do
  # Update inventory levels
  InventoryService.update_levels(self)
  
  # Broadcast updates to UI
  broadcast_update_later_to(
    "organization_#{organization_id}_inventory",
    target: "product_#{product_id}_stock",
    partial: "inventory/stock_level",
    locals: { product: product.reload }
  )
end
```

### 2. Low Stock Alerts

- Configurable reorder levels per product
- Automated notifications (in-app, email) when stock falls below thresholds
- Visual indicators for low stock items

**Technical Implementation:**
- Background job to identify items below reorder level
- Notifications via Action Mailer and in-app notifications
- Use Turbo Streams to push alerts to connected clients

### 3. Supplier Management & Automated Ordering

- Database of suppliers with contact information and purchase history
- Purchase order creation, tracking, and management
- Automated draft purchase orders based on low stock levels

**Technical Implementation:**
- Standard Rails CRUD for suppliers
- Nested forms for purchase orders
- Background job for generating draft purchase orders

### 4. Mobile-Responsive Design

- Fully usable experience across desktops, tablets, and smartphones
- Touch-optimized interface with appropriate sizing

**Technical Implementation:**
- Mobile-first design with TailwindCSS
- Use responsive utility classes (sm:, md:, lg:, xl:)
- Implement mobile-specific navigation patterns

### 5. Sales Forecasting

- Basic forecasting based on historical sales data
- Visual charts and reports for trend analysis

**Technical Implementation:**
- Use historical sales data for calculations
- Implement simple algorithms (moving averages, linear regression)
- Run calculations in background jobs
- Use Chartkick for visualizations

### 6. Payment Integration

- Integration with local payment platforms (MTN Mobile Money, Hubtel)
- Track payments against sales/invoices

**Technical Implementation:**
- Use provider gems or direct API integration
- Implement secure webhook handling
- Process payments in background jobs

### 7. Offline Capabilities

- View cached inventory data when offline
- Queue basic transactions for syncing upon reconnection
- Visual indicators for online/offline status

**Technical Implementation:**
- Progressive Web App (PWA) with Service Workers
- IndexedDB or localStorage for data caching
- Queue operations when offline
- Sync when connection is restored

## Database Design

Key tables in the system include:

- `organizations`: Tenant information
- `users`: User accounts with roles and permissions
- `products`: Product catalog with SKUs and details
- `categories`: Product categorization
- `locations`: Warehouses, store rooms, shelves
- `inventory_levels`: Stock quantities by product and location
- `stock_movements`: Audit trail for all inventory changes
- `suppliers`: Supplier information
- `purchase_orders`: Orders placed with suppliers
- `purchase_order_items`: Line items for purchase orders
- `sales_orders`: Customer sales records
- `sales_order_items`: Line items for sales
- `payments`: Payment records

Proper indexing, constraints, and appropriate data types are essential.

## Multi-tenancy Approach

We'll implement scoped queries with an `organization_id` on relevant tables, using the `ActsAsTenant` gem to enforce data isolation at the application level.

```ruby
# Example implementation in ApplicationController
around_action :set_tenant

def set_tenant
  tenant = Organization.find_by(id: current_user&.organization_id)
  ActsAsTenant.with_tenant(tenant) do
    yield
  end
end
```

## Offline Strategy

Implement a Progressive Web App (PWA) approach:

1. Service worker for caching application shell and critical data
2. IndexedDB for storing essential inventory data
3. Operation queuing mechanism for offline actions
4. Synchronization logic for resolving conflicts when reconnecting

## Development Phases

### Phase 1: Project Setup and Foundation (Weeks 1-2)
- Set up development environments and collaboration tools
- Establish Git workflow and branching strategy
- Configure Rails 8 with Hotwire, TailwindCSS, and PostgreSQL
- Implement basic multi-tenancy infrastructure
- Create CI/CD pipeline for automated testing and deployment

### Phase 2: Core Functionality MVP (Weeks 3-6)
- Implement authentication and authorization systems
- Build database schema for organizations, products, and inventory tracking
- Develop basic inventory management capabilities
- Create real-time inventory update mechanisms with Hotwire
- Implement basic responsive UI with TailwindCSS

### Phase 3: Enhanced Features (Weeks 7-10)
- Implement supplier management and purchase orders
- Develop low stock alerts and notification system
- Build sales tracking functionality
- Create basic reporting and analytics dashboards
- Implement basic offline capabilities

### Phase 4: Integration and Advanced Features (Weeks 11-14)
- Integrate payment gateways (MTN Mobile Money, Hubtel)
- Enhance offline capabilities
- Implement sales forecasting
- Add advanced reporting features
- Develop automated ordering system

### Phase 5: Testing, Refinement, and Launch (Weeks 15-16)
- Comprehensive testing across devices and connections
- Performance optimization
- Documentation completion
- User acceptance testing with selected SMEs
- Production deployment and launch

## Design System

SupplyFlow uses a comprehensive design system that prioritizes:

1. **Simplicity First**: Clear, uncluttered interfaces
2. **Visual Communication**: Icons, colors, and visual cues
3. **Progressive Disclosure**: Revealing complexity only when needed
4. **Consistent Patterns**: Reusing interface patterns
5. **Cultural Relevance**: Elements that resonate with Ghanaian context
6. **Offline-Friendly**: Clear indicators for offline state

Key components include:

- Color system with primary blue (#0055A4) and secondary green (#00A86B)
- Typography based on Inter font family
- Consistent spacing using an 8-point grid system
- Responsive layouts with appropriate breakpoints
- Mobile-specific adaptations
- Accessibility considerations (WCAG AA compliance)

## Development Practices

To ensure high-quality code and smooth team collaboration:

1. **TDD Approach**: Write tests before implementation for critical components
2. **Code Reviews**: Required for all PRs with at least one approval
3. **Pair Programming**: Scheduled for complex components
4. **Regular Refactoring**: Weekly dedicated time for code clean-up
5. **Documentation**: Inline code documentation and a central wiki
6. **Daily Stand-ups**: Brief team syncs to address blockers
7. **Weekly Planning**: Sprint planning with task assignments
8. **Bi-weekly Demos**: Working software demonstrations

## Security Considerations

- **Authentication**: Use Devise for robust user authentication
- **Authorization**: Implement with Pundit or CanCanCan
- **Multi-tenancy**: Strict data isolation between tenants
- **Input Validation**: Validate and sanitize all user input
- **HTTPS**: Enforce secure connections
- **API Security**: Protect API endpoints and implement proper authentication
- **Dependency Scanning**: Regular security audits of dependencies

## Testing Strategy

- **Unit Tests**: Models, services, background jobs
- **Integration Tests**: Controller actions, API endpoints
- **System Tests**: End-to-end workflows, Hotwire interactions
- **Performance Tests**: Critical paths and data operations

## Getting Started

### Prerequisites

- Ruby 3.2+
- PostgreSQL 14+
- Redis (for Sidekiq, if used)
- Node.js and Yarn

### Installation

1. Clone the repository
   ```
   git clone https://github.com/your-org/supplyflow.git
   cd supplyflow
   ```

2. Install dependencies
   ```
   bundle install
   yarn install
   ```

3. Set up the database
   ```
   rails db:create
   rails db:migrate
   rails db:seed
   ```

4. Start the development server
   ```
   ./bin/dev
   ```

## Contributing

Please see our [CONTRIBUTING.md](CONTRIBUTING.md) file for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the [MIT License](LICENSE).
