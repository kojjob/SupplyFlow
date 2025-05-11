class Current < ActiveSupport::CurrentAttributes
  attribute :user, :organization, :ip_address, :user_agent, :request_id

  def user=(user)
    super
    self.organization = user&.organization
  end

  def reset
    self.user = nil
    self.organization = nil
    self.ip_address = nil
    self.user_agent = nil
    self.request_id = nil
  end
end
