class PurchaseOrderPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    same_organization?
  end

  def create?
    same_organization? && (user.admin? || user.manager?)
  end

  def update?
    same_organization? && (user.admin? || user.manager?) && record.status == "draft"
  end

  def destroy?
    same_organization? && user.admin? && record.status == "draft"
  end

  def receive_items?
    same_organization? && (user.admin? || user.manager?) &&
      [ "pending", "approved" ].include?(record.status)
  end

  class Scope < Scope
    def resolve
      scope.where(organization_id: organization.id)
    end
  end
end
