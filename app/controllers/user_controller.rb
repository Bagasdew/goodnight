class UserController < ApplicationController

  def index
    current_user = User.find_by(id: index_params[:user_id])
    following_ids = current_user.following.pluck(:followee_id)
    following_presences = Presence.includes(:user).where(user_id: following_ids, clock_in: 1.week.ago..Time.now).order(:clock_in)
    formatted_presences = []
    following_presences.each do |presence|
      formatted_presences << {
        name: presence.user.name,
        clock_in: ApplicationHelper.format_datetime(presence.clock_in),
        clock_out: ApplicationHelper.format_datetime(presence.clock_out)
      }
    end

    render json: {presences: formatted_presences}, status: :ok
  end

  def clock_in
    presence =  Presence.new(user_id: clock_params[:user_id], clock_in: clock_params[:current_time].to_datetime)

    presence.valid?
    if presence.errors.any?
      render json: { errors: ApplicationHelper.format_errors(presence.errors) }, status: :unprocessable_content
      return
    end

    presence.save!

    render json: {clock_ins: all_clock_ins(clock_params[:user_id])}, status: :ok
  end

  def clock_out
    latest_presence = Presence.where(user_id: clock_params[:user_id]).last
    unless latest_presence.present? && latest_presence.clock_out.nil?
      render json: { errors: "Unable to Clock Out, Not Clocked In yet" }, status: :unprocessable_content
      return
    end

    latest_presence.clock_out = params[:current_time]
    latest_presence.valid?
    if latest_presence.errors.any?
      render json: { errors: ApplicationHelper.format_errors(latest_presence.errors) }, status: :unprocessable_content
      return
    end

    latest_presence.save!
    render json: {current_presence: latest_presence, clock_outs: all_clock_outs(clock_params[:user_id])}, status: :ok
  end

  def follow
    follow_list = FollowList.new(follower_id: follow_params[:user_id], followee_id: follow_params[:following_user_id])
    follow_list.valid?
    if follow_list.errors.any?
      render json: { errors: ApplicationHelper.format_errors(follow_list.errors) }, status: :unprocessable_content
      return
    end

    follow_list.save
    render json: {followings: followings(follow_params[:user_id])}, status: :ok
  end

  def unfollow
    existing_follow_list = FollowList.find_by(follower_id: params[:user_id], followee_id: params[:following_user_id])
    unless existing_follow_list.present?
      render json: { errors: "User is not followed" }, status: :unprocessable_content
      return
    end

    existing_follow_list.destroy!
    render json: {followings: followings(follow_params[:user_id])}, status: :ok
  end

  private

  def all_clock_ins(user_id)
    presences = Presence.where(user_id: user_id).order(:clock_in).pluck(:clock_in)
    presences.map do |presence|
      ApplicationHelper.format_datetime(presence)
    end
  end

  def all_clock_outs(user_id)
    presences = Presence.where(user_id: user_id).order(:clock_out).pluck(:clock_out)
    presences.map do |presence|
      ApplicationHelper.format_datetime(presence)
    end
  end

  def followings(user_id)
    current_user = User.find_by(id: user_id)
    current_user.following
  end

  def index_params
    params.permit(:user_id)
  end

  def clock_params
    params.permit(:user_id, :current_time)
  end

  def follow_params
    params.permit(:user_id, :following_user_id)
  end
end