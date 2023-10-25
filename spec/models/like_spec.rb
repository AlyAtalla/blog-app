require 'rails_helper'

RSpec.describe Like, type: :model do
  describe 'validations' do
    it 'validates presence of author_id' do
      like = Like.new(author_id: nil)
      expect(like).not_to be_valid
    end

    it 'validates presence of post_id' do
      like = Like.new(post_id: nil)
      expect(like).not_to be_valid
    end
  end

  describe 'associations' do
    it 'belongs to an author' do
      association = Like.reflect_on_association(:author)
      expect(association.macro).to eq(:belongs_to)
      expect(association.options[:class_name]).to eq('User')
    end

    it 'belongs to a post' do
      association = Like.reflect_on_association(:post)
      expect(association.macro).to eq(:belongs_to)
      expect(association.options[:class_name]).to eq('Post')
      expect(association.options[:counter_cache]).to be_truthy
    end
  end
end
