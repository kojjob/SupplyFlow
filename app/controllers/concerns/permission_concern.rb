module PermissionConcern
  # Tenant/Organization level permissions
  def manage_organization?
    user.owner? || user.admin?
  end

  def manage_settings?
    user.owner? || user.admin?
  end

  # User management permissions
  def manage_users?
    user.owner? || user.admin?
  end

  # Product permissions
  def manage_products?
    user.owner? || user.admin? || user.manager?
  end

  def view_products?
    true # All authenticated users can view products
  end

  # Inventory permissions
  def manage_inventory?
    user.owner? || user.admin? || user.manager? || user.has_permission?(:manage_inventory)
  end

  def view_inventory?
    true # All authenticated users can view inventory
  end

  # Location permissions
  def manage_locations?
    user.owner? || user.admin? || user.manager?
  end

  def view_locations?
    true # All authenticated users can view locations
  end

  # Supplier permissions
  def manage_suppliers?
    user.owner? || user.admin? || user.manager?
  end

  def view_suppliers?
    user.owner? || user.admin? || user.manager? || user.staff?
  end

  # Customer permissions
  def manage_customers?
    user.owner? || user.admin? || user.manager? || user.has_permission?(:manage_customers)
  end

  def view_customers?
    user.owner? || user.admin? || user.manager? || user.staff?
  end

  # Purchase Order permissions
  def manage_purchase_orders?
    user.owner? || user.admin? || user.manager? || user.has_permission?(:manage_purchase_orders)
  end

  def view_purchase_orders?
    user.owner? || user.admin? || user.manager? || user.staff?
  end

  # Sales Order permissions
  def manage_sales_orders?
    user.owner? || user.admin? || user.manager? || user.has_permission?(:manage_sales_orders)
  end

  def view_sales_orders?
    user.owner? || user.admin? || user.manager? || user.staff?
  end

  # Payment permissions
  def manage_payments?
    user.owner? || user.admin? || user.has_permission?(:manage_payments)
  end

  def view_payments?
    user.owner? || user.admin? || user.manager? || user.has_permission?(:view_payments)
  end

  # Report permissions
  def view_reports?
    user.owner? || user.admin? || user.manager? || user.has_permission?(:view_reports)
  end

  # Dashboard permissions
  def view_dashboard?
    true # All authenticated users can view dashboard
  end

  # Same organization check (basic tenant isolation)
  def same_organization?
    user.organization_id == record.try(:organization_id) ||
    user.organization_id == record.try(:organization).try(:id)
  end

  # Basic access check for most resources
  def basic_access?
    same_organization?
  end
end
