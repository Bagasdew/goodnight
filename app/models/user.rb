class User < ApplicationRecord
  has_many :presences
  has_many :follow_lists

  def following
    FollowList.where(follower_id: self.id)
  end

  def follower
    FollowList.where(followee_id: self.id)
  end
end
