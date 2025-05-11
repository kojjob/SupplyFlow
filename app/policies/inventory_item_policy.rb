class InventoryItemPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    same_organization?
  end

  def adjust?
    same_organization? && user.can_adjust_stock?
  end

  def transfer?
    same_organization? && user.can_transfer_stock?
  end

  class Scope < Scope
    def resolve
      scope.where(organization_id: organization.id)
    end
  end
end
