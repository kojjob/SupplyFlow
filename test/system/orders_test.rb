require "application_system_test_case"

class OrdersTest < ApplicationSystemTestCase
  setup do
    @order = orders(:one)
  end

  test "visiting the index" do
    visit orders_url
    assert_selector "h1", text: "Orders"
  end

  test "should create order" do
    visit orders_url
    click_on "New order"

    fill_in "Billing address", with: @order.billing_address
    fill_in "Currency", with: @order.currency
    fill_in "Customer", with: @order.customer_id
    fill_in "Delivery date", with: @order.delivery_date
    fill_in "Discount amount", with: @order.discount_amount
    fill_in "Metadata", with: @order.metadata
    fill_in "Notes", with: @order.notes
    fill_in "Order date", with: @order.order_date
    fill_in "Order number", with: @order.order_number
    fill_in "Organization", with: @order.organization_id
    fill_in "Payment status", with: @order.payment_status
    fill_in "Shipping address", with: @order.shipping_address
    fill_in "Shipping amount", with: @order.shipping_amount
    fill_in "Shipping date", with: @order.shipping_date
    fill_in "Shipping method", with: @order.shipping_method
    fill_in "Status", with: @order.status
    fill_in "Subtotal", with: @order.subtotal
    fill_in "Tax amount", with: @order.tax_amount
    fill_in "Total amount", with: @order.total_amount
    fill_in "Tracking number", with: @order.tracking_number
    fill_in "User", with: @order.user_id
    click_on "Create Order"

    assert_text "Order was successfully created"
    click_on "Back"
  end

  test "should update Order" do
    visit order_url(@order)
    click_on "Edit this order", match: :first

    fill_in "Billing address", with: @order.billing_address
    fill_in "Currency", with: @order.currency
    fill_in "Customer", with: @order.customer_id
    fill_in "Delivery date", with: @order.delivery_date
    fill_in "Discount amount", with: @order.discount_amount
    fill_in "Metadata", with: @order.metadata
    fill_in "Notes", with: @order.notes
    fill_in "Order date", with: @order.order_date
    fill_in "Order number", with: @order.order_number
    fill_in "Organization", with: @order.organization_id
    fill_in "Payment status", with: @order.payment_status
    fill_in "Shipping address", with: @order.shipping_address
    fill_in "Shipping amount", with: @order.shipping_amount
    fill_in "Shipping date", with: @order.shipping_date
    fill_in "Shipping method", with: @order.shipping_method
    fill_in "Status", with: @order.status
    fill_in "Subtotal", with: @order.subtotal
    fill_in "Tax amount", with: @order.tax_amount
    fill_in "Total amount", with: @order.total_amount
    fill_in "Tracking number", with: @order.tracking_number
    fill_in "User", with: @order.user_id
    click_on "Update Order"

    assert_text "Order was successfully updated"
    click_on "Back"
  end

  test "should destroy Order" do
    visit order_url(@order)
    accept_confirm { click_on "Destroy this order", match: :first }

    assert_text "Order was successfully destroyed"
  end
end
