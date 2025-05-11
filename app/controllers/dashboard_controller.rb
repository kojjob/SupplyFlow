class DashboardController < ApplicationController
  # Skip policy scope check since we're not using a collection that needs scoping
  skip_after_action :verify_policy_scoped

  def index
    # This action requires authentication (handled by ApplicationController)
    # and will be the landing page for authenticated users

    # Authorize the dashboard action
    authorize :dashboard

    # Fetch analytics data for the dashboard
    @analytics = {
      # Inventory metrics
      total_product_skus: Product.count, # Renamed for clarity, used as total in low stock card
      total_units_in_stock: InventoryItem.sum(:quantity), # New metric for total physical units
      low_stock_count: Product.low_stock.count.size, # Get the number of products that are low stock
      out_of_stock_count: Product.out_of_stock.count.size, # Get the number of products that are out of stock

      # Location metrics
      total_locations: Location.count,
      active_locations: Location.active.count,

      # Transaction metrics
      recent_transactions: InventoryTransaction.recent.limit(10),
      transactions_today: InventoryTransaction.where("created_at >= ?", Date.today.beginning_of_day).count,
      transactions_this_week: InventoryTransaction.where("created_at >= ?", 1.week.ago).count,

      # Activity metrics
      user_activities: UserActivity.order(created_at: :desc).limit(10),

      # Time-based metrics
      monthly_transactions: transactions_by_month(6.months.ago),

      # Product metrics
      top_products: top_products_by_transactions(5),

      # Stock value
      total_stock_value: calculate_total_stock_value,
      inventory_by_status: inventory_by_status
    }

    # Chart data
    @chart_data = {
      inventory_trend: generate_inventory_trend_data,
      transactions_by_type: transactions_by_type,
      inventory_by_location: inventory_by_location,
      inventory_value_by_category: inventory_value_by_category
    }
  end

  private

  def transactions_by_month(start_date)
    # Group transactions by month for charting
    InventoryTransaction
      .where("created_at >= ?", start_date)
      .group("DATE_TRUNC('month', created_at)")
      .count
  end

  def transactions_by_type
    # Count transactions by type
    InventoryTransaction
      .where("created_at >= ?", 30.days.ago)
      .group(:transaction_type)
      .count
  end

  def top_products_by_transactions(limit)
    # Find products with most transactions
    Product
      .joins(:inventory_transactions)
      .select("products.*, COUNT(inventory_transactions.id) as transaction_count")
      .where("inventory_transactions.created_at >= ?", 30.days.ago)
      .group("products.id")
      .order("transaction_count DESC")
      .limit(limit)
  end

  def calculate_total_stock_value
    # Calculate total value of current inventory
    InventoryItem
      .joins(:product)
      .sum("inventory_items.quantity * COALESCE(products.cost_price, 0)")
  end

  def inventory_by_status
    # Group inventory items by status
    InventoryItem
      .group(:status)
      .count
  end

  def generate_inventory_trend_data
    # Generate data for inventory level trends over time
    dates = []
    values = []

    # Get last 12 weeks of data
    12.downto(0) do |i|
      date = i.weeks.ago.beginning_of_week
      dates << date.strftime("%b %d")

      # Get a snapshot of inventory at that time based on transactions
      count = InventoryTransaction
        .where("created_at <= ?", date)
        .sum('CASE WHEN transaction_type IN (\'purchase\', \'receipt\', \'return\', \'stock_addition\') THEN quantity
              WHEN transaction_type IN (\'sale\', \'shipment\', \'damage\', \'expiry\', \'stock_removal\') THEN -quantity
              ELSE 0 END')

      # Convert count to a numeric value if it's an array or other object
      count_value = count.is_a?(Numeric) ? count : 0
      values << (count_value > 0 ? count_value : 0)
    end

    { dates: dates, values: values }
  end

  def inventory_by_location
    # Group inventory by location
    Location
      .joins(:inventory_items)
      .select("locations.name, SUM(inventory_items.quantity) as total_quantity")
      .group("locations.id")
      .order("total_quantity DESC")
      .limit(5)
      .map { |l| { name: l.name, value: l.total_quantity } }
  end

  def inventory_value_by_category
    # Group inventory value by product category
    Product
      .joins(:inventory_items)
      .select("products.category, SUM(inventory_items.quantity * COALESCE(products.cost_price, 0)) as total_value")
      .where("products.category IS NOT NULL")
      .group("products.category")
      .order("total_value DESC")
      .limit(5)
      .map { |p| { category: p.category || "Uncategorized", value: p.total_value.to_f } }
  end
end
