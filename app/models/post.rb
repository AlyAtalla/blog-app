# spec/models/post_spec.rb

require 'rails_helper'

RSpec.describe Post, type: :model do
  it 'is valid with valid attributes' do
    user = User.create(username: 'testuser')
    post = Post.new(title: 'Test Post', author: user)
    expect(post).to be_valid
  end

  it 'is not valid without a title' do
    post = Post.new(title: nil)
    expect(post).to_not be_valid
  end

  it 'is not valid if title length exceeds 250 characters' do
    post = Post.new(title: 'a' * 251)
    expect(post).to_not be_valid
  end

  it 'should have a comments_counter that is a non-negative integer' do
    post = Post.new(title: 'Test Post')
    expect(post.comments_counter).to be >= 0
    expect(post.comments_counter).to be_an(Integer)
  end

  it 'should have a likes_counter that is a non-negative integer' do
    post = Post.new(title: 'Test Post')
    expect(post.likes_counter).to be >= 0
    expect(post.likes_counter).to be_an(Integer)
  end

  it "should update the author's post_counter after save" do
    user = User.create(username: 'testuser')
    post = Post.create(title: 'Test Post', author: user)

    expect do
      post.save
      user.reload
    end.to change { user.post_counter }.by(1)
  end
end
