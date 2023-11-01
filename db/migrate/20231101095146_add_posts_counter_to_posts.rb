class AddPostsCounterToPosts < ActiveRecord::Migration[7.1]
  def change
    add_column :posts, :posts_counter, :integer
  end
end
