class Comment < ApplicationRecord
  belongs_to :author, class_name: 'User', foreign_key: :author_id
  belongs_to :post

  validates :text, presence: true
  validates :text, length: { maximum: 100 }
  validates :author_id, numericality: { only_integer: true }
  validates :post_id, numericality: { only_integer: true }
end
