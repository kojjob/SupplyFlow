require "test_helper"

class OrderTest < ActiveSupport::TestCase
  setup do
    @organization = organizations(:acme)
    @customer = customers(:customer_one)
    @user = users(:admin_user)
    @product = products(:product_one)
  end

  test "should create a valid order" do
    order = Order.new(
      organization: @organization,
      customer: @customer,
      user: @user,
      order_date: Date.today
    )

    assert order.valid?
    assert_nil order.order_number

    order.save
    assert_not_nil order.order_number
    assert_match(/ORD-\d{8}-\d{4}/, order.order_number)
  end

  test "should require customer, user, and organization" do
    order = Order.new(order_date: Date.today)
    assert_not order.valid?
    assert_includes order.errors[:customer], "must exist"
    assert_includes order.errors[:user], "must exist"
    assert_includes order.errors[:organization], "must exist"
  end

  test "should have a unique order number per organization" do
    existing_order = orders(:pending_order)
    order = Order.new(
      organization: existing_order.organization,
      customer: @customer,
      user: @user,
      order_number: existing_order.order_number
    )

    assert_not order.valid?
    assert_includes order.errors[:order_number], "has already been taken"
  end

  test "should allow order numbers to be reused across organizations" do
    existing_order = orders(:pending_order)
    different_org = organizations(:globex)

    order = Order.new(
      organization: different_org,
      customer: customers(:customer_two),
      user: users(:staff_user),
      order_number: existing_order.order_number
    )

    assert order.valid?
  end

  test "should calculate totals correctly" do
    order = Order.new(
      organization: @organization,
      customer: @customer,
      user: @user,
      order_date: Date.today,
      tax_amount: 15.0,
      shipping_amount: 10.0,
      discount_amount: 5.0
    )

    # Add order items
    order.order_items.build(
      product: @product,
      quantity: 2,
      unit_price: 25.0,
      tax_rate: 5.0
    )

    order.save
    order.reload

    # Subtotal should be 2 * 25 = 50
    assert_equal 50.0, order.subtotal.to_f

    # Tax from items: 50 * 0.05 = 2.5
    # Additional tax: 15.0
    # Total tax: 17.5

    # Total: 50 (subtotal) + 17.5 (tax) + 10 (shipping) - 5 (discount) = 72.5
    assert_equal 72.5, order.total_amount.to_f
  end

  test "should update payment status based on payments" do
    order = orders(:pending_order)
    assert_equal "unpaid", order.payment_status

    # Add a partial payment
    payment = Payment.create(
      organization: order.organization,
      payable: order,
      user: @user,
      payment_number: "PAY-#{Time.now.to_i}",
      payment_date: Date.today,
      amount: order.total_amount / 2,
      payment_method: "cash"
    )

    order.update_payment_status
    assert_equal "partially_paid", order.payment_status

    # Add the remaining payment
    Payment.create(
      organization: order.organization,
      payable: order,
      user: @user,
      payment_number: "PAY-#{Time.now.to_i + 1}",
      payment_date: Date.today,
      amount: order.total_amount / 2,
      payment_method: "cash"
    )

    order.update_payment_status
    assert_equal "paid", order.payment_status
  end

  test "should handle order status transitions correctly" do
    order = orders(:pending_order)

    # Cancel the order
    assert order.can_be_canceled?
    assert order.cancel
    assert_equal "canceled", order.status

    # Cannot cancel an already canceled order
    assert_not order.can_be_canceled?
    assert_not order.cancel

    # Test shipping and delivery
    order = orders(:processing_order)

    assert order.update(status: "shipped", shipping_date: Date.today)
    assert_not order.can_be_canceled?
    assert order.can_be_returned?

    assert order.update(status: "delivered", delivery_date: Date.today)
    assert_not order.can_be_canceled?
    assert order.can_be_returned?

    # Test return
    assert order.return_order
    assert_equal "returned", order.status
  end

  test "should update inventory when shipping" do
    order = orders(:processing_order)
    product = order.order_items.first.product
    location = order.user.default_location

    # Create inventory item for the product
    inventory_item = InventoryItem.find_or_create_by(
      organization: order.organization,
      product: product,
      location: location
    )
    inventory_item.update(quantity: 20)
    initial_quantity = inventory_item.quantity

    # Ship the order
    order.update(status: "shipped")

    # Reload the inventory item
    inventory_item.reload

    # Check that inventory was reduced by the order item quantity
    assert_equal initial_quantity - order.order_items.first.quantity, inventory_item.quantity
  end

  test "should generate order number with correct format" do
    order = Order.create(
      organization: @organization,
      customer: @customer,
      user: @user,
      order_date: Date.today
    )

    # Format should be ORD-YYYYMMDD-XXXX
    date_part = Date.today.strftime("%Y%m%d")
    assert_match(/^ORD-#{date_part}-\d{4}$/, order.order_number)
  end
end
