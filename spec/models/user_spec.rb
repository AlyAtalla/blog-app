# spec/models/user_spec.rb

require 'rails_helper'

RSpec.describe User, type: :model do
  it 'is valid with valid attributes' do
    user = User.new(
      email: 'test@example.com',
      password: 'password',
      name: 'Test User'
    )
    expect(user).to be_valid
  end

  it 'is not valid without an email' do
    user = User.new(
      password: 'password',
      name: 'Test User'
    )
    expect(user).to_not be_valid
  end

  it 'is not valid without a password' do
    user = User.new(
      email: 'test@example.com',
      name: 'Test User'
    )
    expect(user).to_not be_valid
  end

  it 'is not valid without a name' do
    user = User.new(
      email: 'test@example.com',
      password: 'password'
    )
    expect(user).to_not be_valid
  end

  it 'is not valid if the name length exceeds 50 characters' do
    user = User.new(
      email: 'test@example.com',
      password: 'password',
      name: 'a' * 51
    )
    expect(user).to_not be_valid
  end

  it 'should have a post_counter that is a non-negative integer' do
    user = User.new(
      email: 'test@example.com',
      password: 'password',
      name: 'Test User'
    )
    expect(user.post_counter).to be >= 0
    expect(user.post_counter).to be_an(Integer)
  end

  it 'should return recent posts' do
    user = User.create(
      email: 'test@example.com',
      password: 'password',
      name: 'Test User'
    )
    Post.create(title: 'Post 1', content: 'Content 1', author: user)
    Post.create(title: 'Post 2', content: 'Content 2', author: user)
    Post.create(title: 'Post 3', content: 'Content 3', author: user)
    post4 = Post.create(title: 'Post 4', content: 'Content 4', author: user)
    expect(user.recent_posts).to eq([post4, post3, post2])
  end
end
