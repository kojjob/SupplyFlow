class OrderPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      # Only return orders belonging to the user's organization
      scope.where(organization: user.organization)
    end
  end

  # Index permissions - who can view the order listing
  def index?
    # All authenticated users can view orders list
    user.present?
  end

  # Show permissions - who can view order details
  def show?
    # Users can only view orders in their organization
    record.organization_id == user.organization_id
  end

  # New/Create permissions - who can create orders
  def new?
    create?
  end

  def create?
    # Only staff with appropriate permissions can create orders
    return false unless user.present?

    # Check if user has explicit order management permissions
    return true if user.admin? || user.permissions&.include?("manage_orders")

    # Staff members can create orders by default
    user.role == "staff" || user.role == "manager"
  end

  # Edit/Update permissions - who can modify orders
  def edit?
    update?
  end

  def update?
    # Only staff with appropriate permissions can update orders
    return false unless user.present? && record.organization_id == user.organization_id

    # Don't allow editing of completed orders
    return false if %w[delivered canceled returned].include?(record.status)

    # Check if user has explicit order management permissions
    return true if user.admin? || user.permissions&.include?("manage_orders")

    # Staff members can update orders by default
    # Only the user who created the order or a manager can edit it
    user.role == "manager" || record.user_id == user.id
  end

  # Destroy permissions - who can delete orders
  def destroy?
    # Only users with appropriate permissions can delete orders
    return false unless user.present? && record.organization_id == user.organization_id

    # Only allow deletion of draft orders
    return false unless record.status == "draft"

    # Check if user has explicit order management permissions
    return true if user.admin? || user.permissions&.include?("manage_orders")

    # Only managers or the user who created the draft order can delete it
    user.role == "manager" || record.user_id == user.id
  end

  # Status change permissions

  # Cancel permission
  def cancel?
    # Only users with appropriate permissions can cancel orders
    return false unless user.present? && record.organization_id == user.organization_id

    # Check if the order can be canceled
    return false unless record.can_be_canceled?

    # Check if user has explicit order management permissions
    return true if user.admin? || user.permissions&.include?("manage_orders")

    # Only managers or the user who created the order can cancel it
    user.role == "manager" || record.user_id == user.id
  end

  # Ship permission
  def ship?
    # Only users with appropriate permissions can ship orders
    return false unless user.present? && record.organization_id == user.organization_id

    # Only pending or processing orders can be shipped
    return false unless %w[pending processing].include?(record.status)

    # Check if user has explicit order management permissions
    return true if user.admin? || user.permissions&.include?("manage_orders")

    # Only staff members can mark orders as shipped
    user.role == "staff" || user.role == "manager"
  end

  # Deliver permission
  def deliver?
    # Only users with appropriate permissions can mark orders as delivered
    return false unless user.present? && record.organization_id == user.organization_id

    # Only shipped orders can be marked as delivered
    return false unless record.status == "shipped"

    # Check if user has explicit order management permissions
    return true if user.admin? || user.permissions&.include?("manage_orders")

    # Only staff members can mark orders as delivered
    user.role == "staff" || user.role == "manager"
  end

  # Return permission
  def return?
    # Only users with appropriate permissions can return orders
    return false unless user.present? && record.organization_id == user.organization_id

    # Check if the order can be returned
    return false unless record.can_be_returned?

    # Check if user has explicit order management permissions
    return true if user.admin? || user.permissions&.include?("manage_orders")

    # Only managers can return orders
    user.role == "manager"
  end

  # Invoice permission
  def invoice?
    # Same permissions as show - anyone who can view the order can view/print the invoice
    show?
  end
end
