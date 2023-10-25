class Comment < ApplicationRecord
  belongs_to :author, class_name: 'User'
  belongs_to :post, class_name: 'Post'

  after_save :update_counter

  validates :text, presence: true, length: { maximum: 100 }
  validates :author_id, numericality: { only_integer: true }
  validates :post_id, numericality: { only_integer: true }

  def update_counter
    post.increment!(:comments_counter)
  end
end
