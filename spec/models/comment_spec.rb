# spec/models/comment_spec.rb

require 'rails_helper'

RSpec.describe Comment, type: :model do
  it 'is valid with valid attributes' do
    user = User.create(username: 'testuser')
    post = Post.create(title: 'Test Post', content: 'This is a test post')
    comment = Comment.new(text: 'This is a comment', author: user, post:)
    expect(comment).to be_valid
  end

  it 'is not valid without text' do
    comment = Comment.new(text: nil)
    expect(comment).to_not be_valid
  end

  it 'is not valid if text length exceeds 100 characters' do
    comment = Comment.new(text: 'a' * 101)
    expect(comment).to_not be_valid
  end

  it 'is not valid without a valid author_id' do
    comment = Comment.new(text: 'This is a comment', author_id: nil)
    expect(comment).to_not be_valid
  end

  it 'is not valid without a valid post_id' do
    comment = Comment.new(text: 'This is a comment', post_id: nil)
    expect(comment).to_not be_valid
  end

  it 'should update the comments_counter on the associated post after save' do
    user = User.create(username: 'testuser')
    post = Post.create(title: 'Test Post', content: 'This is a test post')
    comment = Comment.create(text: 'This is a comment', author: user, post:)

    expect do
      comment.save
      post.reload
    end.to change { post.comments_counter }.by(1)
  end
end
