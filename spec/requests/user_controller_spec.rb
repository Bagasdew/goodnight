require 'rails_helper'

RSpec.describe "UserControllers", type: :request do

  let(:john) {create(:user, name: 'John')}
  let(:jane) {create(:user, name: 'Jane')}

  let(:john_follows_jane) {create(:follow_list, follower_id: john.id, followee_id: jane.id)}
  let(:jane_follows_john) {create(:follow_list, follower_id: jane.id, followee_id: john.id)}

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
