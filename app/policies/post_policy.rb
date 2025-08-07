class PostPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user&.admin? # Admins can see all posts (drafts, archived, etc.)
        scope.all
      elsif user # Logged-in users might see their own drafts too
        scope.where(status: :published).or(scope.where(user: user, status: :draft))
      else # Public users only see published posts
        scope.published
      end
    end
  end

  def index?
    true # Public can see the index of published posts
  end

  def show?
    return true if record.published? # Public can see published posts
    user.present? && (record.user == user || user.admin?) # Author or admin can see non-published
  end

  def create?
    user.present? # Any logged-in user can create (can be refined by role)
  end

  def new?
    create?
  end

  def update?
    user.present? && (record.user == user || user.admin?) # Only author or admin can update
  end

  def edit?
    update?
  end

  def destroy?
    user.present? && (record.user == user || user.admin?) # Only author or admin can delete
  end
end
