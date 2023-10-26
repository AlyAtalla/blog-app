require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe 'validations' do
    it 'validates numericality of author_id' do
      comment = Comment.new(author_id: 'not_an_integer')
      expect(comment).not_to be_valid
    end

    it 'validates presence of text' do
      comment = Comment.new(text: nil)
      expect(comment).not_to be_valid
    end
  end

  describe 'associations' do
    it 'belongs to a post' do
      association = described_class.reflect_on_association(:post)
      expect(association.macro).to eq(:belongs_to)
    end
  end
end
