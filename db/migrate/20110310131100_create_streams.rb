class CreateStreams < ActiveRecord::Migration
  def self.up
    create_table :streams do |t|
      t.integer      :user_id
      t.integer      :message_id
      t.timestamps
    end
  end

  def self.down
    drop_table :streams
  end

end
