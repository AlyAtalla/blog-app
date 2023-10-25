require 'rails_helper'

RSpec.describe Post, type: :model do
  # ...

  it 'Title attribute should be less than 250 characters' do
    subject.title = 'Your title with less than 250 characters' # Provide a valid title
    expect(subject).to be_valid
  end

  it 'Comments Counter attribute should be an integer number' do
    subject.comments_counter = 'some random string'
    expect(subject).to_not be_valid
  end

  it 'Comments Counter attribute should be greater or equal to zero' do
    subject.comments_counter = -4
    expect(subject).to_not be_valid
  end

  it 'Likes Counter attribute should be an integer number' do
    subject.likes_counter = 'some random string'
    expect(subject).to_not be_valid
  end

  it 'Likes Counter attribute should be greater or equal to zero' do
    subject.likes_counter = -4
    expect(subject).to_not be_valid
  end

  it 'Author posts counter can be set' do
    user = User.new(name: 'Tom', photo: 'https://unsplash.com/photos/F_-0BxGuVvo', bio: 'Teacher from Mexico.')
    post = Post.new(title: 'Post One', text: 'This is the post one')
    post.author = user
    post.user_posts_counter = 3
    expect(user.posts_counter).to eq(3)
  end

  it 'last_five_comments method should return the last five comments' do
    post = described_class.create(title: 'Post One', text: 'This is the post one')
    user = User.first

    post.comments = [
      Comment.new({ author: user, text: 'This is the comment one' }),
      Comment.new({ author: user, text: 'This is the comment two' }),
      Comment.new({ author: user, text: 'This is the comment three' }),
      Comment.new({ author: user, text: 'This is the comment four' }),
      Comment.new({ author: user, text: 'This is the comment five' }),
      Comment.new({ author: user, text: 'This is the comment six' })
    ]

    expect(post.last_five_comments).to eq(post.comments.last(5))
  end
end
