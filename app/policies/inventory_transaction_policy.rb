class InventoryTransactionPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    same_organization?
  end
  
  class Scope < Scope
    def resolve
      scope.where(organization_id: organization.id)
    end
  end
end