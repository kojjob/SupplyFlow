class PagesPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def index?
    true
  end

  def offline?
    true
  end

  def swipe_test?
    true
  end

  def about?
    true
  end

  def contact?
    true
  end

  def support?
    true
  end
end
