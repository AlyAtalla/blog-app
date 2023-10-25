class Comment < ApplicationRecord
  belongs_to :author, class_name: 'User'
  belongs_to :post, class_name: 'Post', counter_cache: true

  validates :text, presence: true, length: { maximum: 100 }
  validates :author_id, numericality: { only_integer: true }
  validates :post_id, numericality: { only_integer: true }
end
