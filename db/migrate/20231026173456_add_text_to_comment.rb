class AddTextToComment < ActiveRecord::Migration[7.1]
  def change
    add_column :comments, :text, :string
  end
end
