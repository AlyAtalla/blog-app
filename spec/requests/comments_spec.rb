require 'rails_helper'

RSpec.describe 'Comments', type: :request do
  describe 'GET /index' do
    before do
      get user_comments_path(user_id: 1)
    end

    describe 'GET /show' do
      before do
        get user_comment_path(user_id: 1, id: 1)
      end
    end
  end
end
