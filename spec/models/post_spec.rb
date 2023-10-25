require 'rails_helper'

RSpec.describe Post, type: :model do
  describe 'associations' do
    it 'belongs to an author' do
      association = Post.reflect_on_association(:author)
      expect(association.macro).to eq(:belongs_to)
      expect(association.options[:class_name]).to eq('User')
      expect(association.options[:foreign_key]).to eq('author_id')
      expect(association.options[:counter_cache]).to be_truthy
    end

    it 'has many comments' do
      association = Post.reflect_on_association(:comments)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:dependent]).to eq(:destroy)
    end

    it 'has many likes' do
      association = Post.reflect_on_association(:likes)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:dependent]).to eq(:destroy)
    end
  end

  describe 'validations' do
    it 'validates presence of title' do
      post = Post.new(title: nil)
      expect(post).not_to be_valid
    end

    it 'validates maximum length of title' do
      post = Post.new(title: 'a' * 251)
      expect(post).not_to be_valid
    end

    it 'validates numericality of comments_counter' do
      post = Post.new(comments_counter: 'abc')
      expect(post).not_to be_valid
    end

    it 'validates numericality of likes_counter' do
      post = Post.new(likes_counter: 'abc')
      expect(post).not_to be_valid
    end

    it 'validates comments_counter to be greater than or equal to 0' do
      post = Post.new(comments_counter: -1)
      expect(post).not_to be_valid
    end

    it 'validates likes_counter to be greater than or equal to 0' do
      post = Post.new(likes_counter: -1)
      expect(post).not_to be_valid
    end
  end

  describe '#last_five_comments' do
    it 'returns the last five comments in descending order of creation' do
      post = Post.create(title: 'Test Post')
      comment2 = Comment.create(post: post, text: 'Comment 2')
      comment3 = Comment.create(post: post, text: 'Comment 3')
      comment4 = Comment.create(post: post, text: 'Comment 4')
      comment5 = Comment.create(post: post, text: 'Comment 5')
      comment6 = Comment.create(post: post, text: 'Comment 6')

      last_five_comments = post.last_five_comments

      expect(last_five_comments).to eq([comment6, comment5, comment4, comment3, comment2])
    end
  end
end