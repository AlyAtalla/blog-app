require 'rails_helper'

RSpec.describe Like, type: :model do
  describe 'validations' do
    it 'validates presence of author_id' do
      like = Like.new(author_id: nil, post_id: 1)
      expect(like).not_to be_valid
    end

    it 'validates presence of post_id' do
      like = Like.new(author_id: 1, post_id: nil)
      expect(like).not_to be_valid
    end
  end

  describe 'associations' do
    it 'belongs to a post' do
      association = described_class.reflect_on_association(:post)
      expect(association.macro).to eq(:belongs_to)
    end
  end
end
