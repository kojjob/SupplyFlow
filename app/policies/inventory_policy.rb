class InventoryPolicy < ApplicationPolicy
  def index?
    user.present?
  end
  
  def transactions?
    user.present?
  end
  
  def report?
    user.present? && user.can_view_reports?
  end
end