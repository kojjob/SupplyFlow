class SalesOrderPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    same_organization?
  end

  def create?
    same_organization? && (user.admin? || user.manager? || user.sales?)
  end

  def update?
    same_organization? && (user.admin? || user.manager? || user.sales?) &&
      [ "draft", "pending" ].include?(record.status)
  end

  def destroy?
    same_organization? && user.admin? && record.status == "draft"
  end

  def ship_items?
    same_organization? && (user.admin? || user.manager? || user.warehouse?) &&
      [ "confirmed", "processing" ].include?(record.status)
  end

  class Scope < Scope
    def resolve
      scope.where(organization_id: organization.id)
    end
  end
end
