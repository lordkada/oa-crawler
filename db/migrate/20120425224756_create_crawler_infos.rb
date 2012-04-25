class CreateCrawlerInfos < ActiveRecord::Migration
  def self.up
    create_table :crawler_infos do |t|
      t.integer  :analyzing_topic_id
      t.timestamps
    end
  end

  def self.down
    drop_table :crawler_infos
  end
end
