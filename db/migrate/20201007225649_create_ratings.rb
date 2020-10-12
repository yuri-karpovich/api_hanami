class CreateRatings < ActiveRecord::Migration[6.0]
  def change
    create_table :ratings do |t|
      t.references :post, index: true, foreign_key: true
      t.integer :rating, limit: 1
    end
  end
end
