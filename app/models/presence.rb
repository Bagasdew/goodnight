class Presence < ApplicationRecord
  belongs_to :user

  validate :check_latest_presence, on: :create

  def check_latest_presence
    latest_presence = Presence.where(user_id: user_id).last
    if latest_presence.present? && latest_presence.clock_out.nil?
      errors.add(:base, "User hasn't clocked out yet")
    end
  end
end
