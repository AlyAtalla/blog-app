require 'rails_helper'

RSpec.describe Like, type: :model do
  it 'Post likes counter can be set' do
    post = Post.new(title: 'Post One', text: 'This is the post one')
    like = Like.new
    like.post = post
    like.post_likes_counter = 3
    expect(post.likes_counter).to eq(3)
  end
end
