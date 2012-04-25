class AddTwittedFlag < ActiveRecord::Migration
  def up
    change_table :contacted_users do |t|
      t.string  :mention_tweet, :limit => 140
      t.boolean :twitted, :default => false
    end
  end

  def down
    remove_column :contacted_users, :mention_tweet
    remove_column :contacted_users, :twitted
  end
end
