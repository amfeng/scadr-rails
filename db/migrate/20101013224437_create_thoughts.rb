class CreateThoughts < ActiveRecord::Migration
  def self.up
    create_table :thoughts, :id => false do |t|
      t.string :owner
      t.integer :timestamp
      t.string :text
    end
  end

  def self.down
    drop_table :thoughts
  end
end
