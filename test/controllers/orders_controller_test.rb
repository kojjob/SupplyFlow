require "test_helper"

class OrdersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @organization = organizations(:acme)
    @user = users(:admin_user)
    @customer = customers(:customer_one)
    @product = products(:product_one)
    @order = orders(:pending_order)

    # Set the current tenant
    ActsAsTenant.current_tenant = @organization

    # Sign in the user
    sign_in @user
  end

  teardown do
    # Clear the current tenant
    ActsAsTenant.current_tenant = nil
  end

  test "should get index" do
    get orders_url
    assert_response :success
    assert_not_nil assigns(:orders)
  end

  test "should filter orders by status" do
    get orders_url, params: { status: "pending" }
    assert_response :success

    orders = assigns(:orders)
    assert orders.all? { |o| o.status == "pending" }
  end

  test "should filter orders by customer" do
    get orders_url, params: { customer_id: @customer.id }
    assert_response :success

    orders = assigns(:orders)
    assert orders.all? { |o| o.customer_id == @customer.id }
  end

  test "should get new" do
    get new_order_url
    assert_response :success
    assert_not_nil assigns(:order)
    assert_not_nil assigns(:products)
    assert_not_nil assigns(:customers)
  end

  test "should create order" do
    assert_difference("Order.count") do
      post orders_url, params: {
        order: {
          customer_id: @customer.id,
          order_date: Date.today,
          shipping_address: "123 Test St",
          billing_address: "123 Test St",
          order_items_attributes: {
            "0" => {
              product_id: @product.id,
              quantity: 2,
              unit_price: 25.0
            }
          }
        }
      }
    end

    assert_redirected_to order_url(Order.last)
    assert_equal "Order was successfully created.", flash[:notice]
  end

  test "should reject invalid order creation" do
    assert_no_difference("Order.count") do
      post orders_url, params: {
        order: {
          order_date: Date.today,
          # Missing customer_id
          order_items_attributes: {
            "0" => {
              product_id: @product.id,
              quantity: 2,
              unit_price: 25.0
            }
          }
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should show order" do
    get order_url(@order)
    assert_response :success
    assert_not_nil assigns(:order)
    assert_not_nil assigns(:order_items)
    assert_not_nil assigns(:payments)
  end

  test "should get edit" do
    get edit_order_url(@order)
    assert_response :success
    assert_not_nil assigns(:order)
    assert_not_nil assigns(:products)
    assert_not_nil assigns(:customers)
  end

  test "should redirect edit for completed orders" do
    @order.update(status: "delivered")
    get edit_order_url(@order)
    assert_redirected_to order_url(@order)
    assert_equal "Completed orders cannot be edited.", flash[:alert]
  end

  test "should update order" do
    patch order_url(@order), params: {
      order: {
        shipping_address: "Updated Address",
        billing_address: "Updated Billing Address",
        order_items_attributes: {
          "0" => {
            id: @order.order_items.first.id,
            quantity: 3
          }
        }
      }
    }

    assert_redirected_to order_url(@order)
    assert_equal "Order was successfully updated.", flash[:notice]

    @order.reload
    assert_equal "Updated Address", @order.shipping_address
    assert_equal 3, @order.order_items.first.quantity
  end

  test "should not update completed orders" do
    @order.update(status: "delivered")

    patch order_url(@order), params: {
      order: {
        shipping_address: "Updated Address"
      }
    }

    assert_redirected_to order_url(@order)
    assert_equal "Completed orders cannot be updated.", flash[:alert]
  end

  test "should destroy draft order" do
    @order.update(status: "draft")

    assert_difference("Order.count", -1) do
      delete order_url(@order)
    end

    assert_redirected_to orders_url
    assert_equal "Order was successfully deleted.", flash[:notice]
  end

  test "should not destroy non-draft orders" do
    assert_no_difference("Order.count") do
      delete order_url(@order) # @order is pending, not draft
    end

    assert_redirected_to orders_url
    assert_equal "Only draft orders can be deleted.", flash[:alert]
  end

  test "should cancel order" do
    post cancel_order_url(@order)

    @order.reload
    assert_equal "canceled", @order.status
    assert_redirected_to order_url(@order)
    assert_equal "Order was successfully canceled.", flash[:notice]
  end

  test "should not cancel shipped orders" do
    @order.update(status: "shipped")

    post cancel_order_url(@order)

    assert_redirected_to order_url(@order)
    assert_equal "This order cannot be canceled.", flash[:alert]
  end

  test "should mark order as shipped" do
    post ship_order_url(@order)

    @order.reload
    assert_equal "shipped", @order.status
    assert_not_nil @order.shipping_date
    assert_redirected_to order_url(@order)
    assert_equal "Order was successfully marked as shipped.", flash[:notice]
  end

  test "should mark order as delivered" do
    @order.update(status: "shipped")

    post deliver_order_url(@order)

    @order.reload
    assert_equal "delivered", @order.status
    assert_not_nil @order.delivery_date
    assert_redirected_to order_url(@order)
    assert_equal "Order was successfully marked as delivered.", flash[:notice]
  end

  test "should process order return" do
    @order.update(status: "delivered")

    post return_order_url(@order)

    @order.reload
    assert_equal "returned", @order.status
    assert_redirected_to order_url(@order)
    assert_equal "Order was successfully marked as returned.", flash[:notice]
  end

  test "should get invoice" do
    get invoice_order_url(@order, format: :html)
    assert_response :success

    get invoice_order_url(@order, format: :pdf)
    assert_response :success
  end
end
