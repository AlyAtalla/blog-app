FactoryBot.define do
  factory :user do
    name { 'MyString' }
    photo { 'MyString' }
    bio { 'MyText' }
    posts_counter { 1 }
  end
end
