require 'rails_helper'

RSpec.describe 'Likes', type: :request do
  describe 'GET /index' do
    before do
      get user_likes_path(user_id: 1)
    end

    describe 'GET /show' do
      before do
        get user_post_path(user_id: 1, id: 1)
      end
    end
  end
end
