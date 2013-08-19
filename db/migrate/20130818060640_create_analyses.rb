class CreateAnalyses < ActiveRecord::Migration
  def change
    create_table :analyses do |t|
      t.text :content
      t.string :target

      t.timestamps
    end
  end
end
