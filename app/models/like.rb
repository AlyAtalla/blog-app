class Like < ApplicationRecord
  belongs_to :author, class_name: 'User', foreign_key: :author_id
  belongs_to :post

  validates :author_id, presence: true
  validates :post_id, presence: true
end
