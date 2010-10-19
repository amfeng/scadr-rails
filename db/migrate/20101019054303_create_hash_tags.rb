class CreateHashTags < ActiveRecord::Migration
  def self.up
    create_table :hash_tags, :id => false do |t|
      t.string :owner
      t.integer :timestamp
      t.string :tag
    end
  end

  def self.down
    drop_table :hash_tags
  end
end
