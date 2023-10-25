require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it 'has many posts' do
      association = User.reflect_on_association(:posts)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:foreign_key]).to eq(:author_id)
      expect(association.options[:dependent]).to eq(:destroy)
    end

    it 'has many comments' do
      association = User.reflect_on_association(:comments)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:foreign_key]).to eq(:author_id)
      expect(association.options[:dependent]).to eq(:destroy)
    end

    it 'has many likes' do
      association = User.reflect_on_association(:likes)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:foreign_key]).to eq(:author_id)
      expect(association.options[:dependent]).to eq(:destroy)
    end
  end

  describe 'validations' do
    it 'validates presence of name' do
      user = User.new(name: nil)
      expect(user).not_to be_valid
    end

    it 'validates maximum length of name' do
      user = User.new(name: 'a' * 51)
      expect(user).not_to be_valid
    end

    it 'validates numericality of post_counter' do
      user = User.new(post_counter: 'abc')
      expect(user).not_to be_valid
    end

    it 'validates post_counter to be greater than or equal to 0' do
      user = User.new(post_counter: -1)
      expect(user).not_to be_valid
    end
  end

  describe '#last_three_posts' do
    it 'returns the last three posts in descending order of creation' do
      user = User.create(name: 'Test User')
      post2 = Post.create(author: user, title: 'Post 2')
      post3 = Post.create(author: user, title: 'Post 3')
      post4 = Post.create(author: user, title: 'Post 4')

      last_three_posts = user.last_three_posts

      expect(last_three_posts).to eq([post4, post3, post2])
    end
  end
end
