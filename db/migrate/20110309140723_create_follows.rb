class CreateFollows < ActiveRecord::Migration
  def self.up
    create_table :follows do |t|
      t.integer      :star_id
      t.integer      :fan_id
      t.timestamps
    end
  end

  def self.down
    drop_table :follows
  end
end
