require 'rails_helper'

RSpec.describe Comment, type: :model do
  it 'Post comments counter can be set' do
    post = Post.new(title: 'Post One', text: 'This is the post one')
    comment = Comment.new(text: 'This is user 1 comment in post 1')
    comment.post = post
    comment.post_comments_counter = 3
    expect(post.comments_counter).to eq(3)
  end
end
