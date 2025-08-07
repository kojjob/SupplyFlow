# Base policy class for Pundit
require_relative "permission_concern"

class ApplicationPolicy
  include PermissionConcern

  attr_reader :user, :organization, :record

  def initialize(user_context, record)
    @user = user_context[:user]
    @organization = user_context[:organization]
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  # Ensure the record belongs to the current organization
  def same_organization?
    return false unless user && organization
    return true unless record.respond_to?(:organization_id)

    record.organization_id == organization.id
  end

  # Check if user is active
  def active_user?
    user && user.active?
  end

  # Basic access validation for all policies
  def basic_access?
    user && organization && active_user?
  end

  # Scope for filtering records by organization
  class Scope
    def initialize(user_context, scope)
      @user = user_context[:user]
      @organization = user_context[:organization]
      @scope = scope
    end

    def resolve
      if @organization && @scope.column_names.include?("organization_id")
        @scope.where(organization_id: @organization.id)
      else
        @scope.all
      end
    end

    private

    attr_reader :user, :organization, :scope
  end
end
