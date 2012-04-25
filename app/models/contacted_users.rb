class ContactedUsers < ActiveRecord::Base

  attr_accessible :twitter_id, :twitter_name, :followers, :search_key, :topic_id, :topic_title, :tweet, :tweet_id, :mention_tweet, :twitted

end
