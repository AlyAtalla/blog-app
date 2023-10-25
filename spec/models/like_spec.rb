# spec/models/like_spec.rb

require 'rails_helper'

RSpec.describe Like, type: :model do
  it 'is valid with valid attributes' do
    user = User.create(username: 'testuser')
    post = Post.create(title: 'Test Post', content: 'This is a test post')
    like = Like.new(author: user, post:)
    expect(like).to be_valid
  end

  it 'is not valid without an author_id' do
    like = Like.new(post_id: 1)
    expect(like).to_not be_valid
  end

  it 'is not valid without a post_id' do
    like = Like.new(author_id: 1)
    expect(like).to_not be_valid
  end

  it 'should update the likes_counter on the associated post after save' do
    user = User.create(username: 'testuser')
    post = Post.create(title: 'Test Post', content: 'This is a test post')
    like = Like.create(author: user, post:)

    expect do
      like.save
      post.reload
    end.to change { post.likes_counter }.by(1)
  end
end
