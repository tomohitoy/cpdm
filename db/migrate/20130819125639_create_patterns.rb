class CreatePatterns < ActiveRecord::Migration
  def change
    create_table :patterns do |t|
      t.integer :user_id
      t.integer :analysis_id
      t.string :title
      t.text :context
      t.text :consequence
      t.integer :category
      t.text :example
      t.text :problem
      t.text :solution

      t.timestamps
    end
  end
end
