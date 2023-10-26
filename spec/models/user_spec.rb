require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'validates presence of name' do
      user = User.new(name: nil)
      expect(user).not_to be_valid
    end

    it 'validates length of name' do
      user = User.new(name: 'a' * 51)
      expect(user).not_to be_valid
    end

    it 'validates numericality of post_counter' do
      user = User.new(post_counter: 'not_an_integer')
      expect(user).not_to be_valid
    end
  end

  describe 'associations' do
    it 'has many posts' do
      association = described_class.reflect_on_association(:posts)
      expect(association.macro).to eq(:has_many)
    end

    it 'has many comments' do
      association = described_class.reflect_on_association(:comments)
      expect(association.macro).to eq(:has_many)
    end

    it 'has many likes' do
      association = described_class.reflect_on_association(:likes)
      expect(association.macro).to eq(:has_many)
    end
  end

  describe '#last_three_posts' do
    it 'returns the last three posts in descending order of creation' do
      user = User.create(name: 'Test User')
      posts = []
      4.times do |i|
        posts << user.posts.create(title: "Post #{i + 1}")
      end

      expect(user.last_three_posts).to eq(posts.last(3).reverse)
    end
  end
end
