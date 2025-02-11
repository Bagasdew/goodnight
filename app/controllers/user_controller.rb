class UserController < ApplicationController

  def index

    render json: {}, status: :ok
  end

  def clock_in
    presence = Presence.new(clock_params)
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
    unless latest_presence.present? && latest_presence.clock_out.present?
      render json: { errors: ApplicationHelper.format_errors(errors.add(:base, "Unable to Clock Out, Not Clocked In yet")) }, status: :unprocessable_content
    end

    latest_presence.clock_out = params[:clock_out]
    latest_presence.valid?
    if latest_presence.errors.any?
      render json: { errors: ApplicationHelper.format_errors(latest_presence.errors) }, status: :unprocessable_content
      return
    end

    latest_presence.save!
    render json: {clock_ins: all_clock_outs(clock_params[:user_id])}, status: :ok
  end

  def follow
    render json: {}, status: :ok
  end

  private

  def all_clock_ins(user_id)
    Presence.where(user_id: user_id).pluck(:clock_in).order(:clock_in)
  end

  def all_clock_outs(user_id)
    Presence.where(user_id: user_id).pluck(:clock_out).order(:clock_out)
  end

  def clock_params
    params.permit(:user_id, :current_time)
  end
end