class Like < ApplicationRecord
  belongs_to :author, class_name: 'User'
  belongs_to :post, counter_cache: true

  validates :author_id, presence: true
  validates :post_id, presence: true
end
