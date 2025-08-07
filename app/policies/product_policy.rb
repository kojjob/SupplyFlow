class ProductPolicy < ApplicationPolicy
  def index?
    basic_access? && view_products?
  end

  def show?
    basic_access? && same_organization? && view_products?
  end

  def create?
    basic_access? && same_organization? && manage_products?
  end

  def update?
    basic_access? && same_organization? && manage_products?
  end

  def destroy?
    basic_access? && same_organization? && user.can_delete_products?
  end

  # Additional product permissions
  def import?
    basic_access? && manage_products?
  end

  def export?
    basic_access? && view_products?
  end

  def bulk_update?
    basic_access? && manage_products?
  end

  class Scope < Scope
    def resolve
      scope.where(organization_id: organization.id)
    end
  end
end
