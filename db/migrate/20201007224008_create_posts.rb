class CreatePosts < ActiveRecord::Migration[6.0]
  def change
    create_table :posts do |t|
      t.references :user, index: true, foreign_key: true
      t.string :title, null: false
      t.text :content
      t.string :ip, limit: 45
      t.integer :avg_rating, limit: 1, default: 0
    end
  end
end
