class CreateSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :subscriptions, :id => false do |t|
      t.string :owner
      t.string :target
      t.boolean :approved
    end
  end

  def self.down
    drop_table :subscriptions
  end
end
