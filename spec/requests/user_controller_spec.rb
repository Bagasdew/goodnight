require 'rails_helper'

RSpec.describe "UserControllers", type: :request do

  let(:now) {Time.now}

  let(:john) {create(:user, name: 'John')}
  let(:jane) {create(:user, name: 'Jane')}

  let(:john_follows_jane) {create(:follow_list, follower_id: john.id, followee_id: jane.id)}
  let(:jane_follows_john) {create(:follow_list, follower_id: jane.id, followee_id: john.id)}

  let(:john_clocks_in) {create(:presence, user_id: john.id, clock_in: now-8.hours)}
  let(:john_clocks_in_weeks_ago) {create(:presence, user_id: john.id, clock_in: now-2.week)}

  describe 'GET /user/index' do
    context 'with valid parameters' do
      it 'returns following user clock ins from the past week' do
        john_clocks_in
        john_clocks_in.update(clock_out: now)
        jane_follows_john
        get '/user/index', params: {
          user_id: jane.id
        }

        expect(response).to have_http_status(:ok)
        expect(json['presences'].first).to eq({
                                                "name" => john.name,
                                                "clock_in" => ApplicationHelper.format_datetime(now.in_time_zone - 8.hours),
                                                "clock_out" => ApplicationHelper.format_datetime(now.in_time_zone)
                                              })
      end
    end

    context 'when following clocks in more than one week' do
      it 'returns following user clock ins from the past week' do
        john_clocks_in_weeks_ago
        john_clocks_in_weeks_ago.update(clock_out: now-1.week)
        john_clocks_in
        john_clocks_in.update(clock_out: now)

        jane_follows_john
        get '/user/index', params: {
          user_id: jane.id
        }

        expect(response).to have_http_status(:ok)
        expect(json['presences'].first).to eq({
                                                "name" => john.name,
                                                "clock_in" => ApplicationHelper.format_datetime(now.in_time_zone - 8.hours),
                                                "clock_out" => ApplicationHelper.format_datetime(now.in_time_zone)
                                              })
      end
    end
  end

  describe 'POST /user/clock_in' do
    context 'with valid parameters' do
      let(:now) {Time.now}
      it 'creates a new presence' do
        expect {
          post '/user/clock_in', params: {
            user_id: john.id,
            current_time: now
          }
        }.to change(Presence, :count).by(1)

        expect(response).to have_http_status(:ok)
        expect(json['clock_ins'].first).to eq(ApplicationHelper.format_datetime(now.in_time_zone))
      end
    end

    context 'with invalid parameters' do

      it 'returns error when user has not clock out before' do
        john_clocks_in

        expect {
          post '/user/clock_in', params: {
            user_id: john.id,
            current_time: now
          }
        }.to change(Presence, :count).by(0)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['errors']).to eq("base"=>["User hasn't clocked out yet"])
      end
    end
  end

  describe 'POST /user/clock_out' do
    context 'with valid parameters' do
      it 'updates existing presence' do
        john_clocks_in
        expect {
          post '/user/clock_out', params: {
            user_id: john.id,
            current_time: now
          }
        }.to_not change(Presence, :count)

        expect(response).to have_http_status(:ok)
        expect(json['clock_outs'].first).to eq(ApplicationHelper.format_datetime(now.in_time_zone))
      end
    end

    context 'with invalid parameters' do

      it 'returns error when user has not clocked in before' do

        expect {
          post '/user/clock_out', params: {
            user_id: john.id,
            current_time: now
          }
        }.to change(Presence, :count).by(0)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['errors']).to eq("Unable to Clock Out, Not Clocked In yet")
      end
    end
  end

  describe 'POST /user/follow' do
    context 'with valid parameters' do
      it 'creates a new follow relationship' do
        expect {
          post '/user/follow', params: {
            user_id: john.id,
            following_user_id: jane.id
          }
        }.to change(FollowList, :count).by(1)

        expect(response).to have_http_status(:ok)
        expect(json['followings'].first['name']).to eq(jane.name)
      end
    end

    context 'with invalid parameters' do
      it 'returns error when follower is missing' do
        post '/user/follow', params: { following_user_id: john.id }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['errors']).to eq({"follower"=>["Follower must exist"], "follower_id"=>["Follower can't be blank"]})
      end

      it 'returns error when followee is missing' do
        post '/user/follow', params: { user_id: john.id }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['errors']).to eq({"followee"=>["Followee must exist"], "followee_id"=>["Followee can't be blank"]})
      end

      it 'returns error when user tries to follow themselves' do
        post '/user/follow', params: {
          user_id: john.id,
          following_user_id: john.id
        }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['errors']).to eq({"followee_id"=>["Followee can't follow yourself"]})
      end

      it 'returns error for duplicate follow' do
        john_follows_jane

        expect {
          post '/user/follow', params: {
            user_id: john.id,
            following_user_id: jane.id
          }
        }.not_to change(FollowList, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['errors']).to eq({"follower_id"=>["Follower has already been taken"]})
      end
    end
  end

  describe 'POST /user/unfollow' do
    context 'with valid parameters' do
      it 'unfollow relationship' do
        john_follows_jane
        expect {
          post '/user/unfollow', params: {
            user_id: john.id,
            following_user_id: jane.id
          }
        }.to change(FollowList, :count).by(-1)

        expect(response).to have_http_status(:ok)
        expect(json['followings']).to eq([])
      end
    end

    context 'with invalid parameters' do
      it 'returns error when follower is missing' do
        post '/user/unfollow', params: { following_user_id: john.id }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['errors']).to eq("User is not followed")
      end

      it 'returns error when followee is missing' do
        post '/user/unfollow', params: { user_id: john.id }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['errors']).to eq("User is not followed")
      end

      it 'returns error when user tries to unfollow themselves' do
        post '/user/unfollow', params: {
          user_id: john.id,
          following_user_id: john.id
        }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['errors']).to eq("User is not followed")
      end
    end
  end

  private

  def json
    JSON.parse(response.body)
  end
end
