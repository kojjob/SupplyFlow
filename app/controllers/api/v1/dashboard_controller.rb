module Api
  module V1
    class DashboardController < BaseController
      before_action :authenticate_api_user!

      # GET /api/v1/dashboard
      def index
        # Summary data for dashboard
        render json: {
          sales_summary: sales_summary_data,
          inventory_summary: inventory_summary_data,
          recent_activities: recent_activities_data(10)
        }, status: :ok
      end

      # GET /api/v1/dashboard/sales_summary
      def sales_summary
        render json: { sales_summary: sales_summary_data }, status: :ok
      end

      # GET /api/v1/dashboard/inventory_summary
      def inventory_summary
        render json: { inventory_summary: inventory_summary_data }, status: :ok
      end

      # GET /api/v1/dashboard/recent_activities
      def recent_activities
        limit = params[:limit].present? ? params[:limit].to_i : 20
        render json: { recent_activities: recent_activities_data(limit) }, status: :ok
      end

      private

      def sales_summary_data
        # Get sales data for the last 30 days
        sales_orders = SalesOrder.where(created_at: 30.days.ago..Time.current)
        today_sales = sales_orders.where(created_at: Time.current.beginning_of_day..Time.current).sum(:total_amount)
        week_sales = sales_orders.where(created_at: 7.days.ago..Time.current).sum(:total_amount)
        month_sales = sales_orders.sum(:total_amount)

        # Get pending, processing and completed orders counts
        pending_count = SalesOrder.where(status: "pending").count
        processing_count = SalesOrder.where(status: "processing").count
        completed_count = SalesOrder.where(status: "completed").count

        # Get total customers
        customer_count = Customer.count

        {
          today_sales: today_sales,
          week_sales: week_sales,
          month_sales: month_sales,
          pending_orders: pending_count,
          processing_orders: processing_count,
          completed_orders: completed_count,
          customer_count: customer_count
        }
      end

      def inventory_summary_data
        # Get low stock items (less than reorder point)
        low_stock_items = InventoryItem.joins(:product)
                                      .where("quantity < products.reorder_point")
                                      .count

        # Get out of stock items
        out_of_stock_items = InventoryItem.where(quantity: 0).count

        # Get total inventory value
        total_inventory_value = InventoryItem.joins(:product)
                                           .sum("quantity * products.unit_cost")

        # Get inventory items count by location
        inventory_by_location = Location.joins(:inventory_items)
                                      .group("locations.id")
                                      .select("locations.name, COUNT(inventory_items.id) as item_count")
                                      .map { |loc| { name: loc.name, count: loc.item_count } }

        {
          low_stock_count: low_stock_items,
          out_of_stock_count: out_of_stock_items,
          total_inventory_value: total_inventory_value,
          inventory_by_location: inventory_by_location
        }
      end

      def recent_activities_data(limit)
        activities = UserActivity.order(created_at: :desc).limit(limit)

        activities.map do |activity|
          {
            id: activity.id,
            user_id: activity.user_id,
            user_name: "#{activity.user.first_name} #{activity.user.last_name}",
            activity_type: activity.activity_type,
            description: activity.description,
            created_at: activity.created_at
          }
        end
      end
    end
  end
end
