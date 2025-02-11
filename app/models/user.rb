class User < ApplicationRecord
  has_many :presences
  has_many :follow_lists

  def following
    followings = FollowList.includes(:followee).where(follower_id: self.id)

    followings.map do |following|
      {
        followee_id: following.followee.id,
        name: following.followee.name
      }
    end
  end

  def follower
    followers = FollowList.includes(:follower).where(followee_id: self.id)
    followers.map do |follower|
      {
        follower_id: follower.follower.id,
        name: follower.follower.name
      }
    end

  end
end
