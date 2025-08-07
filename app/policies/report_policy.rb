class ReportPolicy < ApplicationPolicy
  include PermissionConcern

  def view_sales?
    user.owner? || user.admin? || user.manager? || user.has_permission?(:view_sales_reports)
  end

  def view_inventory?
    user.owner? || user.admin? || user.manager? || user.has_permission?(:view_inventory_reports)
  end

  def view_supplier_performance?
    user.owner? || user.admin? || user.manager? || user.has_permission?(:view_supplier_reports)
  end

  def view_customer_performance?
    user.owner? || user.admin? || user.manager? || user.has_permission?(:view_customer_reports)
  end

  def export_reports?
    user.owner? || user.admin? || user.has_permission?(:export_reports)
  end
end
