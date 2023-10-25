require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe 'validations' do
    it 'validates presence of text' do
      comment = Comment.new(text: nil)
      expect(comment).not_to be_valid
    end

    it 'validates maximum length of text' do
      comment = Comment.new(text: 'a' * 101)
      expect(comment).not_to be_valid
    end

    it 'validates numericality of author_id' do
      comment = Comment.new(author_id: 'abc')
      expect(comment).not_to be_valid
    end

    it 'validates numericality of post_id' do
      comment = Comment.new(post_id: 'abc')
      expect(comment).not_to be_valid
    end
  end

  describe 'associations' do
    it 'belongs to an author' do
      association = Comment.reflect_on_association(:author)
      expect(association.macro).to eq(:belongs_to)
      expect(association.options[:class_name]).to eq('User')
    end

    it 'belongs to a post' do
      association = Comment.reflect_on_association(:post)
      expect(association.macro).to eq(:belongs_to)
      expect(association.options[:class_name]).to eq('Post')
      expect(association.options[:counter_cache]).to be_truthy
    end
  end
end
