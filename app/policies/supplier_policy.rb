class SupplierPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    same_organization?
  end

  def create?
    same_organization? && user.admin?
  end

  def update?
    same_organization? && user.admin?
  end

  def destroy?
    same_organization? && user.admin?
  end

  class Scope < Scope
    def resolve
      scope.where(organization_id: organization.id)
    end
  end
end
