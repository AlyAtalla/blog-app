require 'rails_helper'

RSpec.describe User, type: :model do
  # ...

  it 'User Posts Counter attribute should be an integer number' do
    subject.posts_counter = 5 # Change the value to an integer
    expect(subject).to be_valid
  end


  it 'User Posts Counter attribute should be greater or equal to zero' do
    subject.posts_counter = -1 # Change the value to a negative integer
    expect(subject).to_not be_valid
  end

  # ...
end
