class CreateLikes < ActiveRecord::Migration[7.1]
  def change
    create_table :likes do |t|
      t.string :name
      t.integer :post_counter

      t.timestamps
    end
  end
end
