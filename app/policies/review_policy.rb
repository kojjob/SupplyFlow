class ReviewPolicy < ApplicationPolicy
  # No specific scope for reviews; they are typically accessed via a post.
  # If you had a standalone reviews index, you might define a scope here.
  # class Scope < Scope
  #   def resolve
  #     scope.all
  #   end
  # end

  def create?
    user.present? # Any logged-in user can create a review
  end

  # edit? and update? are often combined
  def update?
    user.present? && (record.user == user || user.admin?) # Only author of review or admin can update
  end

  def edit?
    update?
  end

  def destroy?
    user.present? && (record.user == user || user.admin?) # Only author of review or admin can delete
  end
end
