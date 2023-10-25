require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe 'Validations for the Comment model' do
    before(:each) do
      @comment = Comment.new(text: 'One comment', author_id: 11, post_id: 2)
    end

    it 'is valid with all attributes present' do
      expect(@comment).to be_valid
    end

    it 'is not valid if text is not present' do
      @comment.text = nil
      expect(@comment).to_not be_valid
    end

    it 'is not valid if author_id is not an integer' do
      @comment.author_id = 'W'
      expect(@comment).to_not be_valid
    end

    it 'is not valid if post_id is not an integer' do
      @comment.post_id = 'Q'
      expect(@comment).to_not be_valid
    end
  end
end
