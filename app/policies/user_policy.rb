class UserPolicy < ApplicationPolicy
  def index?
    basic_access? && manage_users?
  end

  def show?
    basic_access? && same_organization? && (manage_users? || record.id == user.id)
  end

  def create?
    basic_access? && manage_users?
  end

  def update?
    return false unless basic_access? && same_organization?

    if record.id == user.id
      # Users can update their own profiles
      true
    else
      # Only admins/owners can update other users
      manage_users?
    end
  end

  def destroy?
    basic_access? && same_organization? && manage_users? && record.id != user.id && !record.owner?
  end

  # Additional permissions

  def assign_roles?
    user.owner? || user.admin?
  end

  def change_role?
    basic_access? && same_organization? && assign_roles? && record.id != user.id && !record.owner?
  end

  def activate?
    basic_access? && same_organization? && manage_users? && record.id != user.id
  end

  def deactivate?
    basic_access? && same_organization? && manage_users? && record.id != user.id && !record.owner?
  end

  def reset_password?
    basic_access? && same_organization? && (manage_users? || record.id == user.id)
  end

  def unlock?
    basic_access? && same_organization? && manage_users?
  end

  def impersonate?
    basic_access? && user.owner? && record.id != user.id && same_organization?
  end

  def api_access?
    basic_access? && same_organization? && (record.id == user.id || manage_users?)
  end

  class Scope < Scope
    def resolve
      if user.admin? || user.owner?
        scope.where(organization_id: organization.id)
      else
        scope.where(id: user.id)
      end
    end
  end
end
