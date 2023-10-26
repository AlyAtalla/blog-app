require 'rails_helper'

RSpec.describe Post, type: :model do
  describe 'associations' do
    it 'belongs to an author' do
      association = described_class.reflect_on_association(:author)
      expect(association.macro).to eq(:belongs_to)
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

  describe '#last_five_comments' do
    it 'returns the last five comments in descending order of creation' do
      post = Post.create(title: 'Test Post')
      comments = []
      6.times do |i|
        comments << post.comments.create(text: "Comment #{i + 1}")
      end

      expect(post.last_five_comments).to eq(comments.last(5).reverse)
    end
  end
end
