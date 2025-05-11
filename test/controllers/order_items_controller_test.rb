require "test_helper"

class OrderItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @order_item = order_items(:one)
  end

  test "should get index" do
    get order_items_url
    assert_response :success
  end

  test "should get new" do
    get new_order_item_url
    assert_response :success
  end

  test "should create order_item" do
    assert_difference("OrderItem.count") do
      post order_items_url, params: { order_item: { discount_amount: @order_item.discount_amount, metadata: @order_item.metadata, notes: @order_item.notes, order_id: @order_item.order_id, product_id: @order_item.product_id, quantity: @order_item.quantity, shipped_quantity: @order_item.shipped_quantity, tax_amount: @order_item.tax_amount, tax_rate: @order_item.tax_rate, total_amount: @order_item.total_amount, unit_price: @order_item.unit_price } }
    end

    assert_redirected_to order_item_url(OrderItem.last)
  end

  test "should show order_item" do
    get order_item_url(@order_item)
    assert_response :success
  end

  test "should get edit" do
    get edit_order_item_url(@order_item)
    assert_response :success
  end

  test "should update order_item" do
    patch order_item_url(@order_item), params: { order_item: { discount_amount: @order_item.discount_amount, metadata: @order_item.metadata, notes: @order_item.notes, order_id: @order_item.order_id, product_id: @order_item.product_id, quantity: @order_item.quantity, shipped_quantity: @order_item.shipped_quantity, tax_amount: @order_item.tax_amount, tax_rate: @order_item.tax_rate, total_amount: @order_item.total_amount, unit_price: @order_item.unit_price } }
    assert_redirected_to order_item_url(@order_item)
  end

  test "should destroy order_item" do
    assert_difference("OrderItem.count", -1) do
      delete order_item_url(@order_item)
    end

    assert_redirected_to order_items_url
  end
end
