class OrganizationPolicy < ApplicationPolicy
  def show?
    same_organization?
  end

  def update?
    same_organization? && user.admin?
  end

  # Only system admins can create or destroy organizations
  # This would typically be handled through a separate admin interface
  def create?
    false
  end

  def destroy?
    false
  end

  class Scope < Scope
    def resolve
      scope.where(id: organization.id)
    end
  end
end
