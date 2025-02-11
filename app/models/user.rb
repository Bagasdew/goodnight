class User < ApplicationRecord
  has_many :presences
  has_many :follow_lists

  def following
    followings = FollowList.includes(:followee).where(follower_id: self.id)

    followings.map do |following|
      {
        name: following.followee.name
      }
    end
  end

  def follower
    followers = FollowList.includes(:follower).where(followee_id: self.id)
    followers.map do |follower|
      {
        name: follower.follower.name
      }
    end

  end
end
