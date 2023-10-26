class AddTitleAndAuthorToPosts < ActiveRecord::Migration[7.1]
  def change
    add_column :posts, :title, :string
    add_reference :posts, :author, null: false, foreign_key: true
  end
end
