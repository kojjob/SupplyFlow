class InventoryPolicy < ApplicationPolicy
  def index?
    basic_access? && view_inventory?
  end

  def transactions?
    basic_access? && view_inventory?
  end

  def report?
    basic_access? && view_reports?
  end

  def adjust?
    basic_access? && adjust_inventory?
  end

  def transfer?
    basic_access? && transfer_inventory?
  end

  def import?
    basic_access? && manage_inventory?
  end

  def export?
    basic_access? && view_inventory?
  end

  # Additional permission methods
  def adjust_inventory?
    user.admin? || user.manager? || user.has_permission?(:adjust_inventory)
  end

  def transfer_inventory?
    user.admin? || user.manager? || user.staff? || user.has_permission?(:transfer_inventory)
  end

  class Scope < Scope
    def resolve
      scope.where(organization_id: organization.id)
    end
  end
end
