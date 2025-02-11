class FollowList < ApplicationRecord
  belongs_to :follower, class_name: 'User'
  belongs_to :followee, class_name: 'User'

  validates :follower_id, presence: true
  validates :followee_id, presence: true
  validate :cannot_follow_self
  validates_uniqueness_of :follower_id, scope: :followee_id

  private
  def cannot_follow_self
    errors.add(:followee_id, "can't follow yourself") if follower_id == followee_id
  end
end
