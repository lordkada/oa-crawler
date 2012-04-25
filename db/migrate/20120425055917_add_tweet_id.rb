class AddTweetId < ActiveRecord::Migration
  def up
    change_table :contacted_users do |t|
      t.string  :tweet_id
    end
  end

  def down
    remove_column :contacted_users, :tweet_id
  end
end
