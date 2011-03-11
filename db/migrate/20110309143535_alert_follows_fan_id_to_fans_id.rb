class AlertFollowsFanIdToFansId < ActiveRecord::Migration
  def self.up
    rename_column :follows, :fan_id, :fans_id
  end

  def self.down
    rename_column :follows, :fans_id, :fan_id
  end
end
