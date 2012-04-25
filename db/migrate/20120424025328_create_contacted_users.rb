class CreateContactedUsers < ActiveRecord::Migration
  def self.up
    create_table :contacted_users do |t|
      t.string   :twitter_id
      t.string   :twitter_name
      t.integer  :followers
      t.integer  :topic_id
      t.string   :topic_title
      t.string   :tweet
      t.string   :search_key
      t.timestamps
    end

    add_index :contacted_users, :twitter_name, :unique => true

  end

  def self.down

    remove_index :contacted_users, :twitter_name
    drop_table :contacted_users

  end

end
